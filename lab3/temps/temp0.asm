; Новый проект masm32 успешно создан
; Заполнен демо программой «Здравствуй, мир!»
.386
.model flat, stdcall
option casemap :none
include includes\masm32.inc
include includes\kernel32.inc
include includes\macros\macros.asm
includelib includes\masm32.lib
includelib includes\kernel32.lib
.code
start:
	print "Hello, world!"
	exit
end start
