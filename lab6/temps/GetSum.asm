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
	charFormat db "%c", 10, 0
	strFormat db "%s", 10, 0
	newlineFormat db " ", 10, 0

    inputValue db 1, 0, 2, 5, 0

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

start:
    invoke GetSum, addr inputValue, sizeof inputValue
    invoke crt_printf, addr numFormat, eax
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0

end start
