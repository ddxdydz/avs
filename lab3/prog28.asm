.386
.model flat, stdcall
option casemap :none 
include includes\masm32rt.inc ; Для crt_printf
include includes\macros\macros.asm
includelib includes\masm32.lib
includelib includes\kernel32.lib
;(a + b)/c + d/e + (f + gh)/k + m
;(a + b) and c + d and e + (d + g or h) and k + m
.data
	sDesc DB "(a + b) and c + d and e + (d + g or h) and k + m",0
	Result DD 0
	varA DD 1 ; 01
	varB DD 2 ; 10
	varC DD 3 ; 11
	varD DD 4 ; 100
	varE DD 5 ; 101
	varF DD 6 ; 110
	varG DD 7 ; 111
	varH DD 8 ; 1000
	varK DD 9 ; 1001
	varM DD 10 ; 1010
	otv1 db "%d",10,0
	otv2 db "%s",10,0
.code
solve PROC
	;(a + b) and c + d and e + (d + g or h) and k + m
	MOV EAX, varA
	ADD EAX, varB 
	MOV EBX, varC
	ADD EBX, varD 
	MOV ECX, varD
	ADD ECX, varG 
	OR ECX, varH 
	ADD ECX, varE
	AND EAX, EBX 
	AND EAX, ECX
	MOV EDX, varK
	ADD EDX, varM
	AND EAX, EDX
	MOV Result, EAX
	invoke crt_printf, addr otv2, addr sDesc
	invoke crt_printf, addr otv1, Result
	invoke ExitProcess, 0
solve ENDP
end solve
