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

.code

option prologue:PrologueDef
option epilogue:EpilogueDef
testProc PROC, val:BYTE 	
    push eax
    
    ; mov eax, 0
    ; mov eax, dword ptr val
    
    pop eax
    ret
testProc ENDP

start:
	mov eax, 8
	mov edx, 6
	
	invoke testProc, dl  ; если использовать edx, то норм

	invoke crt_printf, addr numFormat, eax
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0

end start
