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
    fileHandler dd ?
    inputBuffer db BSIZE dup(0)
    numberOfBytesRead db 0 
    outputBuffer db BSIZE dup(1)
	numberOfBytesAtOutput db 0

    inFilePath db "C:\Users\UserLog.ru\Desktop\temp\avs\lab6\files\in.txt", 0
    outFilePath db "C:\Users\UserLog.ru\Desktop\temp\avs\lab6\files\out.txt", 0

    stdin dd ?
    stdout dd ?

    buffer_key db BSIZE dup(0)
    cdkey dd ?

	numFormat db "%d", 10, 0
	charFormat db "%c", 10, 0
	strFormat db "%s", 10, 0
	newlineFormat db " ", 10, 0
	inLineNumsFormat db "%d, ", 0
	inLineCharFormat db "%c", 0
	printIndexFormat db "%d) ", 0
	printWordSizeFormat db "size: %d", 0
	printWordFormat db "word: ", 0
    printInputFirstFormat db " Input first letter: ", 0
    printInputTextFormat db " Based text: ", 10, 0
    printOutputTextFormat db " Output text: ", 10, 0
    printInputStringFormat db " Based string: ", 0
    printOutputStringFormat db " Output string: ", 0
    printStringWordsFormat db " String words: ", 10, 0

    first_letter db 'b'

	; Для хранения информации о словах в строке
	wordsBases dd 32 dup(0)
	wordsSizes db 32 dup(0)
	wordsCount dd 0
	
	currentStringSize dd 0
	textSize dd 0
	stringNumBuffer db 8 dup(?)
	stringCount dd 0

.code
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

; Процедура для проверки является ли символ буквой,
; В eax записывается 1, если является, иначе 0.
IsLetter PROC char:BYTE

	; в нижний регистр
	invoke ToLowerCase, char
	mov char, al
	
    mov eax, 0

    mov dl, char
    cmp dl, 'a'
    jb ToEnd    ;dx < 'a'
    cmp dl, 'z'
    ja ToEnd    ;dx > 'z'

    mov eax, 1
	
	ToEnd:
    ret
IsLetter ENDP

InputFirstLetter PROC
	invoke GetStdHandle, STD_INPUT_HANDLE
    mov stdin, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov stdout, eax
	invoke crt_printf, addr printInputFirstFormat
    @startInputCycle:
		invoke ReadConsoleInput, stdin, addr buffer_key, BSIZE, addr cdkey
		
		; Проверка на нажатие
		cmp [buffer_key + 4d], 1h
		jne @startInputCycle
		
		; Проверка на наличие кода символа 
		cmp [buffer_key + 14d], 0
		je @startInputCycle

		; Проверка на букву
		invoke IsLetter, [buffer_key + 14d]
		cmp eax, 0  ; если не является бувой
		je @startInputCycle
		
		movzx eax, [buffer_key + 14d]
		invoke ToLowerCase, al
		mov first_letter, al
		invoke crt_printf, addr charFormat, eax
		
    ret
InputFirstLetter ENDP

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

; Обнуление счётчика добавленных слов 
ClearWords PROC
	mov wordsCount, 0	; обнуляем счётчик слов
	ret
ClearWords ENDP

; Печать строки
PrintString PROC lpString:DWORD, stringSize:DWORD
	push esi
	push eax
	push ecx
	
	mov esi, lpString
	mov ecx, stringSize
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
PrintString ENDP

; Печать слова по индексу
PrintWord PROC wordIndex:DWORD
	push esi
	push eax
	push ecx
	
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
	
	pop ecx
	pop eax
	pop esi
	ret
PrintWord ENDP

; Печать добавленных слов в строку через пробел
PrintWordsInLine PROC
	push eax
	push ecx

	mov ecx, 0
	FORLOOP:
		cmp ecx, wordsCount
		je ENDFOR
		
		push ecx
		invoke PrintWord, ecx
		invoke crt_printf, addr inLineCharFormat, " "
		pop ecx
		
		inc ecx
		jmp FORLOOP
	ENDFOR:
		
	invoke crt_printf, addr newlineFormat

	pop ecx
	pop eax
	ret
PrintWordsInLine ENDP

; Добавление строки в буффер для вывода, в конце строки должен быть 0-й байт
AddStringToOutputBuffer PROC lpString:DWORD
	push esi
	push edi
	
	mov edi, offset outputBuffer
	movzx eax, numberOfBytesAtOutput
	add edi, eax
	
	cld
	
	mov esi, lpString
	mov ecx, 0
	FORLOOP:
		mov al, [esi]
		cmp al, 0
		je ENDFOR
		
		stosb
		inc numberOfBytesAtOutput
		
		inc esi
		jmp FORLOOP
	ENDFOR:
	
	pop edi
	pop esi
	ret
AddStringToOutputBuffer ENDP

