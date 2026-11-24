#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

// CUDA Vector Addition Kernel
__global__ void vectorAdd(int *A, int *B, int *C, int N)
{
    // Calculate global thread index
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    // Check array boundaries
    if (i < N)
    {
        C[i] = A[i] + B[i];
    }
}


// Host function: Prepare input arrays and CPU reference
void prepareArrays(int *A, int *B, int *reference, int N)
{
    for (int i = 0; i < N; i++)
    {
        // Initialise input arrays
        A[i] = i % 100;
        B[i] = (i * 2) % 100;

        // Calculate expected result using CPU
        reference[i] = A[i] + B[i];
    }
}


// Allocate memory on the GPU
bool allocateDeviceMemory(int **d_A, int **d_B, int **d_C, size_t bytes)
{
    cudaError_t error;

    error = cudaMalloc((void**)d_A, bytes);

    if (error != cudaSuccess)
    {
        printf("Failed to allocate GPU memory for A: %s\n",
               cudaGetErrorString(error));
        return false;
    }

    error = cudaMalloc((void**)d_B, bytes);

    if (error != cudaSuccess)
    {
        printf("Failed to allocate GPU memory for B: %s\n",
               cudaGetErrorString(error));
        return false;
    }

    error = cudaMalloc((void**)d_C, bytes);

    if (error != cudaSuccess)
    {
        printf("Failed to allocate GPU memory for C: %s\n",
               cudaGetErrorString(error));
        return false;
    }

    return true;
}


// Transfer input arrays from CPU to GPU
bool copyInputsToDevice(int *d_A, int *d_B,
                        int *h_A, int *h_B,
                        size_t bytes)
{
    cudaError_t error;

    // Copy Array A
    error = cudaMemcpy(d_A, h_A, bytes,
                       cudaMemcpyHostToDevice);

    if (error != cudaSuccess)
    {
        printf("Failed to copy A to GPU: %s\n",
               cudaGetErrorString(error));
        return false;
    }

    // Copy Array B
    error = cudaMemcpy(d_B, h_B, bytes,
                       cudaMemcpyHostToDevice);

    if (error != cudaSuccess)
    {
        printf("Failed to copy B to GPU: %s\n",
               cudaGetErrorString(error));
        return false;
    }

    return true;
}


// Launch CUDA vector addition kernel
bool launchVectorAdd(int *d_A, int *d_B, int *d_C, int N)
{
    // Number of threads per block
    int threadsPerBlock = 256;

    // Calculate number of blocks
    int blocksPerGrid = (N + threadsPerBlock - 1)
                        / threadsPerBlock;

    printf("\nArray size: %d\n", N);
    printf("Blocks: %d\n", blocksPerGrid);
    printf("Threads per block: %d\n", threadsPerBlock);

    // Launch GPU kernel
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(
        d_A, d_B, d_C, N
    );

    // Check kernel launch error
    cudaError_t error = cudaGetLastError();

    if (error != cudaSuccess)
    {
        printf("Kernel launch failed: %s\n",
               cudaGetErrorString(error));
        return false;
    }

    // Wait for GPU execution to complete
    error = cudaDeviceSynchronize();

    if (error != cudaSuccess)
    {
        printf("GPU execution failed: %s\n",
               cudaGetErrorString(error));
        return false;
    }

    printf("GPU kernel execution completed.\n");

    return true;
}


// Copy GPU results back to CPU
bool copyResultsToHost(int *h_C, int *d_C, size_t bytes)
{
    cudaError_t error;

    error = cudaMemcpy(h_C, d_C, bytes,
                       cudaMemcpyDeviceToHost);

    if (error != cudaSuccess)
    {
        printf("Failed to copy results from GPU: %s\n",
               cudaGetErrorString(error));
        return false;
    }

    printf("GPU results successfully copied to CPU.\n");

    return true;
}


