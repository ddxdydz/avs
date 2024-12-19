#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>

#define FIFO_NAME "fifo12"
#define TRIPLE_SIZE 3
#define RAND_RANGE 4

void generate_random_triple(int triple[TRIPLE_SIZE]) {
    for (int i = 0; i < TRIPLE_SIZE; i++) {
        triple[i] = rand() % RAND_RANGE;
    }
}

int compare_triples(int triple1[TRIPLE_SIZE], int triple2[TRIPLE_SIZE]) {
    int count1[RAND_RANGE] = {0}, count2[RAND_RANGE] = {0};

    for (int i = 0; i < TRIPLE_SIZE; i++) {
        count1[triple1[i]]++;
        count2[triple2[i]]++;
    }

    return memcmp(count1, count2, sizeof(count1)) == 0;
}

int main() {
    // Открытие именованных каналов
    int fd_write = open(FIFO_NAME, O_WRONLY);
    int fd_read = open(FIFO_NAME, O_RDONLY);
    int triple[TRIPLE_SIZE];
    int received_triple[TRIPLE_SIZE];

    while (1) {
        generate_random_triple(triple);
        write(fd_write, triple, sizeof(triple));
        printf("Child sent: %d %d %d\n", triple[0], triple[1], triple[2]);

        read(fd_read, received_triple, sizeof(received_triple));
        printf("Child received: %d %d %d\n", received_triple[0], received_triple[1], received_triple[2]);

        if (compare_triples(triple, received_triple)) {
            printf("Child: Found matching triples!\n");
            break;
        }
    }

    close(fd_write);
    close(fd_read);

    return 0;
}
