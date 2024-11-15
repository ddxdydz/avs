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
    valueFormat BYTE "Value: %d ", 0
    newValueFormat BYTE "New Value: %d ", 0
    
    input_buffer db 8 dup(0)
    bytesRead dd ?

.code
GetAbs PROC inputValue:DWORD	; функция для вычисления модуля, результат в eax
    mov eax, inputValue
    cmp eax, 0
    ; если value >= 0 для чисел без знака, то не меняем знак
    jge withoutChangeSign
    neg eax               
    withoutChangeSign:
    ret
GetAbs ENDP

start:
	
	invoke crt_printf, addr valueFormat, 4
    invoke GetAbs, 4
    invoke crt_printf, addr newValueFormat, eax
    
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, addr input_buffer, 7, addr bytesRead, 0

    invoke ExitProcess, 0

end start
