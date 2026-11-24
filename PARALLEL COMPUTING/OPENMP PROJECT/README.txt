CNN20603 PARALLEL COMPUTING
MEMBER 1 – OPENMP DEVELOPER

SOURCE CODE README

File:
- openmp_lab.cpp

Build using g++ with OpenMP:
    g++ -fopenmp openmp_lab.cpp -o openmp_lab

Run:
    ./openmp_lab

Windows MinGW:
    g++ -fopenmp openmp_lab.cpp -o openmp_lab.exe
    openmp_lab.exe

The program tests N = 10, 1003 and 1000000 using 1, 2 and 4 OpenMP
threads. It uses A[i] = i % 100 and B[i] = (2*i) % 100, performs
C[i] = A[i] + B[i], computes the sum using OpenMP reduction, and
compares every element and the final sum with the sequential reference.

Execution evidence submitted in the report should be captured from the
student's actual environment, as required by the assignment.
