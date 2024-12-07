.386
.model flat, stdcall
option casemap:none
include includes\windows.inc
include includes\masm32.inc
include includes\kernel32.inc
includelib includes\masm32.lib
includelib includes\kernel32.lib

BSIZE equ 256

.data
	varA dd ?
    varB dd ?
    varC dd ?
    varD dd ?
    varE dd ?
    varF dd ?
    varG dd ?
    varH dd ?
    varK dd ?
    varM dd ?
	result dd ?
	
	startInputFormat db "Enter var?: ", 0
	varValueFormat db "Entered var?: ", 0
	resultFormat db "Result: ", 10, 0
	errorZeroDivision db "Error: ZeroDivision", 10, 0
	functionString db "(ab + c + de + f/g)+(h + k/m) = ", 0

    stdin dd ?
    stdout dd ?
 
    outputBuffer db BSIZE dup(0)
    newline db 10

    buffer_key db BSIZE dup(0)
    cdkey dd ?
	
	numFormat db "%d", 10, 0
.code
InputDecimalNumber PROC lpVarForNumber:DWORD
	; Происходит сохранение введённого числа в 
	; переменную типа dword, на которую указывает переданный адрес lpVarForNumber

	mov esi, lpVarForNumber
	mov eax, 0
	mov [esi], eax	; Обнуление переменной для записи числа

    @startInputCycle:
		invoke ReadConsoleInput, stdin, addr buffer_key, BSIZE, addr cdkey
		
		; Проверка на нажатие
		cmp [buffer_key + 4d], 1h
		jne @startInputCycle
		
		; Проверка на наличие кода символа 
		cmp [buffer_key + 14d], 0
		je @startInputCycle

		; Проверка Enter 
		cmp [buffer_key + 14d], VK_RETURN
		je @endInputCycle

		; Проверка принадлежности введенного кода заданному диапазону 0-9
		cmp [buffer_key + 14d], 30h
		jb @startInputCycle
		cmp [buffer_key + 14d], 39h
		ja @startInputCycle
		
		; Формирование числа (сборка числа из цифр)
		; Увеличение порядка
		mov eax, [esi]
		imul eax, 10
		; Преобразовние кода в число
		xor edx, edx
		mov dl, [buffer_key + 14d]
		sub dl, 30h
		; Добавление введённого числа
		add eax, edx
		mov [esi], eax
		
		; Вывод на экран введённого числа
		add dl, 48  ; Преобразовние числа в код символа
		mov [outputBuffer], dl
		invoke WriteConsoleA, stdout, offset outputBuffer, 1, 0, 0
		
		jmp @startInputCycle
	@endInputCycle:
		invoke WriteConsoleA, stdout, offset newline, 1, 0, 0
    ret
InputDecimalNumber ENDP

InputVarWithInvitation PROC lpVarForNumber:DWORD, varName: DWORD
	mov eax, varName
	mov [startInputFormat + 9], al	; Добавление имени переменной в выводимую строку
    invoke WriteConsoleA, stdout, offset startInputFormat, sizeof startInputFormat - 1, 0, 0
    invoke InputDecimalNumber, lpVarForNumber
    ret
InputVarWithInvitation ENDP

PrintNumber PROC number:DWORD, base:DWORD
	mov esi, offset outputBuffer
	add esi, BSIZE	; Адрес для записи разрядов с конца буфера
	xor ecx, ecx	; Счётчик количества разрядов числа
    mov eax, number	; Делимое
    whileLoop:
    	inc ecx
    	
        xor edx, edx    ; Хранит остаток после деления
        push ecx
        mov ecx, base	; Делитель
        div ecx
        pop ecx
		
        ; Сохранение символа в буфер (с конца)
        add edx, 48		; Преобразовние числа остатка в код символа
        dec esi
    	mov [esi], dl
        
        cmp eax, 0
        jne whileLoop   ; Пока делимое не равно нулю
    invoke WriteConsoleA, stdout, esi, ecx, 0, 0
	ret
PrintNumber ENDP

PrintVarValue PROC lpVarForNumber:DWORD, varName: DWORD
	mov eax, varName
	mov [varValueFormat + 11], al	; Добавление имени переменной в выводимую строку
	invoke WriteConsoleA, stdout, offset varValueFormat, sizeof varValueFormat - 1, 0, 0
	
	mov esi, lpVarForNumber
	invoke PrintNumber, [esi], 10
	
	invoke WriteConsoleA, stdout, offset newline, 1, 0, 0
    ret
PrintVarValue ENDP

start:
	invoke GetStdHandle, STD_INPUT_HANDLE
    mov stdin, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov stdout, eax
    
    ; Ввод значений
    invoke InputVarWithInvitation, offset varA, 'A'
    invoke InputVarWithInvitation, offset varB, 'B'
    invoke InputVarWithInvitation, offset varC, 'C'
    invoke InputVarWithInvitation, offset varD, 'D'
    invoke InputVarWithInvitation, offset varE, 'E'
    invoke InputVarWithInvitation, offset varF, 'F'
    invoke InputVarWithInvitation, offset varG, 'G'
    invoke InputVarWithInvitation, offset varH, 'H'
    invoke InputVarWithInvitation, offset varK, 'K'
    invoke InputVarWithInvitation, offset varM, 'M'
    invoke WriteConsoleA, stdout, offset newline, 1, 0, 0
    
    ; Вывод введённых значений для проверки
    invoke PrintVarValue, offset varA, 'A'
    invoke PrintVarValue, offset varB, 'B'
    invoke PrintVarValue, offset varC, 'C'
    invoke PrintVarValue, offset varD, 'D'
    invoke PrintVarValue, offset varE, 'E'
    invoke PrintVarValue, offset varF, 'F'
    invoke PrintVarValue, offset varG, 'G'
    invoke PrintVarValue, offset varH, 'H'
    invoke PrintVarValue, offset varK, 'K'
    invoke PrintVarValue, offset varM, 'M'
    invoke WriteConsoleA, stdout, offset newline, 1, 0, 0
    
    ; Вычисление выражения по частям: ab + c + de + f/g + h + k/m
    mov result, 0
    
    ; ab
    mov eax, varA
    mul varB
    add result, eax
    
    ; + c
    mov eax, varC
    add result, eax
    
    ; + de
    mov eax, varD
    mul varE
    add result, eax
    
    ; + f/g
    mov eax, varF
    mov ecx, varG
    cmp ecx, 0
    je ZeroDivision  ; Проверка деления на 0
    div ecx
    add result, eax
    
    ; + h
    mov eax, varH
    add result, eax
    
    ; + k/m
    mov eax, varK
    mov ecx, varM
    cmp ecx, 0
    je ZeroDivision  ; Проверка деления на 0
    div ecx
    add result, eax
    
    ; Вывод результата вычислений
    invoke WriteConsoleA, stdout, offset resultFormat, sizeof resultFormat - 1, 0, 0
    invoke WriteConsoleA, stdout, offset functionString, sizeof functionString - 1, 0, 0
    invoke PrintNumber, result, 10
    invoke WriteConsoleA, stdout, offset newline, 1, 0, 0
    jmp ToEnd
    ZeroDivision:
    	invoke WriteConsoleA, stdout, offset errorZeroDivision, sizeof errorZeroDivision - 1, 0, 0
    ToEnd:
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполненияToEnd:
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0
	
    invoke ExitProcess, 0
end start
