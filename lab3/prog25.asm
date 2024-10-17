.386
.MODEL flat, stdcall
option casemap :none
include includes\windows.inc
include includes\kernel32.inc
include includes\user32.inc
include includes\masm32.inc
includelib includes\kernel32.lib
includelib includes\user32.lib
includelib includes\masm32.lib

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
    result DWORD ?
    resultFormat db "Result: %d", 10, 0  

    input_buffer db BSIZE dup(0)
    output_buffer db BSIZE dup(0)

    bytesRead dd ?
    bytesWritten dd ?

    stdin dd ?
    stdout dd ?

.code
start:
    ; Получение дескриптора стандартного ввода
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov stdin, eax
    ; Получение дескриптора стандартного вывода
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov stdout, eax
 
    ; Чтение из стандартного ввода
    invoke ReadConsoleA, stdin, addr input_buffer, BSIZE, addr bytesRead, 0
    ; Вывод полученного выражения на экран
    invoke WriteConsoleA, stdout, addr input_buffer, bytesRead, addr bytesWritten, 0

    ; Вычисление выражения по частям: (a + b or c) + (d + e and f) or g + h and (k + m)
    mov eax, varA
    add eax, varB
    or eax, varC		; (a + b or c)

    mov ebx, varD
    add ebx, varE
    and ebx, varF		; (d + e and f)

    add eax, ebx		; (a + b or c) + (d + e and f)
    
    mov ebx, varG
    add ebx, varH		; g + h

    or eax, ebx			; (a + b or c) + (d + e and f) or g + h

    mov ebx, varK
    add ebx, varM		; k + m

    and eax, ebx		; (a + b or c) + (d + e and f) or g + h and k + m

    ; Сохранение результата
    mov result, eax

    ; Подготовка для вывода результата
    invoke wsprintf, addr output_buffer, addr resultFormat, result
    ; Вывод результата
    invoke WriteConsoleA, stdout, addr output_buffer, BSIZE, addr bytesWritten, 0
    
    invoke ReadConsoleA, stdin, addr input_buffer, BSIZE, addr bytesRead, 0

    ; Завершение программы
    invoke ExitProcess, 0

end start
