#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>


int main()
{
    char s[15];  
    int fd;      

    mkfifo("mypipe", S_IFIFO | 0666); // создать канал
    fd = open("mypipe", O_RDONLY);    // получить дескриптор для чтения

    // ожидает поступления данных в канал и выводит их на экран.
    // прочитать данные из канала (здесь функция read - блокирующая) 
    read(fd, &s, 15);                 

    fprintf(stdout,"\nрПрочитано : '%s'",s); //вывести полученные данные на экран

    close(fd);    // закрыть дескриптор
    unlink("mypipe"); // уничтожить канал
    return 1;
}
