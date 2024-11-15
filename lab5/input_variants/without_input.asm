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
	buffer db 3 dup(0) ; Массив для хранения 3 чисел
    bytesRead db 0
    consoleHandle dd 0
    
    num1 db 10011001b
    num2 db 01101010b
    num3 db 11100100b
    resultFormat db "Result: %d", 10, 0
    
    input_buffer db 8 dup(0)

.code
InputDecimalNumber PROC stdin:DWORD, bufferAdress:DWORD, bsize:DWORD, cdkeyAdress: DWORD, num: ; функция для вычисления модуля, результат в eax
    mov eax, inputValue
    cmp eax, 0
    ; если value >= 0, то не меняем знак
    jge withoutChangeSign
    neg eax               
    withoutChangeSign:
    ret
InputDecimalNumber ENDP

start:
	; Считываем числа
	invoke GetStdHandle, STD_INPUT_HANDLE
    invoke ReadConsoleA, eax, addr buffer, 3, addr bytesRead, 0
    
    ; Извлечение старшей части num1
    mov al, num1
    shr al, 4
    mov dl, al          
    ; Извлечение младшей части num3
    mov al, num3      
    and al, 0Fh       
    ; Логическое сложение старшей части num1 и младшей num3, результат в dl
    or dl, al

    ; Извлечение младшей части num1
    mov al, num1
    and al, 0Fh   
    ; Извлечение младшей части num2
    mov bl, num2   
    and bl, 0Fh   
    ; Логическое умножение младшей части num1 и младшей части num2, результат в al
    and al, bl

    ; Делим результат на 4
    shr dl, 2        
    shr al, 2       

    invoke crt_printf, offset resultFormat, dl
    invoke crt_printf, offset resultFormat, al

    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, addr input_buffer, 7, addr bytesRead, 0

    invoke ExitProcess, 0
end start