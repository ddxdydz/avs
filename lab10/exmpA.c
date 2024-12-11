#include <stdio.h>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/wait.h>

// массив, сумма элементов которого вычисляется процессами
int A[100];

struct mymem
// структура, под которую будет выделена разделяемая память
{
    int sum; // для записи суммы
} *mem_sum;

int main()
{
    // запрос на создание разделяемой памяти объемом 2 байта
    // с правами чтения и записи для всех
    int shmid = shmget(IPC_PRIVATE, 2, IPC_CREAT | 0666);
    // если запрос оказался неудачным, завершить выполнение
    if (shmid < 0) {fprintf(stdout, "\nОшибка"); return 0;}
    // теперь mem_sum указывает на выделенную разделяемую память
    mem_sum = (struct mymem *)shmat(shmid, NULL, 0);
    // инициализация элементов массива А
    for (int i = 0; i < 100; i++) A[i] = i;
    
    int pid, sum = 0;
    pid = fork();
    if (pid == 0) // дочерний процесс
    {
        for (int i = 0; i < 50; i++)
            sum += A[i];
        // вычислить сумму
        mem_sum->sum = sum;
        // записать ее в общую память
    }
    if (pid != 0) // родительский процесс
    {
        for (int i = 50; i < 100; i++)
            sum += A[i];
        // вычислить сумму
        wait(NULL);
        // дождаться завершения процесса-потомка
        // вывести на экран сумму всех элементов массива
        fprintf(stdout, "\nРезультат =  %d", sum + mem_sum->sum);
    }
    // удалить разделяемую память
    shmctl(shmid, IPC_RMID, NULL);
    return 1;
}