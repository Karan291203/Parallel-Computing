CNN20603 PARALLEL COMPUTING
MEMBER 2 – MPI DEVELOPER

SOURCE CODE README

File:
- mpi_vector_sum.cpp

Build using mpicxx:
    mpicxx -std=c++17 -Wall -Wextra mpi_vector_sum.cpp -o mpi_vector_sum

Run:
    mpirun -np 1 ./mpi_vector_sum 10
    mpirun -np 2 ./mpi_vector_sum 10
    mpirun -np 4 ./mpi_vector_sum 10
    mpirun -np 1 ./mpi_vector_sum 1003
    mpirun -np 2 ./mpi_vector_sum 1003
    mpirun -np 4 ./mpi_vector_sum 1003
    mpirun -np 1 ./mpi_vector_sum 1000000
    mpirun -np 2 ./mpi_vector_sum 1000000
    mpirun -np 4 ./mpi_vector_sum 1000000

Zero-length chunk test:
    mpirun -np 4 ./mpi_vector_sum 2

The program distributes A[i] = i % 100 using MPI_Scatterv,
calculates local sums and combines them using MPI_Reduce with MPI_SUM.
It also exchanges element counts using MPI_Send and MPI_Recv.
Expected sums for N = 10, 1003, 1000000 and 2 are 45, 49503,
49500000 and 1, respectively. Compare against the sequential reference.
Use Open MPI and a C++17 compiler; the commands above follow the MPI report.
Record actual execution evidence and ensure process slots are available.
