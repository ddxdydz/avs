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

BSIZE equ 256

.data
	numFormat db "%d", 10, 0
	charFormat db "%c", 10, 0
	strFormat db "%s", 10, 0
	newlineFormat db " ", 10, 0
	inLineNumsFormat db "%d, ", 0
	inLineCharFormat db "%c", 0
	printWordIndexFormat db "%d) ", 0
	printWordSizeFormat db "size: %d", 0
	printWordConsonantsFormat db "unique_consonants: %d", 0
	printWordFormat db "word: ", 0
	
    inputValue db "wordAr     longwordB wwWwordC sf sdga agd aaaaaaaaaaa aeuyut 123R", 0

	outputBuffer db BSIZE dup(?)
	numberOfBytesAtOutput db 0

    consonants db 'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z'
    countedLetterFlags db 32 dup(0)

	; Для хранения информации о словах в строке
	wordsBases dd 32 dup(0)
	wordsSizes db 32 dup(0)
	wordsCount dd 0

	swapFlag db 0  ; индикатор перестановок, используется в сортировке слов

.code
; Процедура для получения суммы чисел в массиве байт, результат в eax
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

; Печать массива чисел в одну строку
PrintArrayOfBytes PROC lpArray:DWORD, arraySize:BYTE
	push esi
	push ecx
	
	mov esi, lpArray
	mov cl, 0
	FORLOOP:
		
		push ecx
		movzx eax, byte ptr [esi]
		invoke crt_printf, addr inLineNumsFormat, eax
		pop ecx
		
		inc cl
		inc esi
		cmp cl, arraySize
		jne FORLOOP
	
	invoke crt_printf, addr newlineFormat
	
	pop ecx
	pop esi
	ret
PrintArrayOfBytes ENDP

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

; Получение адреса слова по индексу, результат в eax 
GetWordBase PROC wordIndex:DWORD 
	push esi
	mov esi, offset wordsBases
	mov eax, wordIndex
	imul eax, 4
	add esi, eax
	mov eax, dword ptr [esi]
	pop esi
	ret
GetWordBase ENDP

; Получение размера слова по индексу, результат в eax 
GetWordSize PROC wordIndex:DWORD 
	push esi
	mov esi, offset wordsSizes
	add esi, wordIndex
	xor eax, eax
	mov al, [esi]
	pop esi
	ret
GetWordSize ENDP

; Получение количества уникальных согласных в слове по индексу, результат в eax 
GetWordConsonants PROC wordIndex:DWORD 
	push esi
	push edx
	
	invoke GetWordBase, wordIndex
	mov edx, eax  ; сохранение адреса слова в edx
	invoke GetWordSize, wordIndex  ; размер слова в eax
	invoke CountUniqueConsonants, edx, al
	
	pop edx
	pop esi
	ret
GetWordConsonants ENDP

; Вставка информации о слове в заданную позицию
InsertWord PROC lpWord:DWORD, wordSize:BYTE, insertIndex:DWORD
	push esi
	push eax

	; Добавляем адрес слова
	mov esi, offset wordsBases
	mov eax, insertIndex
	imul eax, 4
	add esi, eax
	mov eax, lpWord
	mov [esi], eax

	; Добавляем размер слова
	mov esi, offset wordsSizes
	add esi, insertIndex
	mov al, wordSize
	mov [esi], al
	
	pop eax
	pop esi
	
	ret
InsertWord ENDP

; Добавление информации о слове
AddWord PROC lpWord:DWORD, wordSize:BYTE

	; Добавляем информацию о слове в конец
	invoke InsertWord, lpWord, wordSize, wordsCount

	; Увеличиваем счётчик добавленных слов
	inc wordsCount

	ret
AddWord ENDP

; Поменять местами слова в массивах для хранения информации слов
SwapWords PROC wordIndex1:DWORD, wordIndex2:DWORD
	push eax
	push ebx
	push ecx
	push edx

	invoke GetWordBase, wordIndex1
	mov ebx, eax  ; сохраняем адрес 1-го слова
	invoke GetWordSize, wordIndex1
	mov dl, al  ; сохраняем размер 1-го слова

	invoke GetWordBase, wordIndex2
	mov ecx, eax  ; сохраняем адрес 2-го слова
	invoke GetWordSize, wordIndex2
	mov dh, al  ; сохраняем размер 2-го слова

	; Меняем местами слова
	invoke InsertWord, ebx, dl, wordIndex2
	invoke InsertWord, ecx, dh, wordIndex1

	mov swapFlag, 1

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret
SwapWords ENDP

; Обнуление счётчика добавленных слов 
ClearWords PROC
	mov wordsCount, 0	; обнуляем счётчик слов
	ret
ClearWords ENDP

