/*

mpirun -np 8 ./affinity_test_asterisk
N 9
matrix of size 10x20 affinities for each matrix element
        0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19
      --------------------------------------------------------------------------------
  0 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3
  1 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3
  2 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3
  3 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3
  4 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3
  5 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3
  6 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3
  7 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3
  8 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3
  9 |   0   1   2   3   4   5   6   7   0   1   2   3   4   5   6   7   0   1   2   3

*/

#include <upc.h>
#include <stdio.h>

#define N 9
#define M 20

extern shared [*] int T[10*THREADS]; 

int main(){
    
    if(MYTHREAD == 0)
        printf("N %d\n", N);


    int i, j;
    if(MYTHREAD == 0){
		printf("matrix of size %dx%d affinities for each matrix element\n",N+1, M);
 	
		printf("      ");
		for(j = 0; j < M; j++)
			printf("%3d ",j);
		printf("\n");
		printf("      ");
		for(j = 0; j < M; j++)
            printf("----");
		printf("\n");
        for(i = 0; i<=N; i++){
			printf("%3d | ",i);
        	for(j = 0; j<M; j++)
                printf("%3ld ", upc_threadof(&T[i+j*(N+1)]));

			printf("\n");
		}
	}

    upc_barrier;
/*
	// write to own block column-by-column
	int *local_T = (int*)&T[BLOCKSIZE*MYTHREAD];

	for(j=0; j<M; j++){
		for(i=0; i<BLOCKSIZE; i++)
			local_T[i] = MYTHREAD + 100;

		local_T += BLOCKSIZE;					
	}
	
	upc_barrier;

    if(MYTHREAD == 0){
		printf("\n");
		printf("matrix of size %dx%d write thread ID + 100 to your own elements\n",N_padded+1, M);
 	
		printf("      ");
		for(j = 0; j < M; j++)
			printf("%3d ",j);
		printf("\n");
		printf("      ");
		for(j = 0; j < M; j++)
            printf("----");
		printf("\n");
        for(i = 0; i<=N_padded; i++){
			printf("%3d | ",i);
        	for(j = 0; j<M; j++)
                printf("%3d ", T[i+j*(N_padded+1)]);

			printf("\n");
		}
	}

    upc_barrier;
*/

    return 0;
}

