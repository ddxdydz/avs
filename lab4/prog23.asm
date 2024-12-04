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
    varA dd 3
    varX dd -15
    y1 dd ?
    y2 dd ?
    result dd ?
    resultFormat db "x=%d: y1=%d, y2=%d, y1 + y2 = %d (0x%X)   ", 10, 0
    input_buffer db 8 dup(0)
    bytesRead dd ?

.code
GetAbs PROC inputValue:DWORD  ; функция для вычисления модуля, результат в eax
    mov eax, inputValue
    cmp eax, 0
    ; если value >= 0, то не меняем знак
    jge withoutChangeSign
    neg eax               
    withoutChangeSign:
    ret
GetAbs ENDP

start:
	forX:
		jmp calculateY
		doneCalculationY:
			invoke crt_printf, addr resultFormat, varX, y1, y2, result, result
		inc varX
		cmp varX, 16
	jne forX
	jmp endCalculation

	calculateY:
		jmp calculateY1
		doneCalculationY1:
			jmp calculateY2
		doneCalculationY2:
			; y = y1 + y2
			mov eax, y1
			add eax, y2
			mov result, eax
			jmp doneCalculationY

	calculateY1:
		invoke GetAbs, varX
		cmp eax, 4
		ja case1Y1  ; |x| > 4
		jmp case2Y1

	case1Y1:
		mov eax, varX
		imul eax, 2
		mov y1, eax
		jmp doneCalculationY1

	case2Y1:
		mov eax, varA
		add eax, 4
		mov y1, eax
		jmp doneCalculationY1

	calculateY2:
		mov eax, varX
		cmp eax, 0
		je case1Y2	; x == 0
		jmp case2Y2

	case1Y2:
		mov y2, 9
		jmp doneCalculationY2

	case2Y2:
		mov eax, varA
		xor edx, edx
		div varX
		mov y2, eax
		jmp doneCalculationY2

	endCalculation:
		invoke GetStdHandle, STD_INPUT_HANDLE
		invoke ReadConsoleA, eax, addr input_buffer, 7, addr bytesRead, 0

	invoke ExitProcess, 0
end start
