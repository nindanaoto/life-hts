#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// prototype declaration
void dgemm_(char *transA, char *transB, int *m, int *n, int *k, double *alpha, double *A, int *ldA, double *B, int *ldB, double *beta, double *C, int *ldC);

int main(int argc, char **argv)
{
	int i, j;
	int m, n, k;
	int size;
	double *a, *b, *c;
	double alpha, beta;
	int lda, ldb, ldc;
	struct timespec ts1, ts2;

	size = atoi(argv[1]);

	m = size;
	n = size;
	k = size;

	a = (double *)malloc(sizeof(double) * m * k); // m x k matrix
	b = (double *)malloc(sizeof(double) * k * n); // k x n matrix
	c = (double *)malloc(sizeof(double) * m * n); // m x n matrix

	for (i=0; i<m; i++) {
		for (j=0; j<k; j++) {
			a[i + m * j] = rand() / (1.0 + RAND_MAX);
		}
	}

	for (i=0; i<k; i++) {
		for (j=0; j<n; j++) {
			b[i + k * j] = rand() / (1.0 + RAND_MAX);
		}
	}

	for (i=0; i<m; i++) {
		for (j=0; j<n; j++) {
			c[i + m * j] = 0;
		}
	}

	alpha = 1.;
	beta = 0.;
	lda = m; 
	ldb = k; 
	ldc = m; 

	// dgemm_(TransA, TransB, M, N, K, alpha, A, LDA, B, LDB, beta, C, LDC)
	// C = alpha * A * B + beta * C
	// A=M*K, B=K*N, N=M*N
	// Trans: "N"/"T"/"C"
	// LDA = number of row of A

	clock_gettime(CLOCK_REALTIME, &ts1);
	dgemm_("N", "N", &m, &n, &k, &alpha, a, &lda, b, &ldb, &beta, c, &ldc);
	clock_gettime(CLOCK_REALTIME, &ts2);

	printf("%g\n", (ts2.tv_sec - ts1.tv_sec) + (ts2.tv_nsec - ts1.tv_nsec) / 1e9);

	free(a);
	free(b);
	free(c);

	return 0;
}