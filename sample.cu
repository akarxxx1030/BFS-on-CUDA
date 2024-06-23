#include<stdio.h>
#include<cuda_runtime.h>

__global__ void sample (int *d_array, int *d_sum, int N){
__shared__ s_array;
int tid = blockIdx.x * blockDim.x + threadIdx.x;
/*
if (tid < N)
s_array[i] = d_array[i];
__syncthreads();

if (tid < N){
s_array[tid] += tid;
atomicAdd(d_sum, s_array[tid]);
}
__syncthreads(); 
   
if (tid < N)
d_array[tid] = s_array[tid];   
}*/

if(tid<N){
d_array[tid]+=tid;
atomicAdd(d_sum,d_array[tid]);}
//d_sum +=d_array[tid];
}


int main(){
  int h_sum=0;
  int *d_sum;
int h_array[10]={1,2,3,4,5,6,7,8,9,10};
int block_size = 256;
int N = sizeof(h_array)/sizeof(int);
int *d_array;
cudaMalloc((void**)&d_array, sizeof(int)*N);
cudaMalloc((void**)&d_sum, sizeof(int));
cudaMemcpy(d_array, h_array, sizeof(int)*N, cudaMemcpyHostToDevice);
cudaMemset(d_sum, 0, sizeof(int));
int num_blocks = (N+block_size-1)/block_size;
//sample <<< num_blocks, block_size>>>(d_array, d_sum, N);
sample <<<4,block_size>>>(d_array, d_sum, N);
cudaMemcpy(h_array, d_array, sizeof(int) * N, cudaMemcpyDeviceToHost);
cudaMemcpy(&h_sum, d_sum, sizeof(int), cudaMemcpyDeviceToHost);
cudaFree(d_array);
cudaFree(d_sum);
for(int i=0;i<N;i++){
printf("%d\n",h_array[i]);}
printf("%d\n",h_sum);
return 0;
}


