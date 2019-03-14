#include <stdio.h>
#include <stdlib.h>

extern void asma(unsigned long *a, unsigned long *b, unsigned long c);
extern void asmb(unsigned long *a, unsigned long *b, unsigned long c, unsigned long n);

void asma_ref(unsigned long *a, unsigned long *b, unsigned long c)
{
    unsigned long longs= c >> 6;
    unsigned long bits = c & 63;
    if (bits==0) {
        b[0]=a[(0-longs)%2];
        b[1]=a[(1-longs)%2];
    } else {
        b[0] = (a[(0-longs)%2]<<bits)|(a[(-1-longs)%2]>>-bits);
        b[1] = (a[(1-longs)%2]<<bits)|(a[( 0-longs)%2]>>-bits);
    }
}

void asmb_ref(unsigned long *a, unsigned long *b, unsigned long c, unsigned long n)
{
    unsigned long longs=c>>6;
    unsigned long bits = c & 63;
    unsigned long i;
    if (bits == 0)
        for (i=0; i<n; i++)
            b[i] = a[(i-longs)%n];
    else
        for (i=0; i<n; i++)
            b[i] = (a[(i-longs)%n]<<bits)|(a[(i-longs-1)%n]>>-bits);
}

int main() {
    FILE* rand = fopen("/dev/urandom", "r");
    if (!rand) {
        perror("urandom");
        exit(1);
    }

    int num_tests = 100000;

#define MAX_N 16
    unsigned long a[MAX_N];
    unsigned long b[MAX_N];
    unsigned long b_ref[MAX_N];
    int n = 2;

    int num_failed = 0;
    int num_total = 0;

    printf("testing a\n");
    for (int i = 0; i < num_tests; ++i) {
        int num_bytes = fread(a, 1, sizeof(unsigned long) * n, rand);
        if (num_bytes != sizeof(unsigned long) * n) {
            perror("urandom");
            exit(1);
        }

        for (int c = 0; c < 200; ++c) {
            asma(a, b, c);
            asma_ref(a, b_ref, c);
        }
        int invalid = 0;
        for (int j = 0; j < n; ++j) {
            if (b[j] != b_ref[j]) {
                invalid = 1;
                break;
            }
        }
        if (invalid)
            ++num_failed;
        ++num_total;
    }
    printf("failed: %d/%d\n", num_failed, num_total);
    num_failed = 0;
    num_total= 0;

    printf("testing b\n");
    for (int n = 2; n <= MAX_N; n *= 2) {
        for (int i = 0; i < num_tests; ++i) {
            int num_bytes = fread(a, 1, sizeof(unsigned long) * n, rand);
            if (num_bytes != sizeof(unsigned long) * n) {
                perror("urandom");
                exit(1);
            }
    
            for (int c = 0; c < 200; ++c) {
                asmb(a, b, c, n);
                asmb_ref(a, b_ref, c, n);
            }
            int invalid = 0;
            for (int j = 0; j < n; ++j) {
                if (b[j] != b_ref[j]) {
                    invalid = 1;
                    break;
                }
            }
            if (invalid)
                ++num_failed;
            ++num_total;
        }
    }
    printf("failed: %d/%d\n", num_failed, num_total);

    printf("done\n");
    fclose(rand);
    return 0;
}
