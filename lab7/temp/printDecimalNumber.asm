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
	testNumber dd 423
    stdout dd ?
    numFormat db "%d", 10, 0
    outputBuffer db BSIZE dup(0)
 
.code
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

; Печать массива чисел в одну строку
PrintArrayOfBytes PROC lpArray:DWORD, arraySize:DWORD
	push esi
	push ecx
	
	mov esi, lpArray
	mov ecx, 0
	FORLOOP:
		
		push ecx
		movzx eax, byte ptr [esi]
		invoke crt_printf, addr numFormat, eax
		pop ecx
		
		inc ecx
		inc esi
		cmp ecx, arraySize
		jne FORLOOP
	
	pop ecx
	pop esi
	ret
PrintArrayOfBytes ENDP

start:
    invoke GetStdHandle, STD_OUTPUT_HANDLE; дескриптор консоли вывода 
    mov stdout, eax

    invoke PrintNumber, testNumber, 2
    ;invoke PrintArrayOfBytes, offset outputBuffer, BSIZE
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0
end start
