#include<stdio.h>
#include<cuda_runtime.h>
#define L 16777216


__global__ void sample(double *d_array, double *d_sum, int N) {
    __shared__ double s_array[1024];
    __shared__ double d_tb_sum;

    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int local_tid = threadIdx.x;
    double local_sum=0.0;
    if(tid<N) {
    local_sum = d_array[tid]+tid;
    }
    s_array[local_tid]=local_sum;
    __syncthreads();

    for(int stride=blockDim.x/2; stride>0; stride/=2) {
        if (local_tid < stride) {
            s_array[local_tid]+= s_array[local_tid+stride];}
        __syncthreads();}

    if(local_tid == 0){
    atomicAdd(&d_tb_sum, s_array[0]);}
    __syncthreads();
    
    if(local_tid == 0){
        atomicAdd(d_sum, d_tb_sum);}
}


int main(){
  double h_sum=0.0;
  double *d_sum;
//int h_array[10]={1,2,3,4,5,6,7,8,9,10};
double h_array[L];
/*for(int i =0; i<L; i++)
h_array[i]=1;*/
int block_size = 1024;
int N = sizeof(h_array)/sizeof(int);
double *d_array;
cudaMalloc(&d_array, sizeof(double)*L);
cudaMalloc(&d_sum, sizeof(double));
cudaMemcpy(d_array, h_array, sizeof(double)*L, cudaMemcpyHostToDevice);
cudaMemset(d_sum, 0, sizeof(double));
int num_blocks = (N+block_size-1)/block_size;
//sample <<< num_blocks, block_size>>>(d_array, d_sum, N);
sample <<<num_blocks,block_size>>>(d_array, d_sum, N);
cudaDeviceSynchronize();
cudaMemcpy(h_array, d_array, sizeof(double) * L, cudaMemcpyDeviceToHost);
cudaMemcpy(&h_sum, d_sum, sizeof(double), cudaMemcpyDeviceToHost);
cudaFree(d_array);
cudaFree(d_sum);
/*for(int i=0;i<N;i++){
printf("%d\n",h_array[i]);}*/
printf("%lf\n",h_sum);
return 0;
}
