#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

#define FIFO_NAME "fifo2b"

int main(int argc, char *argv[]) {
    int size = argc - 1;
    int fd = open(FIFO_NAME, O_WRONLY); 

    // Отправляем элементы массива
    for (int i = 1; i < argc; i++) {
        int value = atoi(argv[i]);
        write(fd, &value, sizeof(value));
    }

    close(fd);
    return 0;
}

