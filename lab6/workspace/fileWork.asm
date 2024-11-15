.386 
.model flat,stdcall 
option casemap:none 
include includes\windows.inc
include includes\user32.inc
include includes\kernel32.inc
include includes\msvcrt.inc
includelib includes\user32.lib
includelib includes\kernel32.lib
includelib includes\msvcrt.lib

.data
    fileHandler dd ?        ; для хранения дескриптора файла
    numberOfBytesRead db ?  ; для хранения количества прочитанных байтов
    numberOfBytesWritten db ?  ; для хранения количества записанных байтов
    fileSizeHigh dd ?       ; для хранения размера файла
    buffer db 256 dup(0)    ; Буфер для хранения прочитанных данных
    
    temp db ?
    
    inFilePath db "C:\Users\UserLog.ru\Desktop\in.txt", 0
    outFilePath db "C:\Users\UserLog.ru\Desktop\out.txt", 0
    
	numFormat db "%d", 10, 0
	charFormat db "%c", 10, 0
	combFormat db "%d, %d: %c", 10, 0
.code 
start: 
    ; Чтение файла in.txt
    invoke CreateFileA, offset inFilePath, GENERIC_READ, 0, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandler, eax   ; сохраняем дескриптор открытого файла
    invoke SetFilePointer, fileHandler, 0, 0, FILE_BEGIN
    invoke ReadFile, fileHandler, addr buffer, sizeof buffer - 1, addr numberOfBytesRead, 0
    invoke CloseHandle, fileHandler    ; Закрывает дескриптор файла.
    
    mov buffer[1], 'G'

    ; Запись в файл out.txt
    invoke CreateFileA, offset outFilePath, GENERIC_WRITE, 0, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0 
    mov fileHandler, eax
    invoke SetFilePointer, fileHandler, 0, 0, FILE_BEGIN
    invoke WriteFile, fileHandler, addr buffer, sizeof buffer, addr numberOfBytesWritten, 0  
    invoke CloseHandle, fileHandler
    
    mov al, [buffer + 0]
    invoke crt_printf, addr numFormat, al
    
    mov al, [buffer + 0]
    invoke crt_printf, addr charFormat, al
    
    mov al, [buffer + 0]
    invoke crt_printf, addr numFormat, 'g'
    
    mov al, [buffer + 1]
    invoke crt_printf, addr numFormat, al
    
    mov esi, offset buffer
    mov al, [esi]
    invoke crt_printf, addr charFormat, al
    
    cmp [buffer + 0], 'g'
    je Yes
    invoke crt_printf, addr numFormat, 0
    Yes:
    	invoke crt_printf, addr numFormat, 1
    
    ;   mov bl, numberOfBytesRead; в cx помещаем кол-во повторений
    ;   mov esi, offset buffer
	;   FORLOOP:
	;   	invoke crt_printf, addr combFormat, bl, 0, 0
	;   	mov al, [esi]
	;   	invoke crt_printf, addr numFormat, al
	;   	mov al, [esi]
	;   	invoke crt_printf, addr charFormat, al
	;   	inc esi
	;   	dec bl
	;   	cmp bl, 0
	;   jne FORLOOP
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0
	
    invoke ExitProcess, 0 
end start
