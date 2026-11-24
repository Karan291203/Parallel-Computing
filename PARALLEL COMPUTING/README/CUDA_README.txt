CNN20603 PARALLEL COMPUTING
MEMBER 3 – CUDA DEVELOPER

SOURCE CODE README

File:
- vector_add.cu (provisional; confirm actual source filename with J)

Build using nvcc (provisional command):
    nvcc vector_add.cu -o vector_add

Run:
    ./vector_add

Windows (CUDA Toolkit and compatible host compiler):
    nvcc vector_add.cu -o vector_add.exe
    vector_add.exe

The updated CUDA report uses A[i] = i % 100 and B[i] = (2*i) % 100
and calculates C[i] = A[i] + B[i]. It tests N = 10, 1003 and 1000000
using 256 threads per block, with 1, 4 and 3907 blocks respectively.
Compare every output element against the CPU reference. The expected
mismatch count is zero. The supplied report shows PASS on an NVIDIA
GeForce MX330. Run on a compatible NVIDIA GPU with CUDA Toolkit installed.
Confirm the source filename and build command with the CUDA developer
before submission; no CUDA source file was supplied for this README.
