#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>


int main()
{
    char s[15];       
    int fd;           

    fd = open("mypipe", O_WRONLY);    // получить дескриптор для записи
    sprintf(s, "MyPid=%d", getpid()); // записать свой pid в s
    write(fd, &s, 15);                // записать s в канал

    close(fd);                        // закрыть дескриптор
    return 1;
}