#include <stdio.h> 
#include <stdlib.h> 
#include <time.h> 
#include <sys/types.h> 
#include <sys/wait.h> 
#include <unistd.h>  
#include <signal.h>


int main() { 
    int a, b, c, d, e, f, h, k, m;
    double result = 0;
    int delay; 
    int process_number = 0;
    
    FILE *fp = fopen("data.txt", "r");
    if (!fp)
    {
        printf("Не удалось открыть файл.\n");
        return 1;
    }
    
    srand(time(NULL)); 
    
    while((fscanf(fp, "%d %d %d %d %d %d %d %d %d\n", &a, &b, &c, &d, &e, &f, &h, &k, &m))!=EOF) {
        delay = 1 + rand() % 4;  // Задержка от 1 до 4 секунд
        process_number++;
        if (fork() == 0) {
            sleep(delay);
            printf("Завершение процесса №%d с задержкой %d сек. ", process_number, delay);
            if (f == 0 || m == 0) {
                printf("OШИБКА: Деление на 0\n");
            } else {
                result = a * (b + c) + d + e / f + (h + k) / m;
                printf("Pезультат: %.2f\n", result);
            }
            return 0;
        }
    } 
    fclose(fp);
    while(wait(NULL) > 0); 
    printf("Конец основной программы\n");
    return 0; 
 } 
 