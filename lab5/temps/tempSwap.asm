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
    input BYTE 10100100b

    valueFormat db "Value: %d ", 0
    numericCharFormat db "%d", 0
	newLineFormat db " ", 10, 0
    
    input_buffer db 8 dup(0)
    bytesRead dd ?

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

; функция, меняющая местами разряды в числе, результат в al
; digit1, digit2 - номера разрядов с 1 до 8, где 1 - младший, 8 - старший
Swap PROC inputValue:BYTE, digit1:BYTE, digit2:BYTE

    ; Если digit1 > digit2, то меняем их местами,
    ; Для правильности дальнейших вычислений
    mov al, digit2
    cmp digit1, al
    jb d1_less_d2
    mov al, digit2
    mov bl, digit1
    mov digit2, bl
    mov digit1, al
    d1_less_d2:
        
    ; Маска 1 в al
    mov al, 1
    mov cl, digit1
    sub cl, 1
    shl al, cl        

    ; Маска 2 в bl
    mov bl, 1
    mov cl, digit2
    sub cl, 1
    shl bl, cl

    ; Расстояние между разрядами в cl
    mov cl, digit2
    sub cl, digit1
        
    ; Сохраняем 1 разряд в al 
    ; и удаляем его из inputValue
    mov dl, inputValue
    and dl, al
    not al
    and inputValue, al
    mov al, dl

    ; Сохраняем 2 разряд в bl 
    ; и удаляем его из inputValue
    mov dl, inputValue
    and dl, bl
    not bl
    and inputValue, bl  ; удаление
    mov bl, dl   ; сохранение

    ; Передвигаем разряды на нужные места и возвращаем в inputValue
    shl al, cl
    shr bl, cl
    add inputValue, al
    add inputValue, bl
	
	mov al, inputValue	; сохраняем результат в al
	
    ret
Swap ENDP

start:
	
	invoke printBinary, input
    invoke Swap, input, 8, 1
    invoke printBinary, al
    
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, addr input_buffer, 7, addr bytesRead, 0

    invoke ExitProcess, 0

end start
