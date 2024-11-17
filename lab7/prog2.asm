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
	num1 dd ?
	num2 dd ?
	num3 dd ?
	
	result1 db ?
	result2 db ?
	
	startInputFormat db "Enter a decimal number for var?: ", 0
	resultInputFormat db "Value of var?: ", 0

    stdin dd ?
    stdout dd ?
 
    outputBuffer db BSIZE dup(0)
    newline db 10

    buffer_key db BSIZE dup(0)
    cdkey dd ?
 
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
	mov [startInputFormat + 30], al
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
	mov [resultInputFormat + 13], al
    ret
PrintVarValue ENDP

start:
	invoke GetStdHandle, STD_INPUT_HANDLE; дескриптор консоли ввода 
    mov stdin, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE; дескриптор консоли вывода 
    mov stdout, eax
    
    ; Ввод значений чисел (num1, num2, num3)
    invoke InputVarWithInvitation, offset num1, 'A'
    
    ; Вывод введённых значений чисел для проверки
    ;invoke crt_printf, addr resultInputFormat, 1, num1
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0
end start
