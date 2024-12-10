#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>

int main()
{
    char s[15];      // для передачи и получения данных
    int fd[2];       // для получения дескрипторов канала
    if (mkfifo("mypipe", S_IFIFO | 0666) < 0)
    {
        fprintf(stdout, "\nОшибка создания канала");
        return 0;
    }
    
    // если не указать флаг O_NONBLOCK, процесс заблокирует сам себя
    // получение дескрипторов для чтения/записи
    fd[0] = open("mypipe", O_RDONLY | O_NONBLOCK); 
    fd[1] = open("mypipe", O_WRONLY); 

    if (fork() == 0)
    {                                             
        int r = sprintf(s, "MyPid=%d", getpid()); 
        write(fd[1], &s, r);
        return 1;
    }

    wait(NULL);          /*ожидание дочернего процесса необходимо, так как
             функция чтения из канала стала не блокирующей, т.е. если
             дочерний процесс не успеет записать данные в канал,
             функция чтения не получит данных и завершиться*/

    read(fd[0], &s, 15);
    fprintf(stdout, "\nParent read - '%s'", s);

    close(fd[0]);
    close(fd[1]);     // закрыть дескрипторы канала

    unlink("mypipe"); // удалить канал

    return 1;
}
