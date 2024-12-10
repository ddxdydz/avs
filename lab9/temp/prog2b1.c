#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/wait.h>

#define BUFFER_SIZE 256
#define PIPE_NAME "pipe2b"

int main() {
    int size;
    int *arrayA;
    int fd;    

    // Ввод размерности массива
    printf("Введите размерность массива A: ");
    if (scanf("%d", &size, stdin) != 1 || size <= 0) {
        printf("Ошибка ввода. Размерность должна быть положительным целым числом.\n");
        return 1;
    }

    // Ввод элементов массива A
    arrayA = (int*)malloc(size * sizeof(int));
    for (int i = 0; i < size; i++) {
        printf("Введите элемент №%d массива A: ", i + 1);
        if (scanf("%d", &arrayA[i], stdin) != 1) {
            printf("Ошибка ввода.\n");
            return 1;
        }
    }

    mkfifo(PIPE_NAME, S_IFIFO | 0666); // создать канал

    // Передача размерности и элементов массива A
    fd = open(PIPE_NAME, O_WRONLY);    // получить дескриптор для записи
    write(fd, &size, sizeof(int));
    write(fd, arrayA, size * sizeof(int));
    close(fd);
    
    return 1;
}
