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

BSIZE equ 256

.DATA
	countNumbers dd 3
	numbers db 3 dup(0)
	currentNumberIndex dd 0
	
	startInputFormat db "Enter a number (<256): ", 0
	endInputFormat db " ", 10, 0
	resultInputFormat db "Input result (number %d): %d", 10, 0
	numericCharFormat db "%d", 0
	testFormat db "Test %d", 10, 0

    stdin dd ?

    buffer_key db BSIZE dup(0)
    cdkey dd ?
    
    inputBuffer db 8 dup(0)
    bytesRead db 0
.CODE
start:
	; дескриптор консоли ввода  сохраняем в переменную
	invoke GetStdHandle, STD_INPUT_HANDLE
    mov stdin, eax
    
    @inputNumbers:
    	invoke crt_printf, addr startInputFormat
    	jmp @startInputCycle	; ввод очередного числа
		
		@continueInput:

			inc currentNumberIndex
			mov eax, countNumbers
			cmp currentNumberIndex, eax	; если все 3 числа введены
			je @calculate	; переход к расчёту выражения

			jmp @inputNumbers

    @startInputCycle:
		;invoke crt_printf, addr startMsg
		invoke ReadConsoleInput, stdin, addr buffer_key, BSIZE, addr cdkey; 
		invoke ReadConsoleInput, stdin, addr buffer_key, BSIZE, addr cdkey;
 
		; Проверка Enter 
		cmp [buffer_key + 14d], VK_RETURN
		je @endInputCycle
    
		; Проверка на наличие кода символа 
		cmp [buffer_key + 14d], 0
		je @startInputCycle
    
		; Проверка принадлежности введенного кода заданному диапазону
		cmp [buffer_key + 14d], 30h
		jb @startInputCycle
		cmp [buffer_key + 14d], 39h
		ja @startInputCycle
	
		; Формирование числа (сборка числа из цифр)
		mov ecx, currentNumberIndex
		mov al, [numbers + ecx]
		; Увеличение порядка
		mov bl, 10d
		mul bl
		; Добавление введённого числа
		mov dl, [buffer_key + 14d]
		sub dl, 30h
		add al, dl
		; Сохранение
		mov ecx, currentNumberIndex
		mov [numbers + ecx], al
		
		; Вывод на экран введённого числа
		invoke crt_printf, addr numericCharFormat, dl
		
		jmp @startInputCycle
	@endInputCycle:
		invoke crt_printf, addr endInputFormat
		mov eax, currentNumberIndex
		mov ebx, currentNumberIndex
		inc ebx
		invoke crt_printf, addr resultInputFormat, ebx, [numbers + eax]
		jmp @continueInput
    
    @calculate:    	
    	; Извлечение старшей части num1
		mov al, [numbers + 0]
		shr al, 4
		mov dl, al          
		; Извлечение младшей части num3
		mov al, [numbers + 2]      
		and al, 0Fh       
		; Логическое сложение старшей части num1 и младшей num3, результат в dl
		or dl, al

		; Извлечение младшей части num1
		mov al, [numbers + 0]
		and al, 0Fh   
		; Извлечение младшей части num2
		mov bl, [numbers + 1]   
		and bl, 0Fh   
		; Логическое умножение младшей части num1 и младшей части num2, результат в al
		and al, bl

		; Делим результат на 4
		shr dl, 2        
		shr al, 2      
 
	; Вызов функции для ввода, чтобы консоль не закрывалась сразу после выполнения
	invoke ReadConsoleA, stdin, addr inputBuffer, BSIZE, addr cdkey, 0
	
    invoke ExitProcess, 0
end start
