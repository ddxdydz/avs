if( a == b )
    c = d;
else
    b = b + 1;

mov a, eax
cmp eax, b
jne ElsePart
mov c, d
jmp EndOfIf
ElsePart:
    inc b;
EndOfIf:

mov a, eax
cmp eax, b
je IfPart
inc b
IfPart:
    mov c, d

; Цикл WHILE
A:
    cmp x, 0
    jle A2      ;op1 ≤ op2
    <тело цикла>
    jmp A
A2: …

; Цикл FOR
mov CX, n; в cx помещаем кол-во повторений
for:
    <тело цикла>
    ………………
    dec CX
    cmp CX, 0
jne for

; Цикл FOR с командой loop:
mov CX, n; в cx помещаем кол-во повторений
m:
    <тело цикла>
; cx уменьшается на 1 и, если он не равен 0, на метку m    
Loop m     