#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

#define FIFO_NAME "fifo2b"

int main(int argc, char *argv[]) {
    int size = argc - 1;

    // Формирование массива B
    int *B = malloc(size * sizeof(int));
    for (int i = 0; i < size; i++) {
        B[i] = atoi(argv[i + 1]);
    }

    mkfifo(FIFO_NAME, S_IFIFO | 0666);
    int fd = open(FIFO_NAME, O_RDONLY);    

    // Формирование массива A
    int *A = malloc(size * sizeof(int));
    for (int i = 0; i < size; i++) {
        read(fd, &A[i], sizeof(int));
    }

    // Вывод сформированных массивов
    for (int i = 0; i < size; i++) {
        printf("A[%d] = %d\n", i, A[i]);
    }
    for (int i = 0; i < size; i++) {
        printf("B[%d] = %d\n", i, B[i]);
    }
    
    // Вычисление скалярного произведения
    int result = 0;
    for (int i = 0; i < size; i++) {
        result += A[i] * B[i];
    }
    printf("Скалярное произведение: %d\n", result);

    close(fd);
    unlink(FIFO_NAME);
    return 0;
}
