extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

find_key_address:
        push ebp
        mov ebp, esp
        mov edi, [esp+8]        ; mut in edi prima adresa din fisier
find_key:
        inc edi                 ; caut terminatorul de sir
        cmp byte[edi], 0
        jne find_key
        inc edi                 ; ma mut la adresa primului element din cheie
        leave
        ret
        
xor_strings:
        push ebp
        mov ebp, esp
        mov esi, dword[esp+8]   ; adresa de inceput a cheii
        mov edi, dword[esp+12]  ; adresa de inceput a valorii

xor_byte_by_byte:
        mov bl, byte[edi]       ; fac xor byte cu byte pana la terminatorul de sir
        xor bl, byte[esi]
        mov byte[edi], bl       ; suprascriu valoarea
        inc esi                 ; trec la urmatorul element
        inc edi
        cmp byte[edi], 0
        jne xor_byte_by_byte

        leave
	ret   

rolling_xor:
        push ebp
        mov ebp, esp
        mov edi, [esp+8]
        mov esi, [esp+8]   ; pastrez primul element
parse_till_end:            ; merg pana la ultimul element
        inc edi
        cmp byte[edi], 0
        jne parse_till_end
        dec edi            ; ultimul element inainte de /0
parse_the_string:
        mov bl, byte[edi]  ; pun in bl byte-ul curent
        dec edi
        xor bl, byte[edi]  ; fac xor pe byte-ul anterior
        inc edi
        mov byte[edi], bl  ; rescriu byte-ul curent
        dec edi            ; continui scadere
        cmp esi, edi       ; daca am ajuns la primul byte ma opresc
        jne parse_the_string

        leave
	ret

xor_hex_strings:
        push ebp
        mov ebp, esp
        mov esi, [esp+8]    ; adresa de la inceputul cheii
        mov edi, [esp+12]   ; adresa de la inceputul valorii
        xor ebx, ebx
        xor eax, eax
convert_each_byte:  
        sub byte[edi], 48   ; scad valoarea lui '0' din byte-ul de valoare si cheie
        sub byte[edi+1], 48
        sub byte[esi], 48
        sub byte[esi+1], 48
        cmp byte[edi], 49   ; daca e mai mare ca 9 trebuie sa scad iar
        jl verify_next_4bits
        sub byte[edi], 39
verify_next_4bits:
        cmp byte[edi+1], 49
        jl verify_key
        sub byte[edi+1], 39
verify_key:
       cmp byte[esi], 49
       jl verify_next_4bkey
       sub byte[esi], 39
verify_next_4bkey:
       cmp byte[esi+1], 49
       jl continue
       sub byte[esi+1], 39
continue:
        mov bl, byte[edi]    ; mut continutul lui bl in valoare
        shl bl, 4
        add bl, byte[edi+1]
        mov al, byte[esi]
        shl al, 4
        add al, byte[esi+1]
        xor bl, al           ; fac xor cu cheia
        mov byte[edi], bl    ; suprascriu datele
        mov byte[esi], al
        jmp overwrite        ; trebuie sa suprascriu sirul
done_with_overwriting:
        inc esi              ; ma mut la urmatorul byte
        inc edi
        cmp byte[edi], 0
        jne convert_each_byte
        jmp stop
overwrite:
        push edi             ; pastrez adresele curente pentru cheie si valoare
        push esi
continue_overwriting:
        mov bl, byte[edi+2]  ; suparascriu atat valoarea cat si cheia cu cate o pozitie
        mov al, byte[esi+2]
        mov byte[edi+1], bl
        mov byte[esi+1], al
        inc edi             ; trec la urmatoarea pozitie pentru ca vreau sa suprascriu tot sirul
        inc esi
        cmp byte[esi+2], 0  ; daca urmatorul element este /0 atunci 
        jne continue_overwriting
done:
        mov bl, byte[edi+2] ; mai trebuie doar sa pun /0 pe ultima pozitie
        mov al, byte[esi+2]
        mov byte[edi+1], bl
        mov byte[esi+1], al
        pop esi             ; restaurez adresele de memorie curente pentru cheie si valoare
        pop edi
        jmp done_with_overwriting
stop:
        leave
        ret

bruteforce_singlebyte_xor:
        push ebp
        mov ebp, esp
        mov esi, [esp+8]     ; pun in esi adresa primului caracter din string 
        xor eax, eax         ; ma asigur ca suprascriu bine registrul, nu vreau sa fie ceva in ah
        mov al, -1           ; pun in al -1 pentru ca urmeaza sa il incrementez
continue_bruteforce:
        inc al               ; deci aici va fi 0 prima data
        mov edi, esi
xor_string:
        mov bl, byte[edi]    ; fac xor cu al pe fiecare octet al string-ului pana ajung la /0
        xor bl, al
        mov byte[edi], bl
        inc edi
        cmp byte[edi], 0
        jne xor_string
        mov edi, esi         ; restaurez prima adresa pentru a vedea daca apare force in string
find_substring:
        inc edi
        cmp byte[edi], 0     ; la fiecare pas vad daca nu cumva am ajuns la final de string
        je not_found
        cmp byte[edi], 'f'   ; caut aparitia lui f
        je stop_searching
        jne find_substring
        
