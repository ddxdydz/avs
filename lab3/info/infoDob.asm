invoke SetConsoleOutputCP, CP_UTF8  ; Устанавливаем кодировку вывода в UTF-8

; Подготовка к делению
    mov eax, dividend      ; Переносим делимое в EAX
    xor edx, edx          ; Обнуляем EDX перед делением (остаток)
; Выполняем деление    (делит содержимое в eax, результат в eax, остаток в edx)
    div divisor    


SIZEOF подменяется в исполняемом коде длиной (в байтах) символьной строки.
(SIZEOF msg2) - 1, ; уменьшаем размер строки msg2 на 1 (из-за нуля)