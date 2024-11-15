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
	inLineNumsFormat db "%d, ", 0

    inputValue db 1, 0, 2, 5, 0

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
start:
	
    invoke PrintArrayOfBytes, addr inputValue, sizeof inputValue
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0

end start