stop_searching:              ; cand am gasit un f in string 
        inc edi              ; merg la urmatorul caracter
        cmp byte[edi], 0     ; verific daca nu am ajuns la terminatorul de sir
        je not_found         ; daca am ajuns, inseamna ca nu am gasit cheia buna si trec la urmatoarea
        cmp byte[edi], 'o'   ; ma uit daca urmatorul caracter este o
        jne find_substring   ; daca nu e este ceea ce caut, o sa caut urmatorul f din string
        inc edi              ; continui cu acesti pasi pentru fiecare caracter pana termin cuvantul force
        cmp byte[edi], 0
        je not_found
        cmp byte[edi], 'r'
        jne find_substring
        inc edi
        cmp byte[edi], 0
        je not_found
        cmp byte[edi], 'c'
        jne find_substring
        inc edi
        cmp byte[edi], 0
        je not_found
        cmp byte[edi], 'e'
        jne find_substring
        jmp stop_bruteforce    ; daca si e este acolo unde trebuie, atunci am gasit cheia buna
not_found:
        mov edi, esi           ; daca nu am ajuns la cheia buna, atunci mai fac xor o data
continue_xor:
        mov bl, byte[edi]      ; restaurez sirul initial in cazul in care nu am gasit o cheie buna
        xor bl, al
        mov byte[edi], bl
        inc edi
        cmp byte[edi], 0
        jne continue_xor
        cmp al, 0xff            ; daca cheia nu e buna, trebuie sa fie mai mica decat 255 ca sa continui
        jne continue_bruteforce
stop_bruteforce:
        mov [esp+12], eax        ; cand am gasit cheia actualizez valoarea adresei de retur
        leave
	ret

decode_vigenere:
        push ebp
        mov ebp, esp
        mov edi, [esp+8]         ; valoarea
        mov esi, [esp+12]        ; cheia
        xor eax, eax
        xor ebx, ebx
do_the_rot:       
        mov al, byte[esi]
        mov bl, byte[edi]
        cmp bl, 97               ; trebuie sa fie caractere intre a si z de decodificat
        jb continue_rot
        cmp bl, 122
        ja continue_rot
        sub al, 97                ; scad adresa caracterului a pentru a vedea distanta dintre el si 'a'
        mov ah, 26                ; trebuie sa rotesc cu numarul caracterelor - rotatia de codificare
        sub ah, al
        mov al, ah
        add bl, al                ; adaug rotatia
        cmp bl, 122
        jbe overwrite_string
        sub bl, 123               ; daca trec de 122 scad 123 pentru ca se incepe de la 0
        add bl, 97                ; si adaug valoarea lui 'a'
overwrite_string:
        inc esi                   ; daca este o litera valida ajunge aici
        cmp byte[esi], 0
        jne continue_rot          ; daca inca nu am ajuns la finalul sirului, continui
        mov esi, [esp+12]         ; daca ajung la finalul sirului o iau de la capat
continue_rot:
        mov byte[edi], bl         ; suprasciu sirul
        inc edi                   ; trec la urmatorul caracter
        cmp byte[edi], 0          ; daca nu am ajuns la final continui
        jne do_the_rot
        
        leave
	ret

main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
        push ecx
        call find_key_address           ; apelez functia ce imi intoarce in edi adresa cheii
        add esp, 4
        
        push ecx
        push edi
        call xor_strings                ; apelez functia xor_strings
        add esp, 8

        push ecx
        call puts                       ; afisez sirul 
        add esp, 4
        
        jmp task_done

task2:
        push ecx
        call rolling_xor                ; apelez  functia reolling_xor
        add esp, 4
        
	push ecx
	call puts                       ; se afiseaza sirul 
	add esp, 4

	jmp task_done

task3:
        push ecx
        call find_key_address           ; apelez functia ce imi intoarce in edi adresa cheii
        add esp, 4
        
        push ecx
        push edi
        call xor_hex_strings            ; apelez functia cu parametri sirul si cheia
        add esp, 8
        
	push ecx                       ; se afiseaza sirul rezultat
        call puts
        add esp, 4

	jmp task_done

task4:
                                        ; :(
	push ecx
	call puts                      ; se afiseaza sirul rezultat
	pop ecx
	
	jmp task_done

task5:
        push eax                       ; eax = cheia cautata
        push ecx                       ; ecx = adresa sirului
        call bruteforce_singlebyte_xor ; se apeleaza functia cu parametri sirul si cheia
        pop ecx
                                       ; las eax pe stiva ca sa nu fie modificat in prealabil
        
	push ecx                       ; se afiseaza sirul
	call puts
	pop ecx
	                               ; eax = cheia (e deja pe stiva)
	push fmtstr
	call printf                    ; se afiseaza cheia
	add esp, 8

	jmp task_done

task6:
	push ecx
	call strlen                    ; se afla lungimea sirului in functie de care se face adresa cheii
	pop ecx

	add eax, ecx
	inc eax

	push eax                       ; eax = adresa cheii
	push ecx                       ; ecx = adresa sirului de input
	call decode_vigenere
	pop ecx
	add esp, 4

	push ecx
	call puts
	add esp, 4

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
