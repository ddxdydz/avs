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
    cdkey dd ?

    stdin dd ?
    stdout dd ?
    
    bytesRead db 0
    input_buffer db 8 dup(0)
.code
start:
	invoke AllocConsole
	invoke GetStdHandle, STD_INPUT_HANDLE; дескриптор консоли ввода 
	mov stdin, eax; дескриптор сохраняем в переменную
    
    @start_input_cycle:
		invoke crt_printf, addr startMsg
		invoke ReadConsoleInput, stdin, addr buffer_key_1, BSIZE, addr cdkey; 
		invoke ReadConsoleInput, stdin, addr buffer_key_1, BSIZE, addr cdkey; 
		
		; Проверка Enter 
		cmp [buffer_key_1 + 14d], VK_RETURN
		je @end_input_cycle
    
		; Проверка на наличие кода символа 
		cmp [buffer_key_1 + 14d], 0
		je @start_input_cycle
		
		invoke crt_printf, addr rrFormat, [buffer_key_1 + 14d]
		
		jmp @start_input_cycle
    @end_input_cycle:
		invoke crt_printf, addr endInputFormat
		invoke crt_printf, addr resultInputFormat, tempNumber
    
	invoke ReadConsoleA, stdin, addr input_buffer, 8, addr bytesRead, 0
	invoke ExitProcess, 0
end start
