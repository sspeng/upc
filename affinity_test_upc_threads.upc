// compile with:
// sgiupc -LANG:upc_threads=THREADS affinity_test_upc_threads.upc -o affinity_test_upc_threads

#include <upc.h>
#include <stdio.h>

#define N 10
#define BLOCKSIZE ((N+1)/THREADS + 1)

int main(){
    
	// number of rows-1
    //int N = 10;
	// number of columns
    int M = 20;
	// number of rows processed by each thread
	int no_elements = (N+1)/THREADS + 1;
	// pad number of rows so that each thread processes the same number of rows
    int N_padded = no_elements * THREADS - 1;
    
    if(MYTHREAD == 0)
        printf("N %d, no_elements %d, N_padded %d\n", N, no_elements, N_padded);

	shared [BLOCKSIZE] int* T  = (shared [BLOCKSIZE] int*) upc_all_alloc( M*(N_padded+1)/BLOCKSIZE, sizeof(int)*BLOCKSIZE);

    int i, j;
    if(MYTHREAD == 0){
		printf("matrix of size %dx%d affinities for each matrix element\n",N_padded+1, M);
 	
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
                printf("%3ld ", upc_threadof(&T[i+j*(N_padded+1)]));

			printf("\n");
		}
	}

    upc_barrier;

	// write to own block column-by-column
	int *local_T = (int*)&T[BLOCKSIZE*MYTHREAD];

	for(j=0; j<M; j++){
		for(i=0; i<BLOCKSIZE; i++)
			local_T[i] = MYTHREAD + 100;

		local_T += no_elements;					
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
    return 0;
}

