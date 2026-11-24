
#include <iostream>
#include <mpi.h>

using namespace std;

int main(int argc, char* argv[]) {

    // Initialise MPI
    MPI_Init(&argc, &argv);

    // Declare rank and process count
    int rank, size;

    // Get current process rank
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    // Get total number of processes
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Display process information
    cout << "Hello from MPI Process "
         << rank
         << " out of "
         << size
         << " processes."
         << endl;

    // End MPI
    MPI_Finalize();

    return 0;
}
