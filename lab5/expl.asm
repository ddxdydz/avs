.386
.model flat, stdcall
option casemap :none
include includes\masm32.inc
include includes\kernel32.inc
include includes\macros\macros.asm
includelib includes\masm32.lib
includelib includes\kernel32.lib
.data
	a db 10110101b
	b db 00110111b
	cc db 0
.code
start:
	not a; инвертируем первое число 									01001010	4A
	shr a,2; делим его на 4 											00010010	12
	shl b,1; второе число умножаем на 2 								01101110	6E
	mov eax, a; полученные результаты складываем 
	add al, b; для сложения необходим регистр al
	xor al, 00001111b ; меняем первые 4 разряда на противоположные
	mov cc, al; результат сохраняет в cc
	invoke ExitProcess, 0
end start
