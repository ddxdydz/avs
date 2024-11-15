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
	num1 dd 3
	addrnum1 dd ?
	testFormat db "Test(%d)", 10, 0
	
	inputBuffer dd 8 dup(0)

    stdin dd ?
.code
start:
	invoke GetStdHandle, STD_INPUT_HANDLE
    mov stdin, eax
	
	invoke crt_printf, addr testFormat, offset num1
	mov ebx, offset num1  ; 4210688
	mov eax, [ebx]	; 3
	mov eax, ebx	; 4210688
	invoke crt_printf, addr testFormat, eax
	
	; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
	invoke ReadConsoleA, stdin, addr inputBuffer, 8, 0, 0
	
    invoke ExitProcess, 0
end start
