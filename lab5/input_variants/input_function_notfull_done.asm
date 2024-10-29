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
	num1 db ?
	num2 db ?
	num3 db ?
	
	result1 db ?
	result2 db ?
	
	startInputFormat db "Enter a 8-bit number%d: ", 0
	resultInputFormat db "Input result number%d: ", 0
	numericCharFormat db "%d", 0
	newLineFormat db " ", 10, 0
	resultFormat db "Calculation results: ", 10, 0

    stdin dd ?

    buffer_key db BSIZE dup(0)
    cdkey dd ?
    
    inputBuffer db 8 dup(0)
    bytesRead db 0

.code
; Функция для вывода на экран чисел в двоичном формате
printBinary PROC number:BYTE
	mov bl, 8
	outputCycle:
		rol number, 1
		mov al, number
		and al, 1	; обнуление битов, кроме младшего
		invoke crt_printf, addr numericCharFormat, al
		dec bl
		cmp bl, 0
		jne outputCycle
		invoke crt_printf, addr newLineFormat
	ret
printBinary ENDP

; Функция для ввода чисел 8-bit, результат в al
InputBynaryNumber PROC
	LOCAL resultNumber: BYTE		; результат работы функции
	LOCAL currentInputNumber: DWORD	; номер вводимого разряда числа
	mov resultNumber, 0
    mov currentInputNumber, 1
    @startInputCycle:
		;invoke crt_printf, addr startMsg
		invoke ReadConsoleInput, stdin, addr buffer_key, BSIZE, addr cdkey; 
		invoke ReadConsoleInput, stdin, addr buffer_key, BSIZE, addr cdkey;

		; Проверка Enter 
		cmp [buffer_key + 14d], VK_RETURN
		je @endInputCycle

		; Проверка на наличие кода символа 
		cmp [buffer_key + 14d], 0
		je @startInputCycle

		; Проверка принадлежности введенного кода заданному диапазону
		cmp [buffer_key + 14d], 30h
		jb @startInputCycle
		cmp [buffer_key + 14d], 31h
		ja @startInputCycle

		; Формирование числа (сборка числа из цифр)
		mov al, resultNumber
		; Увеличение порядка
		shl al, 1
		; Добавление введённого числа
		mov dl, [buffer_key + 14d]
		sub dl, 30h
		add al, dl
		; Сохранение
		mov resultNumber, al

		; Вывод на экран введённого числа
		invoke crt_printf, addr numericCharFormat, dl
		
		; Валидация на ввод не более 8 разрядов числа
		cmp currentInputNumber, 8
		je @endInputCycle
		inc currentInputNumber
		
		jmp @startInputCycle
	@endInputCycle:
		invoke crt_printf, addr newLineFormat
		mov al, resultNumber
    ret
InputBynaryNumber ENDP

start:
	invoke GetStdHandle, STD_INPUT_HANDLE; дескриптор консоли ввода 
    mov stdin, eax; дескриптор сохраняем в переменную
    
    ; Ввод значений чисел (num1, num2, num3)
    invoke crt_printf, addr startInputFormat, 1
    invoke InputBynaryNumber
    mov num1, al
    invoke crt_printf, addr startInputFormat, 2
    invoke InputBynaryNumber
    mov num2, al
    invoke crt_printf, addr startInputFormat, 3
    invoke InputBynaryNumber
    mov num3, al
    invoke crt_printf, addr newLineFormat
    
    ; Вывод введённых значений чисел для проверки
    invoke crt_printf, addr resultInputFormat, 1
    invoke printBinary, num1
    invoke crt_printf, addr resultInputFormat, 2
    invoke printBinary, num2
    invoke crt_printf, addr resultInputFormat, 3
    invoke printBinary, num3
    
    ; Извлечение старшей части num1
    mov al, num1
    shr al, 4
    mov dl, al          
    ; Извлечение младшей части num3
    mov al, num3      
    and al, 0Fh       
    ; Логическое сложение старшей части num1 и младшей num3, результат в dl
    or dl, al

    ; Извлечение младшей части num1
    mov al, num1
    and al, 0Fh   
    ; Извлечение младшей части num2
    mov bl, num2   
    and bl, 0Fh   
    ; Логическое умножение младшей части num1 и младшей части num2, результат в al
    and al, bl

    ; Делим результат на 4
    shr dl, 2        
    shr al, 2
		
	; Сохранение результатов
	mov result1, dl
	mov result2, al
    
    ; Вывод результатов в двоичном виде
	invoke crt_printf, addr newLineFormat
	invoke crt_printf, addr resultFormat
	invoke printBinary, result1
	invoke printBinary, result2
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
	invoke ReadConsoleA, stdin, addr inputBuffer, 8, addr bytesRead, 0
	
    invoke ExitProcess, 0
end start
