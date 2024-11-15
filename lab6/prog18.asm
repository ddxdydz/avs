include masm32includemasm32.inc
include masm32includekernel32.inc
include masm32includemsvcrt.inc
includelib masm32libkernel32.lib
includelib masm32libmsvcrt.lib

.data
    buffer db "Пример текста для сортировки слов", 0
    output db "Отсортированные слова: ", 0
    words db 10 dup(256 dup(0)) ; Массив для хранения слов (10 слов, максимум 256 символов каждое)
.code
start:
    ; Разделение строки на слова
    invoke SplitWords, addr buffer, addr words

    ; Сортировка слов по количеству уникальных согласных
    invoke SortWords, addr words

    ; Вывод результата
    invoke StdOut, addr output
    invoke PrintSortedWords, addr words

    ; Завершение программы
    invoke ExitProcess, 0

; Процедура для разделения строки на слова
SplitWords proc str:DWORD, words:DWORD
    local word:DWORD
    local count:DWORD
    mov count, 0

    ; Указатель на начало строки
    mov eax, str

next_word:
    ; Пропускаем пробелы
    while byte ptr [eax] == ' '
        inc eax
    endwhile

    ; Если достигли конца строки, выходим
    cmp byte ptr [eax], 0
    je done

    ; Сохранение адреса текущего слова
    mov word, eax

    ; Копируем слово в массив words
    lea edi, [words + count * 256]
    
copy_word:
    ; Копируем символы слова
    mov al, [eax]
    cmp al, ' '
    je end_copy_word
    mov [edi], al
    inc edi
    inc eax
    jmp copy_word

end_copy_word:
    mov byte ptr [edi], 0 ; Завершаем строку нулем
    inc count              ; Увеличиваем счетчик слов
    jmp next_word         ; Переход к следующему слову

done:
    mov dword ptr [words + count * 256], 0 ; Завершаем массив слов нулем
    ret
SplitWords endp

; Процедура для подсчета уникальных согласных букв в слове
CountUniqueConsonants proc word:DWORD
    local consonants:DWORD
    local unique_count:DWORD
    mov consonants, 0
    mov unique_count, 0

    ; Массив для хранения согласных (используем битовую маску)
    local mask db 0 ; Битовая маска для согласных (26 бит для каждой буквы)

next_char:
    mov al, [word]
    cmp al, 0
    je done_count

    ; Проверяем, является ли буква согласной (например, в русском языке)
    cmp al, 'А'
    jb skip_char
    cmp al, 'Я'
    ja skip_char
    
    ; Если это согласная буква (например, Б, В, Г и т.д.)
    ; Можно использовать более сложную проверку для русского алфавита

skip_char:
    inc word
    jmp next_char

done_count:
    ret
CountUniqueConsonants endp

; Процедура для сортировки слов (пузырьковая сортировка)
SortWords proc words:DWORD
    local i:DWORD, j:DWORD, temp:DWORD

outer_loop:
    mov i, 0

inner_loop:
    mov eax, [words + i * 256]
    mov ebx, [words + (i + 1) * 256]

    ; Подсчет уникальных согласных для каждого слова
    invoke CountUniqueConsonants, eax
    mov ecx, eax          ; Сохраняем количество уникальных согласных первого слова
    invoke CountUniqueConsonants, ebx
    cmp ecx, eax         ; Сравниваем с количеством второго слова

    jg swap_words         ; Если первое слово больше - меняем местами

skip_swap:
    inc i                 ; Переходим к следующему слову
    cmp byte ptr [words + (i + 1) * 256], 0 ; Проверка на конец массива слов
    jne inner_loop        ; Если не конец - продолжаем внутренний цикл

outer_end:
    ret

swap_words:
    ; Меняем местами слова в массиве words
    mov temp, [words + i * 256]
    mov [words + i * 256], [words + (i + 1) * 256]
    mov [words + (i + 1) * 256], temp
    
    jmp skip_swap         ; Возвращаемся к пропуску обмена

SortWords endp

; Процедура для вывода отсортированных слов
PrintSortedWords proc words:DWORD
    local word:DWORD

print_loop:
    mov eax, [words]
    cmp eax, 0            ; Проверка на конец массива слов
    je done_printing
    
    invoke StdOut, eax   ; Выводим слово на экран
    
done_printing:
    ret
PrintSortedWords endp

end start