; Печать слова по индексу
PrintWord PROC wordIndex:DWORD
	push esi
	push eax
	push ecx
	
	invoke crt_printf, addr printWordIndexFormat, wordIndex
	invoke GetWordSize, wordIndex
	invoke crt_printf, addr printWordSizeFormat, eax
	invoke crt_printf, addr inLineCharFormat, '	'
	invoke GetWordConsonants, wordIndex
	invoke crt_printf, addr printWordConsonantsFormat, eax
	invoke crt_printf, addr inLineCharFormat, '	'
	invoke crt_printf, addr printWordFormat
	
	invoke GetWordBase, wordIndex
	mov esi, eax
	invoke GetWordSize, wordIndex
	mov ecx, eax
	cld
	FORLOOP:
		cmp ecx, 0
		je ENDFOR
		
		xor eax, eax
		lodsb
		push ecx
		invoke crt_printf, addr inLineCharFormat, eax
		pop ecx
		
		dec ecx
		jmp FORLOOP
	ENDFOR:

	invoke crt_printf, addr newlineFormat
	
	pop ecx
	pop eax
	pop esi
	ret
PrintWord ENDP

; Печать информации о добавленных словах из строки
PrintCountedWords PROC
	push eax
	push ecx

	mov ecx, 0
	FORLOOP:
		cmp ecx, wordsCount
		je ENDFOR
		
		invoke PrintWord, ecx
		
		inc ecx
		jmp FORLOOP
	ENDFOR:

	pop ecx
	pop eax
	ret
PrintCountedWords ENDP

; Процедура для сортировки слов в массивах для учёта слов
SortWords PROC
	push ebx
	push ecx
	push edx
	
	WHILELOOP:
		mov swapFlag, 0

		mov ecx, 1
		FORLOOP:
			cmp ecx, wordsCount
			je ENDFOR
			
			; Получаем количество уникальных согласных предыдущего слова, результат в edx 
			mov eax, ecx
			dec eax
			invoke GetWordConsonants, eax
			mov edx, eax
			
			; Получаем количество уникальных согласных текущего слова, результат в eax 
			invoke GetWordConsonants, ecx
			
			; Проверяем, нужно ли поменять слова местами
			cmp edx, eax
			jbe NOSWAP  ; если edx <= eax, то не меняем слова местами
			mov eax, ecx
			dec eax
			invoke SwapWords, eax, ecx
			NOSWAP:
	
			inc ecx
			jmp FORLOOP
		ENDFOR:

		cmp swapFlag, 1
		je WHILELOOP  ; пока есть перестановки
	
	pop edx
	pop ecx
	pop ebx
	ret
SortWords ENDP

; Получение размера 1-го слова в строке, результат в eax
GetNextWordSize PROC lpString:DWORD
	push esi
	push ecx

	xor ecx, ecx  ; обнуление счётчика количества букв в слове
    mov esi, lpString
	WHILELOOP:
		mov al, [esi]

		; Проверка, что символ является буквой:
		invoke ToLowerCase, al
    	cmp al, 'a'
    	jb TOEND
    	cmp al, 'z'
    	ja TOEND
		
		inc ecx  ; увеличение счётчика количества букв в слове
		inc esi
		jmp WHILELOOP
	TOEND:

	mov eax, ecx
	
	pop ecx
	pop esi
	ret
GetNextWordSize ENDP

; Процедура для сохранения информации о словах в строке
; В строке должно быть не более 32 слов
; Строка должна оканчиваться 0 байтом
; В eax помещается размер обработанной строки
ProcessString PROC lpString:DWORD
	push esi

    mov esi, lpString
	WHILELOOP:

		invoke GetNextWordSize, esi
		cmp eax, 0
		je EMPTY  ; Если слово пустое (размер не 0), то не добавляем его
		invoke AddWord, esi, al
		EMPTY:
		inc eax
		add esi, eax  ; смещение на следующее слово
		
		mov al, [esi]
		cmp al, 0
		jne WHILELOOP  ; Если не конец строки

	mov eax, esi
	sub eax, lpString

	pop esi
    ret
ProcessString ENDP

start:
	invoke ProcessString, offset inputValue
	invoke crt_printf, addr numFormat, eax
	invoke PrintArrayOfBytes, offset wordsSizes, sizeof wordsSizes
    invoke PrintCountedWords
    
    invoke SwapWords, 3, 1
    invoke PrintArrayOfBytes, offset wordsSizes, sizeof wordsSizes
    invoke PrintCountedWords
    
    invoke SortWords
    invoke PrintArrayOfBytes, offset wordsSizes, sizeof wordsSizes
    invoke PrintCountedWords
    
    invoke ClearWords
    invoke PrintArrayOfBytes, offset wordsSizes, sizeof wordsSizes
    invoke PrintCountedWords
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0

end start
