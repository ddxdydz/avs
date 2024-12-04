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

BSIZE equ 100

.data
    varA dd 1
    varB dd 2
    varC dd 3
    varD dd 4
    varE dd 5
    varF dd 6
    varG dd 7
    varH dd 8
    varK dd 9
    varM dd 10
    result dd 0
    resultFormat db "Result: %d", 13, 10, 0  

    input_buffer db BSIZE dup(?)
    output_buffer db BSIZE dup(?)

    bytesRead dd ?
    bytesWritten dd ?

    stdin dd ?
    stdout dd ?

.code
start:
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov stdin, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov stdout, eax

    ; Вычисление выражения по частям: (a + b or c) and (d or e + f) + g and (h + k or m)
    mov eax, varA
    add eax, varB
    or eax, varC		; (a + b or c)
	
    mov ebx, varF
    add ebx, varE
    or ebx, varD
    add ebx, varG		; (d or e + f) + g

    and eax, ebx		; (a + b or c) and (d or e + f) + g
    mov result, eax
    
    mov eax, varH
    add eax, varK
    or eax, varM		; (h + k or m)
    
    and result, eax		; (a + b or c) and (d or e + f) + g and (h + k or m)

	; Вывод результата
    invoke crt_printf, addr resultFormat, result
    
	; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke ReadConsoleA, stdin, addr input_buffer, BSIZE, addr bytesRead, 0

    ; Завершение программы
    invoke ExitProcess, 0

end start
