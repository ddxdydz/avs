#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#define MAX_REPLACEMENTS 10
#define MAX_STRING_LENGTH 256

int main() {
    int n;
    char a[MAX_REPLACEMENTS], b[MAX_REPLACEMENTS];
    char S[MAX_STRING_LENGTH];
    int pipefd[2];

    // Создание канала
    if (pipe(pipefd) == -1) {
        printf("Ошибка при создании канала.\n");
        return 1;
    }

    // Ввод количества замен
    printf("Введите количество замен n: ");
    if (scanf("%d", &n) != 1 || n <= 0 || n > MAX_REPLACEMENTS) {
        printf("Некорректный ввод количества замен.\n");
        return 1;
    }

    // Ввод пар символов
    for (int i = 0; i < n; i++) {
        printf("Введите пару символов для замены %d через пробел: ", i + 1);
        if (scanf(" %c %c", &a[i], &b[i]) != 2) {
            printf("Некорректный ввод пары символов.\n");
            return 1;
        }
        printf("Введённые символы для замены %d: (%c, %c).\n", i + 1, a[i], b[i]);
    }

    // Ввод строки
    printf("Введите строку S для преобразования: ");
    scanf(" %[^\n]", S); // Используем %[^\n] для чтения строки с пробелами


    // Создание дочерних процессов для выполнения замен
    for (int i = 0; i < n; ++i) {
        pid_t pid = fork();

        if (pid < 0) {
            printf("Ошибка fork.\n");
            return 1;
        }

        if (pid == 0) { // Дочерний процесс
            // Получение индексов замены
            int count = 0;
            int indexes[MAX_STRING_LENGTH];

            // Нахождение индексов для замены
            for (int j = 0; S[j] != '\0'; ++j) {
                if (S[j] == a[i]) {
                    indexes[count++] = j;
                }
            }

            // Запись в канал
            write(pipefd[1], &b[i], sizeof(char));
            write(pipefd[1], &count, sizeof(int));
            write(pipefd[1], indexes, count * sizeof(int));

            close(pipefd[1]); // Закрыть запись в канале
            exit(0);
        }
    }

    // Закрытие канала для записи в родительском процессе
    close(pipefd[1]);

    // Обработка полученных данных из канала
    char result[MAX_STRING_LENGTH];
    strcpy(result, S);
    for (int i = 0; i < n; ++i) {
        // Получение данных из канала
        char replace_char;
        int count;
        read(pipefd[0], &replace_char, sizeof(char));
        read(pipefd[0], &count, sizeof(int));
        
        int indexes[MAX_REPLACEMENTS];
        read(pipefd[0], indexes, count * sizeof(int));

        // Выполнение замены в результирующей строке
        for (int j = 0; j < count; ++j) {
            result[indexes[j]] = replace_char;
        }
    }

    close(pipefd[0]); // Закрыть чтение из канала

    // Ожидание завершения дочерних процессов
    while(wait(NULL) > 0);

    // Вывод результата
    printf("Преобразованная строка: %s\n", result);

    return 0;
}