#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

#define BUFFER_SIZE 256
#define PIPE_NAME "pipe21"

int main() {
    int size;
    int *arrayA, *arrayB;
    int fd;

    fd = open(PIPE_NAME, O_RDONLY);  // Открытие канала для чтения

    read(fd, &size, sizeof(int));  // Чтение размерности массива

    arrayA = (int*)malloc(size * sizeof(int));    
    arrayB = (int*)malloc(size * sizeof(int));

    read(fd, arrayA, size * sizeof(int));  // Чтение элементов массива A
    close(fd);

    // Ввод элементов массива B
    for (int i = 0; i < size; i++) {
        printf("Введите элемент №%d массива B: ", i + 1);
        if (scanf("%d", &arrayB[i], stdin) != 1) {
            printf("Ошибка ввода. Введите целые числа.\n");
            return 1;
        }
    }

    // Вычисление скалярного произведения
    int result = 0;
    for (int i = 0; i < size; i++) {
        result += arrayA[i] * arrayB[i];
    }
    printf("Скалярное произведение: %d\n", result);
    
    unlink("mypipe");

    return 0;
}
