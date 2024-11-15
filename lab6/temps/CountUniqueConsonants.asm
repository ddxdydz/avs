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

    inputValue db 'BFggaXdfs-6', 0
    inputValue1 db 'aEe32-0', 0
    inputValue2 db 'gggggGGGG-1', 0

    consonants db 'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z'
    countedLetterFlags db 32 dup(0)

.code
; Процедура для получения кода символа в нижнем регистре, результат в eax
ToLowerCase PROC char:BYTE	
	xor eax, eax
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

; Процедура для получения суммы чисел в массиве, результат в eax
GetSum PROC lpNums:DWORD, count:BYTE	
    xor eax, eax ; числа будут добавляться из массива к eax в цикле
    mov esi, lpNums
	mov cl, count
	FORLOOP:
		mov dl, [esi]
        add al, dl
		inc esi
		dec cl
		cmp cl, 0
		jne FORLOOP
    ret
GetSum ENDP

; Процедура для учёта встречаемости букв
SetLetterFlag PROC letterCode: BYTE
	push esi
	sub letterCode, 'a'
	mov esi, offset countedLetterFlags
	add esi, dword ptr letterCode
	mov byte ptr [esi], 1
	pop esi
	ret
SetLetterFlag ENDP

; Процедура для получения количества уникальных согласных в слове, результат в eax
CountUniqueConsonants PROC lpWord:DWORD, wordSize:BYTE
	push esi 
	push ecx
	push edx
	
	; обнуляем массив с флагами букв
    invoke RtlZeroMemory, addr countedLetterFlags, sizeof countedLetterFlags
    
    mov esi, lpWord
	mov cl, wordSize
	FORLOOP:

		mov al, [esi]
	
		; Проверка буквы на согласную
		invoke IsConsonant, al
		cmp eax, 0
		je NoConsonant
		
		Consonant:
			mov al, [esi]
			invoke ToLowerCase, al
			invoke SetLetterFlag, al  ; Устанавливаем флаг соответствующей буквы
		
		NoConsonant:

		inc esi
		dec cl
		cmp cl, 0
		jne FORLOOP
	
	; Складываем установленные флаги согласных букв
	invoke GetSum, addr countedLetterFlags, sizeof countedLetterFlags
	
	pop edx
	pop ecx
	pop esi
    ret
CountUniqueConsonants ENDP

start:
	
	invoke crt_printf, addr strFormat, addr inputValue
    invoke CountUniqueConsonants, addr inputValue, sizeof inputValue
    invoke crt_printf, addr numFormat, eax
	
	invoke crt_printf, addr strFormat, addr inputValue1
    invoke CountUniqueConsonants, addr inputValue1, sizeof inputValue1
    invoke crt_printf, addr numFormat, eax
	
	invoke crt_printf, addr strFormat, addr inputValue2
    invoke CountUniqueConsonants, addr inputValue2, sizeof inputValue2
    invoke crt_printf, addr numFormat, eax
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0

end start
