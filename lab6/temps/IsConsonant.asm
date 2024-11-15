.386
.model flat, stdcall
option casemap:none
include includes\windows.inc
include includes\user32.inc
include includes\kernel32.inc
include includes\msvcrt.inc
includelib includes\user32.lib
includelib includes\kernel32.lib
includelib includes\msvcrt.lib

.data
	numFormat db "%d", 10, 0
	charFormat db "%c", 10, 0
	strFormat db "%s", 10, 0
	newlineFormat db " ", 10, 0

    inputValue db 'a'
    inputValue1 db 'b'
    inputValue2 db 'G'
    inputValue3 db 'p'
    inputValue4 db 'z'
    inputValue5 db '0'

    consonants db 'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z'

.code
; Процедура для получения кода символа в нижнем регистре, результат в al
ToLowerCase PROC char:BYTE	
    mov al, char

    ; Проверка, что символ в верхнем регистре:
    cmp char, 'A'
    jb ToEnd
    cmp char, 'Z'
    ja ToEnd

    add al, 32  ; в нижний регистр
    
    ToEnd:
    ret
ToLowerCase ENDP

; Процедура для проверки является ли символ согласной буквой,
; В eax записывается 1, если является, иначе 0.
IsConsonant PROC char:BYTE		
	push esi 
	push ecx
	push edx
	
	; в нижний регистр
	invoke ToLowerCase, char
	mov char, al
	
    mov eax, 1  ; изначально считаем символ согласной буквой

    ; сравниваем символ с каждой согласной буквой из списка consonants
    mov esi, offset consonants
    mov cl, sizeof consonants
	FORLOOP:
		
		mov dl, [esi]	; код очередной согласной буквы
		cmp char, dl
		je ToEnd	; Если символ совпал с согласной из списка, то выход
		
		inc esi
		dec cl
		cmp cl, 0
		jne FORLOOP
		
	; Если символ не совпал с символами согласных букв из списка, значит это не согласная
	mov eax, 0
	
	ToEnd:
	
	pop edx
	pop ecx
	pop esi
    ret
IsConsonant ENDP

start:
	
	invoke crt_printf, addr charFormat, inputValue
    invoke IsConsonant, inputValue
    invoke crt_printf, addr numFormat, eax
    invoke crt_printf, addr newlineFormat
    
    invoke crt_printf, addr charFormat, inputValue1
    invoke IsConsonant, inputValue1
    invoke crt_printf, addr numFormat, eax
    invoke crt_printf, addr newlineFormat
    
    invoke crt_printf, addr charFormat, inputValue2
    invoke IsConsonant, inputValue2
    invoke crt_printf, addr numFormat, eax
    invoke crt_printf, addr newlineFormat
    
    invoke crt_printf, addr charFormat, inputValue3
    invoke IsConsonant, inputValue3
    invoke crt_printf, addr numFormat, eax
    invoke crt_printf, addr newlineFormat
    
    invoke crt_printf, addr charFormat, inputValue4
    invoke IsConsonant, inputValue4
    invoke crt_printf, addr numFormat, eax
    invoke crt_printf, addr newlineFormat
    
    invoke crt_printf, addr charFormat, inputValue5
    invoke IsConsonant, inputValue5
    invoke crt_printf, addr numFormat, eax
    invoke crt_printf, addr newlineFormat
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0

end start