; Добавление перевёрнутого слова в буффер для вывода
AddWordToOutputBuffer PROC wordIndex:DWORD
	push esi
	push edi
	push eax
	push ecx
	
	; Source, адрес начала слова
	invoke GetWordBase, wordIndex
	mov esi, eax
	
	; Destination, адрес начала ячеек для записи в outputBuffer
	mov edi, offset outputBuffer
	movzx eax, numberOfBytesAtOutput
	add edi, eax

	invoke GetWordSize, wordIndex
	mov ecx, eax
	
	add numberOfBytesAtOutput, cl
	
	cmp ecx, 0
	je ENDWHILE
	
	add esi, ecx
	dec esi
	WHILELOOP:
		cmp ecx, 0
		je ENDWHILE
		mov eax, [esi]
		mov [edi], eax
		inc edi
		dec esi
		dec ecx
		jmp WHILELOOP
	ENDWHILE:

	pop ecx
	pop eax
	pop edi
	pop esi
	ret
AddWordToOutputBuffer ENDP

; Добавление символа в буффер для вывода
AddCharToOutputBuffer PROC char:DWORD
	push esi

	mov esi, offset outputBuffer
	movzx eax, numberOfBytesAtOutput
	add esi, eax

	mov al, byte ptr char
	mov [esi], al
	
	inc numberOfBytesAtOutput

	pop esi
	ret
AddCharToOutputBuffer ENDP

; Добавление строки в буффер для вывода
AddWordsToOutputBuffer PROC
	push eax
	push ecx
	
	; Добавление нумерации строк
    mov eax, stringCount
    add eax, 48
    invoke AddCharToOutputBuffer, eax
	invoke AddCharToOutputBuffer, ')'
	invoke AddCharToOutputBuffer, ' '
	
	; Добавление обработанных слов из сроки с текущем номером через пробел
	mov ecx, 0
	FORLOOP:
		cmp ecx, wordsCount
		je ENDFOR
		
		invoke AddWordToOutputBuffer, ecx
		invoke AddCharToOutputBuffer, ' '
		
		inc ecx
		jmp FORLOOP
	ENDFOR:
	
	; Перенос на новую строку
	invoke AddCharToOutputBuffer, 10

	pop ecx
	pop eax
	ret
AddWordsToOutputBuffer ENDP

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
    push ebx

    xor ebx, ebx

    mov esi, lpString
	WHILELOOP:
		
		; Добавляем обработанные слова
		invoke GetNextWordSize, esi
		cmp eax, 0
		je EMPTY  ; Если слово пустое (размер не 0), то не добавляем его

        push eax
        xor eax, eax
        mov al, [esi]
        invoke ToLowerCase, al 
        mov dl, al
        pop eax
        cmp dl, first_letter
        jne EMPTY  ; Если буква не равна заданной

		invoke AddWord, esi, al

		EMPTY:

		inc eax
		add esi, eax  ; смещение на следующее слово
		
		; Проверяем завершение строки
		mov al, [esi]
		cmp al, 10
		je ENDWHILE  ; Если перенос строки
		cmp al, 0
		je ENDWHILE  ; Если конец текста
		
		jmp WHILELOOP
	ENDWHILE:

	mov eax, esi
	sub eax, lpString

    pop ebx
	pop esi
    ret
ProcessString ENDP

start:
	; Чтение файла in.txt
    invoke CreateFileA, offset inFilePath, GENERIC_READ, 0, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandler, eax
    invoke SetFilePointer, fileHandler, 0, 0, FILE_BEGIN
    invoke ReadFile, fileHandler, addr inputBuffer, sizeof inputBuffer - 1, addr numberOfBytesRead, 0
    invoke CloseHandle, fileHandler
    
    ; Добавление нулевого байта в конец прочитанного текста для обозначения окончания
    mov esi, offset inputBuffer
    inc numberOfBytesRead
    add esi, dword ptr numberOfBytesRead
    mov [esi], byte ptr 0

    ; Вывод в консоль прочитанного текста
    invoke crt_printf, addr printInputTextFormat
    invoke PrintString, offset inputBuffer, numberOfBytesRead
    invoke crt_printf, addr newlineFormat
    
    invoke InputFirstLetter
    invoke crt_printf, addr charFormat, ' '

    ; Обработка строк в файле in.txt
    mov esi, offset inputBuffer
	WHILELOOP:
		
		; Обработка очередной строки
		invoke ProcessString, esi
		mov currentStringSize, eax
		inc stringCount
        
        invoke AddWordsToOutputBuffer

        invoke ClearWords
        
        inc currentStringSize
        mov eax, currentStringSize
        add textSize, eax
        mov esi, offset inputBuffer
		add esi, textSize  ; смещение на начало следующей строки
		
		movzx eax, numberOfBytesRead
		cmp textSize, eax
		jb WHILELOOP  ; Если не конец ввода, ecx < numberOfBytesRead
	
	; Вывод в консоль результата
	invoke crt_printf, addr printOutputTextFormat
	invoke PrintString, offset outputBuffer, numberOfBytesAtOutput

    ; Запись результата в файл out.txt
    invoke CreateFileA, offset outFilePath, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0 
    mov fileHandler, eax
    invoke SetFilePointer, fileHandler, 0, 0, FILE_BEGIN
    invoke WriteFile, fileHandler, addr outputBuffer, numberOfBytesAtOutput, 0, 0  
    invoke CloseHandle, fileHandler
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0
end start
