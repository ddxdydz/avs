#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>

#define FIFO_NAME "fifo_12b"
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
    mkfifo(FIFO_NAME, S_IFIFO | 0666);

    srand(time(NULL));

    int fd_write;
    int fd_read;
    int triple[TRIPLE_SIZE];
    int received_triple[TRIPLE_SIZE];

    while (1) {
        fd_read = open(FIFO_NAME, O_RDONLY);
        read(fd_read, received_triple, sizeof(received_triple));
        printf("Parent received: %d %d %d\n", received_triple[0], received_triple[1], received_triple[2]);
        close(fd_read);

        fd_write = open(FIFO_NAME, O_WRONLY);
        generate_random_triple(triple);
        write(fd_write, triple, sizeof(triple));
        printf("Parent sent: %d %d %d\n", triple[0], triple[1], triple[2]);
        close(fd_write);

        if (compare_triples(triple, received_triple)) {
            printf("Parent: Found matching triples.\n");
            break;
        }
    }
    
    unlink(FIFO_NAME);

    return 0;
}
