#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <stdbool.h>

bool is_prime(int num) {
	if (num <= 1) return false;
	for (int i = 2; i * i <= num; i++) {
    	if (num % i == 0) return false;
	}
	return true;
}

void sum_of_primes(int* arr, int n, int write_fd) {
	int prime_sum = 0;
	for (int i = 0; i < n; i++) {
    	if (is_prime(arr[i])) {
        	prime_sum += arr[i];
    	}
	}
	write(write_fd, &prime_sum, sizeof(prime_sum));
	close(write_fd); // Закрываем запись в канал
	exit(0);
}

void sum_of_evens(int* arr, int n, int write_fd) {
	int even_sum = 0;
	for (int i = 0; i < n; i++) {
    	if (arr[i] % 2 == 0) {
        	even_sum += arr[i];
    	}
	}
	write(write_fd, &even_sum, sizeof(even_sum));
	close(write_fd); // Закрываем запись в канал
	exit(0);
}

int main() {
	int n;

	printf("Введите размер массива: ");
	scanf("%d", &n);

	int* A = (int*)malloc(n * sizeof(int));
	printf("Введите %d целых положительных чисел через пробел: ", n);
	for (int i = 0; i < n; i++) {
    	scanf("%d", &A[i]);
	}

	int pipe_primes[2]; // Канал для суммы простых чисел
	int pipe_evens[2];  // Канал для суммы четных чисел

	// Создание каналов
	if (pipe(pipe_primes) == -1 || pipe(pipe_evens) == -1) {
    	perror("Ошибка создания канала");
    	exit(EXIT_FAILURE);
	}

	pid_t pid1 = fork();
	
	if (pid1 == 0) {
    	// Первый процесс для суммы простых чисел
    	close(pipe_primes[0]); // Закрываем чтение в дочернем процессе
    	sum_of_primes(A, n, pipe_primes[1]);
	} else {
    	pid_t pid2 = fork();

    	if (pid2 == 0) {
        	// Второй процесс для суммы четных чисел
        	close(pipe_evens[0]); // Закрываем чтение в дочернем процессе
        	sum_of_evens(A, n, pipe_evens[1]);
    	} else {
        	// Родительский процесс
        	close(pipe_primes[1]); // Закрываем запись в родительском процессе
        	close(pipe_evens[1]);  // Закрываем запись в родительском процессе

        	int prime_sum, even_sum;

        	read(pipe_primes[0], &prime_sum, sizeof(prime_sum)); // Читаем сумму простых чисел
        	read(pipe_evens[0], &even_sum, sizeof(even_sum));   // Читаем сумму четных чисел

        	wait(NULL); // Ожидание завершения дочерних процессов
        	wait(NULL);

        	// Определение максимальной суммы
        	int max_sum = (prime_sum > even_sum) ? prime_sum : even_sum;
        	printf("Сумма простых чисел: %d\n", prime_sum);
        	printf("Сумма четных чисел: %d\n", even_sum);
        	printf("Максимальная сумма: %d\n", max_sum);
    	}
	}
	return 0;
}
