#include <iostream>
#include <vector>
#include <omp.h>
using namespace std;

int main()
{
    int sizes[] = {10, 1003, 1000000};
    int threads[] = {1, 2, 4};

    for (int s = 0; s < 3; s++)
    {
        int N = sizes[s];

        vector<int> A(N);
        vector<int> B(N);
        vector<int> C_sequential(N);
        vector<int> C_parallel(N);

        for (int i = 0; i < N; i++)
        {
            A[i] = i % 100;
            B[i] = (2 * i) % 100;
        }

        long long sequential_sum = 0;

        for (int i = 0; i < N; i++)
        {
            C_sequential[i] = A[i] + B[i];
            sequential_sum += C_sequential[i];
        }

        cout << "\n====================================\n";
        cout << "N = " << N << endl;
        cout << "Sequential Sum = " << sequential_sum << endl;
        cout << "====================================\n";

        for (int t = 0; t < 3; t++)
        {
            int numThreads = threads[t];
            long long parallel_sum = 0;

            #pragma omp parallel for num_threads(numThreads) reduction(+:parallel_sum)
            for (int i = 0; i < N; i++)
            {
                C_parallel[i] = A[i] + B[i];
                parallel_sum += C_parallel[i];
            }

            int mismatches = 0;

            for (int i = 0; i < N; i++)
            {
                if (C_sequential[i] != C_parallel[i])
                    mismatches++;
            }

            cout << "\nThreads = " << numThreads << endl;
            cout << "OpenMP Sum = " << parallel_sum << endl;
            cout << "Mismatches = " << mismatches << endl;

            if (mismatches == 0 && sequential_sum == parallel_sum)
                cout << "Validation = PASS" << endl;
            else
                cout << "Validation = FAIL" << endl;
        }
    }

    return 0;
}