// Validate GPU results against CPU reference
bool validateResults(int *h_C, int *h_reference, int N)
{
    int mismatches = 0;

    for (int i = 0; i < N; i++)
    {
        if (h_C[i] != h_reference[i])
        {
            mismatches++;
        }
    }

    printf("Mismatch count: %d\n", mismatches);

    if (mismatches == 0)
    {
        printf("Validation: PASS\n");
        return true;
    }
    else
    {
        printf("Validation: FAIL\n");
        return false;
    }
}


int main()
{
    // Test array sizes
    int sizes[] = {10, 1003, 1000000};

    // Check available CUDA GPU
    int deviceCount = 0;

    cudaError_t error = cudaGetDeviceCount(&deviceCount);

    if (error != cudaSuccess || deviceCount == 0)
    {
        printf("No CUDA-capable GPU detected.\n");
        return 1;
    }

    // Get GPU information
    cudaDeviceProp prop;

    error = cudaGetDeviceProperties(&prop, 0);

    if (error != cudaSuccess)
    {
        printf("Failed to get GPU information: %s\n",
               cudaGetErrorString(error));
        return 1;
    }

    printf("GPU: %s\n", prop.name);
    printf("Compute Capability: %d.%d\n",
           prop.major, prop.minor);

    printf("\n===== CUDA VECTOR ADDITION =====\n");

    bool allPassed = true;

    // Run all three test cases
    for (int test = 0; test < 3; test++)
    {
        int N = sizes[test];

        size_t bytes = (size_t)N * sizeof(int);

        // Host pointers
        int *h_A = NULL;
        int *h_B = NULL;
        int *h_C = NULL;
        int *h_reference = NULL;

        // Device pointers
        int *d_A = NULL;
        int *d_B = NULL;
        int *d_C = NULL;

        bool testPassed = false;

        printf("\n--- Test %d ---\n", test + 1);

        // Allocate host memory
        h_A = (int*)malloc(bytes);
        h_B = (int*)malloc(bytes);
        h_C = (int*)malloc(bytes);
        h_reference = (int*)malloc(bytes);

        if (!h_A || !h_B || !h_C || !h_reference)
        {
            printf("Host memory allocation failed.\n");
            goto cleanup;
        }

        // Initialise arrays and calculate CPU reference
        prepareArrays(h_A, h_B, h_reference, N);

        // Allocate GPU memory
        if (!allocateDeviceMemory(&d_A, &d_B, &d_C, bytes))
            goto cleanup;

        // Copy inputs to GPU
        if (!copyInputsToDevice(d_A, d_B, h_A, h_B, bytes))
            goto cleanup;

        // Launch GPU kernel
        if (!launchVectorAdd(d_A, d_B, d_C, N))
            goto cleanup;

        // Copy results back to CPU
        if (!copyResultsToHost(h_C, d_C, bytes))
            goto cleanup;

        // Validate results
        testPassed = validateResults(h_C, h_reference, N);

        if (!testPassed)
            allPassed = false;

cleanup:

        // Free GPU memory and check errors
	if (d_A)
	{
 	   	error = cudaFree(d_A);
 	   	if (error != cudaSuccess)
    	{
        	printf("Failed to free d_A: %s\n",
               		cudaGetErrorString(error));
        	allPassed = false;
    	}}

	if (d_B)
	{
   		error = cudaFree(d_B);
    		if (error != cudaSuccess)
   	{
       		printf("Failed to free d_B: %s\n",
             		 cudaGetErrorString(error));
       		allPassed = false;
    	}}

	if (d_C)
	{
    		error = cudaFree(d_C);
    		if (error != cudaSuccess)
    	{
        	printf("Failed to free d_C: %s\n",
               		cudaGetErrorString(error));
        	allPassed = false;
    	}}

        // Free CPU memory
        free(h_A);
        free(h_B);
        free(h_C);
        free(h_reference);

        if (!testPassed)
            allPassed = false;
    }

    printf("\n===== FINAL RESULT =====\n");

    if (allPassed)
        printf("All test cases PASSED!\n");
    else
        printf("One or more test cases FAILED!\n");

    return allPassed ? 0 : 1;
}
