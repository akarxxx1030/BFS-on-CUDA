#include <cuda_runtime.h>
#include <stdio.h>
#include "/content/drive/MyDrive/kate.h"

__global__ void bfs_kernel(int *d_graph_nodes, int *d_graph_edges, int *d_cost, int *d_graph_active, int *d_updating_graph_active, int k, int *d_count, int no_of_nodes) {
    int tid = threadIdx.x + blockIdx.x * blockDim.x;


    if (tid < no_of_nodes && d_graph_active[tid] != -1) {
        int node = d_graph_active[tid];
        for (int i = d_graph_nodes[node]; i < d_graph_nodes[node + 1]; i++) {
            int id = d_graph_edges[i];
            if (atomicMin(&d_cost[id], k) > k) {
                int pos = atomicAdd(d_count, 1);
                d_updating_graph_active[pos] = id;
            }
        }
    }
}
    
    
    
    


int main() {
    int no_of_nodes = ver;
    int edge_list_size = edg;
    int source = 0;

    h_graph_active[0] = source;
    
    int *d_graph_nodes, *d_graph_edges, *d_cost, *d_graph_active, *d_updating_graph_active, *d_count;
    cudaMalloc((void**)&d_graph_nodes, sizeof(int) * (no_of_nodes + 1));
    cudaMalloc((void**)&d_graph_edges, sizeof(int) * edge_list_size);
    cudaMalloc((void**)&d_cost, sizeof(int) * no_of_nodes);
    cudaMalloc((void**)&d_graph_active, sizeof(int) * no_of_nodes);
    cudaMalloc((void**)&d_updating_graph_active, sizeof(int) * no_of_nodes);
    cudaMalloc((void**)&d_count, sizeof(int));
    
    cudaMemcpy(d_graph_nodes, h_graph_nodes, sizeof(int) * (no_of_nodes + 1), cudaMemcpyHostToDevice);
    cudaMemcpy(d_graph_edges, h_graph_edges, sizeof(int) * edge_list_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_cost, h_cost, sizeof(int) * no_of_nodes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_graph_active, h_graph_active, sizeof(int) * no_of_nodes, cudaMemcpyHostToDevice);
 
    for (int i = 0; i < ver; i++) {
        h_cost[i] = -1;
    }
    
     
    h_cost[source] = 0;
    cudaMemcpy(d_cost, h_cost, sizeof(int) * no_of_nodes, cudaMemcpyHostToDevice);
    
    int count1 = 1;
    int k = 0;
    int *h_count = (int*)malloc(sizeof(int));
    int var = *h_count;
    
    
     do {
        k++;
        *h_count = 0;
        cudaMemcpy(d_count, h_count, sizeof(int), cudaMemcpyHostToDevice);
        
        int num_blocks = (count1 + 255) / 256;
        bfs_kernel<<<num_blocks, 256>>>(d_graph_nodes, d_graph_edges, d_cost, d_graph_active,    d_updating_graph_active, k, d_count, ver);

        cudaMemcpy(h_count, d_count, sizeof(int), cudaMemcpyDeviceToHost);
        count1 = *h_count;

        cudaMemcpy(d_graph_active, d_updating_graph_active, sizeof(int) * count1, cudaMemcpyDeviceToDevice);

    } while (var);
    
    cudaMemcpy(h_cost, d_cost, sizeof(int) * no_of_nodes, cudaMemcpyDeviceToHost);

    cudaFree(d_graph_nodes);
    cudaFree(d_graph_edges);
    cudaFree(d_cost);
    cudaFree(d_graph_active);
    cudaFree(d_updating_graph_active);
    cudaFree(d_count);
    free(h_count);
 }
