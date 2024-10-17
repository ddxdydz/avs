.386
.model flat, stdcall	
option casemap :none	
include includes\user32.inc
include includes\kernel32.inc
includelib includes\user32.lib
includelib includes\kernel32.lib

BSIZE equ 15

.data
ifmt db "%d", 0; строка формата
buf db BSIZE dup(?); буфер
msg dd 123456; то что мы выводим
stdout dd ?
cWritten dd ?

.code
start:
	invoke GetStdHandle, -11 ; запрос дескриптора вывода. 
	; Результат запроса 
	; помещается в регистр eax
	mov ebp, offset msg
	mov esi, 0
	mov ebx,[ebp][esi]
	mov stdout,eax ; значение дескриптора из eax
	; помещается в stdout
	invoke wsprintf, ADDR buf, ADDR ifmt, msg
	invoke WriteConsoleA, stdout, ADDR buf, BSIZE, 
	ADDR cWritten, 0
	invoke ExitProcess,0
end start
