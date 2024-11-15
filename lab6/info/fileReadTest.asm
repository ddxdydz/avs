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
    numberOfBytesRead db ?  ; для хранения количества записанных байтов
    fileSizeHigh dd ?       ; для хранения размера файла
    buffer db 256 dup(0)    ; Буфер для хранения прочитанных данных
    
    filePath db "C:\Users\UserLog.ru\Desktop\1234.txt", 0
    
	testFormat db "%s", 10, 0
.code 
start: 
    invoke CreateFileA, offset filePath, GENERIC_READ, 0, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0 
    ; создаёт файл с именем fname. Если файл уже существует, он открывается.
    ; 1: строка, содержащую имя файла: offset <имя_файла>
    ; 2: доступ, который требуется к файлу
    ;           GENERIC_READ — разрешение на чтение.
    ;           GENERIC_WRITE — разрешение на запись.
    ; 3: Определяет режим совместного доступа к файлу
    ;           0 — файл не может быть совместно использован.
    ;           FILE_SHARE_READ — разрешает другим процессам читать файл.
    ;           FILE_SHARE_WRITE — разрешает другим процессам записывать в файл.
    ; 4: безопасность создаваемого файла. Если NULL, файл получает стандартные атрибуты безопасности.
    ; 5: Определяет, как функция должна обрабатывать файл, если он уже существует. Возможные значения:
    ;           CREATE_NEW — создать новый файл; если файл существует, вызов завершится с ошибкой.
    ;           CREATE_ALWAYS — создать новый файл; если файл существует, он будет перезаписан.
    ;           OPEN_EXISTING — открыть существующий файл; вызов завершится с ошибкой, если файл не существует.
    ;           OPEN_ALWAYS — открыть файл, если он существует; в противном случае создать новый файл.
    ;           TRUNCATE_EXISTING — открыть существующий файл и усечь его до нуля; файл должен иметь разрешение на запись.
    ; 6: пределяет атрибуты и флаги для создаваемого файла. Например:
    ;           FILE_ATTRIBUTE_NORMAL — обычный файл.
    ;           Можно использовать дополнительные флаги, такие как FILE_FLAG_RANDOM_ACCESS, FILE_FLAG_SEQUENTIAL_SCAN и другие.
    ; 7: Дескриптор файла, Если NULL, то создаётся обычный файл.
    
    mov fileHandler, eax   ; Дескриптор открытого файла
    
    invoke GetFileSize, fileHandler, addr fileSizeHigh
    ; invoke GetFileSize, fileHandle, addr fileSizeHigh
    ; 1: Дескриптор
    ; 2: Указатель на переменную типа DWORD, которая будет содержать старшую часть размера файла.

    invoke SetFilePointer, fileHandler, 0, 0, FILE_BEGIN
    ; 1: Дескриптор
    ; 2: смещение, на которое нужно переместить указатель (может быть отриц)
    ; 3: если нужно работать с большими файлами, обычно 0
    ; 4: Метод, определяющий, откуда будет производиться смещение. Возможные значения:
    ;           FILE_BEGIN — смещение считается от начала файла.
    ;           FILE_CURRENT — смещение считается от текущей позиции указателя файла.
    ;           FILE_END — смещение считается от конца файла.
    
    invoke ReadFile, fileHandler, addr buffer, sizeof buffer - 1, addr numberOfBytesRead, 0
    ;  Записывает 2 байта из строки ab в файл по дескриптору d. Количество записанных байтов сохраняется в переменной o.
    ; 1: hFile Дескриптор
    ; 2: lpBuffer указатель на буфер с данными для записи
    ; 3: nNumberOfBytesToWrite, // количество байтов для записи
    ; 4: lpNumberOfBytesWritten, // указатель на переменную для сохранения фактически записанных байтов (может быть NULL)
    ; 5: lpOverlapped   // указатель на структуру OVERLAPPED (может быть NULL) для асинхронный ввод-вывод

    ; Вывод прочитанных данных на экран
    invoke SetConsoleOutputCP, CP_UTF8
    invoke crt_printf, addr testFormat, addr buffer

    invoke CloseHandle, fileHandler    ; Закрывает дескриптор файла.
    
    ; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
    invoke GetStdHandle, STD_INPUT_HANDLE
	invoke ReadConsoleA, eax, ebx, 8, 0, 0
	
    invoke ExitProcess, 0 
end start
