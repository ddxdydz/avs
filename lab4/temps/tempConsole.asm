.386
.model flat,stdcall
option casemap:none
include includes\user32.inc
includelib includes\user32.lib
include includes\kernel32.inc
includelib includes\kernel32.lib
include includes\msvcrt.inc
includelib includes\msvcrt.lib
.data
 printForm db "%d",0
.data?
 num dword ?
.code
start:
    invoke crt_printf, offset printForm, num
end start
