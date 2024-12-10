#include <stdio.h>
#include <unistd.h>



int main()
{
    char s[15];       // для передачи и получения данных
    int fd[2];        // для получения дескрипторов канала
    if (pipe(fd) < 0)
    {
        fprintf(stdout, "\nОшибка создания канала");
        return 0;
    }






    if (fork() == 0)
    {                                            
        int r = sprintf(s, "MyPid=%d", getpid());
        write(fd[1], &s, r);
        return 1;
    }






    read(fd[0], &s, 15);
    fprintf(stdout, "\nParent read - '%s'", s);

    close(fd[0]);
    close(fd[1]); // закрыть дескрипторы канала



    return 1;
}
