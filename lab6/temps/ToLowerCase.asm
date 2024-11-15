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

    inputValue db 50
    inputValue1 db 'b'
    inputValue2 db 'G'
    inputValue3 db 'g'
    inputValue4 db 'Z'
    inputValue5 db 'z'
    inputValue6 db 'A'
    inputValue7 db 'a'
    inputValue8 db '}'

.code
; Процедура для получения кода символа в нижнем регистре, результат в eax
ToLowerCase PROC char:BYTE	
    mov al, char

    ; Проверка, что символ в верхнем регистре:
    cmp char, 'A'
    jb ToEnd
    cmp char, 'Z'
    ja ToEnd

    add al, 32  ; в нижний регистр
    
    ToEnd:
    ret
ToLowerCase ENDP

start:
	
	invoke crt_printf, addr charFormat, inputValue
    invoke ToLowerCase, inputValue
    invoke crt_printf, addr charFormat, al
    invoke crt_printf, addr newlineFormat
	
	invoke crt_printf, addr charFormat, inputValue1
    invoke ToLowerCase, inputValue1
    invoke crt_printf, addr charFormat, al
    invoke crt_printf, addr newlineFormat
	
	invoke crt_printf, addr charFormat, inputValue2
    invoke ToLowerCase, inputValue2
    invoke crt_printf, addr charFormat, al
    invoke crt_printf, addr newlineFormat
	
	invoke crt_printf, addr charFormat, inputValue3
    invoke ToLowerCase, inputValue3
    invoke crt_printf, addr charFormat, al
    invoke crt_printf, addr newlineFormat
	
	invoke crt_printf, addr charFormat, inputValue4
    invoke ToLowerCase, inputValue4
    invoke crt_printf, addr charFormat, al
    invoke crt_printf, addr newlineFormat
	
	invoke crt_printf, addr charFormat, inputValue5
    invoke ToLowerCase, inputValue5
    invoke crt_printf, addr charFormat, al
    invoke crt_printf, addr newlineFormat
	
	invoke crt_printf, addr charFormat, inputValue6
    invoke ToLowerCase, inputValue6
    invoke crt_printf, addr charFormat, al
    invoke crt_printf, addr newlineFormat
	
	invoke crt_printf, addr charFormat, inputValue7
    invoke ToLowerCase, inputValue7
    invoke crt_printf, addr charFormat, al
    invoke crt_printf, addr newlineFormat
	
	invoke crt_printf, addr charFormat, inputValue8
    invoke ToLowerCase, inputValue8
    invoke crt_printf, addr charFormat, al
    invoke crt_printf, addr newlineFormat
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0

    invoke ExitProcess, 0

end start
