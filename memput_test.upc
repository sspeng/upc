#include <stdio.h>
#include <stdlib.h>
#include <upc.h>
#include <upc_collective.h>

int get_responsible_thread(int row_i, int no_elements){
	int no_threads = THREADS;
	int responsible_thread = no_threads / 2;

//	printf("thread %d responsible_thread %d, no_threads %d\n", MYTHREAD, responsible_thread, no_threads);

	while( !((row_i >= no_elements*responsible_thread) && (row_i <= no_elements*responsible_thread + no_elements - 1)) ){
		no_threads /= 2;
		if(row_i < no_elements*responsible_thread)
			responsible_thread -= no_threads;
		else if(row_i > no_elements*responsible_thread + no_elements - 1)
			responsible_thread += no_threads;

//		printf("thread %d responsible_thread %d, no_threads %d\n", MYTHREAD, responsible_thread, no_threads);
	}

	return responsible_thread;
}

int main(){
	// number of rows-1
    int N = 10;
	// number of columns
    int M = 20;
	// number of rows processed by each thread
	int no_elements = (N+1)/THREADS + 1;
	// pad number of rows so that each thread processes the same number of rows
    int N_padded = no_elements * THREADS - 1;
    
    if(MYTHREAD == 0)
        printf("N %d, no_elements %d, N_padded %d\n", N, no_elements, N_padded);

	//shared int* T  = upc_alloc( no_elements * M * sizeof(int) );
	//int *local_T = (int*)&T[0];
	int *local_T = (int*) malloc(no_elements*M*sizeof(int));

	int k;
	for( k=0; k<no_elements*M; k++ )
		local_T[k] = MYTHREAD+100;		

    int i, j;

	shared [] int * memput_receive = (shared [] int *) upc_all_alloc( M*(N_padded+1), sizeof(int) );

	for(j=0; j<M; j++){
		int my_row = 0;
		for(i=0; i<=N_padded; i++)
			if(get_responsible_thread(i, no_elements) == MYTHREAD){
				upc_memput( &memput_receive[i+j*(N_padded+1)], &local_T[my_row + j*no_elements], sizeof(int) );
				
				printf("thread %d writing to memput_receive[%2d, %2d] from local_T[%2d, %2d]\n", MYTHREAD, i, j, my_row, j);
				my_row++;
			}
	}
	
	upc_barrier;

    if(MYTHREAD == 0){
		printf("matrix of size %dx%d responsible thread for each matrix element\n",N_padded+1, M);
 	
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
                printf("%3d ", get_responsible_thread(i, no_elements));

			printf("\n");
		}
	}

    upc_barrier;

    if(MYTHREAD == 0){
		printf("matrix of size %dx%d responsible thread for each matrix element\n",N_padded+1, M);
 	
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
                printf("%3d ", memput_receive[i + j*(N_padded+1)]);

			printf("\n");
		}
	}

//	upc_free( T );
	upc_free( memput_receive );
	free( local_T );

    return 0;
}

