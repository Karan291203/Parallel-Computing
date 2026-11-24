
#include <iostream>
#include <vector>
#include <numeric>
#include <mpi.h>
#include <cstdlib>

using namespace std;

int main(int argc, char* argv[]) {

    // Initialise MPI environment
    MPI_Init(&argc, &argv);

    int rank;
    int size;

    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Array size
    int N = 1003;

    // Allow user to specify N through terminal
    if (argc > 1) {
        N = atoi(argv[1]);
    }

    // Validate input
    if (N < 1) {

        if (rank == 0) {
            cerr << "Invalid array size." << endl;
        }

        MPI_Finalize();
        return 1;
    }

    // Declare arrays and distribution information
    vector<int> A;
    vector<int> counts(size);
    vector<int> displacements(size);

    if (rank == 0) {

        A.resize(N);

        // Generate array A
        for (int i = 0; i < N; i++) {
            A[i] = i % 100;
        }

        cout << "MPI Vector Sum Program" << endl;
        cout << "Array size: " << N << endl;
        cout << "Processes: " << size << endl;
    }

    // Calculate counts and displacements

int base = N / size;
int remainder = N % size;

int offset = 0;

for (int i = 0; i < size; i++) {

    counts[i] = base;

    if (i < remainder) {
        counts[i]++;
    }

    displacements[i] = offset;

    offset += counts[i];
}

// Display distribution information
if (rank == 0) {

    cout << "\nDistribution Information" << endl;

    for (int i = 0; i < size; i++) {

        cout << "Rank " << i
             << " | Count: " << counts[i]
             << " | Displacement: "
             << displacements[i] << endl;
    }
}

// Create local array for each process
vector<int> local_A(counts[rank]);
// Distribute array using MPI_Scatterv()
MPI_Scatterv(
    rank == 0 ? A.data() : nullptr,
    rank == 0 ? counts.data() : nullptr,
    rank == 0 ? displacements.data() : nullptr,
    MPI_INT,
    local_A.data(),
    counts[rank],
    MPI_INT,
    0,
    MPI_COMM_WORLD
);

// Calculate local sum
long long local_sum = 0;

for (int value : local_A) {
    local_sum += value;
}

// Display local sum for each process
cout << "Rank " << rank
     << " | Local Sum: " << local_sum << endl;

// Combine all local sums using MPI_Reduce()
long long global_sum = 0;

MPI_Reduce(
    &local_sum,
    &global_sum,
    1,
    MPI_LONG_LONG_INT,
    MPI_SUM,
    0,
    MPI_COMM_WORLD
);

// Point-to-point communication using MPI_Send and MPI_Recv

const int TAG = 100;
bool count_validation = true;

if (rank == 0) {

    cout << "\nReceiving element counts from other processes:\n";

    for (int source = 1; source < size; source++) {

        int received_count = 0;

        MPI_Recv(
            &received_count,
            1,
            MPI_INT,
            source,
            TAG,
            MPI_COMM_WORLD,
            MPI_STATUS_IGNORE
        );

        cout << "Rank " << source
             << " sent element count: "
             << received_count << endl;

        if (received_count != counts[source]) {
            count_validation = false;
        }
    }

}
else {

    MPI_Send(
        &counts[rank],
        1,
        MPI_INT,
        0,
        TAG,
        MPI_COMM_WORLD
    );

}

// Sequential validation and final result

if (rank == 0) {

    long long expected_sum = 0;

    // Calculate sequential reference sum
    for (int i = 0; i < N; i++) {
        expected_sum += i % 100;
    }

    cout << "\n========== FINAL VALIDATION ==========\n";

    cout << "Expected Sequential Sum: "
         << expected_sum << endl;

    cout << "MPI Distributed Sum: "
         << global_sum << endl;

    if (global_sum == expected_sum && count_validation) {
    cout << "Validation Status: PASS" << endl;
}
else {
    cout << "Element Count Validation: "
     << (count_validation ? "PASS" : "FAIL") << endl;
}

    cout << "======================================\n";
}

// Display received elements
if (N <= 20) {

    cout << "\nRank " << rank << " received: ";

    for (int value : local_A) {
        cout << value << " ";
    }

    cout << endl;

} else {

    cout << "\nRank " << rank
         << " received " << local_A.size()
         << " elements." << endl;
}

    MPI_Finalize();

    return 0;
}
