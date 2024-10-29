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

.DATA
	tempNumber dd 0
	
	startInputFormat db "Enter a number: ", 0
	endInputFormat db " ", 10, 0
	resultInputFormat db "Input result: %d", 10, 0
	numericCharFormat db "%d", 0

    result DWORD ?
    rrFormat db "RR: %d", 10, 0
    
	endMsg db "END", 10, 0
	startMsg db "start", 10, 0

    buffer_key_1 db BSIZE dup(0)
    ;cdkey dd ?

    stdin dd ?
    stdout dd ?
    
    bytesRead db 0
    input_buffer db 8 dup(0)
.code
; функция для вычисления модуля, результат в eax
InputDecimalNumber PROC
	invoke GetStdHandle, STD_INPUT_HANDLE
	;LOCAL buffer BYTE 256 dup(0);
	LOCAL tempVar DWORD
	LOCAL cdkey3 DWORD ?
    startInputCycle:
		;invoke crt_printf, addr startMsg
		invoke ReadConsoleInput, eax, addr buffer, 255, addr cdkey3; 
		invoke ReadConsoleInput, eax, addr buffer, 255, addr cdkey3;
		
		mov eax, [bufferAdress]
		
		; Проверка Enter 
		cmp [eax + 14d], VK_RETURN
		je @end_input_cycle
    
		; Проверка на наличие кода символа 
		cmp eax[14d], 0
		je @start_input_cycle
		
		invoke crt_printf, addr rrFormat, bufferAdress[14d]
    
		; Проверка принадлежности введенного кода заданному диапазону
		cmp bufferAdress[14d], 30h
		jb @start_input_cycle
		cmp bufferAdress[14d], 39h
		ja @start_input_cycle
	
		; Формирование числа (сборка числа из цифр)
		mov eax, tempNumber
		; Увеличение порядка
		mov ebx, 10d
		imul ebx
		; Добавление введённого числа
		mov edx, DWORD ptr bufferAdress[14d]
		sub edx, 30h
		add eax, edx
		; Сохранение
		mov tempNumber, eax
		; Вывод на экран введённого числа
		invoke crt_printf, addr numericCharFormat, edx
		
		jmp @start_input_cycle
    @end_input_cycle:
		invoke crt_printf, addr endInputFormat
		invoke crt_printf, addr resultInputFormat, tempNumber
    ret
InputDecimalNumber ENDP

start:
	invoke GetStdHandle, STD_INPUT_HANDLE; дескриптор консоли ввода 
    mov stdin, eax; дескриптор сохраняем в переменную
    
    invoke crt_printf, addr startInputFormat
    mov tempNumber, 0
    
    invoke InputDecimalNumber
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
	invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, addr input_buffer, 7, addr bytesRead, 0
end start
