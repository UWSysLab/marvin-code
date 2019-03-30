#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#ifndef PAGE_SIZE
#define PAGE_SIZE 4096
#endif

int main(int argc, char ** argv) {
    int ARRAY_SIZE = 1048576;
    char DUMMY_VALUE = 42;

    const char * USAGE = "usage: ./malloc-timer num-arrays";
    if (argc != 2) {
        fprintf(stderr, "%s\n", USAGE);
        return -1;
    }
    int numArrays = atoi(argv[1]);

    printf("Press ENTER to continue...\n");
    char input[3];
    fgets(input, 2, stdin);

    struct timespec startTime;
    int ret = clock_gettime(CLOCK_MONOTONIC, &startTime);
    if (ret < 0) {
        perror("clock_gettime");
        return -1;
    }

    char ** arrayPtrs = malloc(sizeof(char *) * numArrays);
    for (int i = 0; i < numArrays; i++) {
        char * array = malloc(ARRAY_SIZE);
        for (int j = 0; j < ARRAY_SIZE; j += PAGE_SIZE) {
            array[j] = DUMMY_VALUE;
        }
        arrayPtrs[i] = array;
    }

    struct timespec endTime;
    ret = clock_gettime(CLOCK_MONOTONIC, &endTime);
    if (ret < 0) {
        perror("clock_gettime");
        return -1;
    }

    int timeDiffMs =  (endTime.tv_sec - startTime.tv_sec) * 1000
                    + (endTime.tv_nsec - startTime.tv_nsec) / (1000 * 1000);

    printf("Allocated and touched the pages of %d arrays of size %d in %d ms (using page size %d)\n", numArrays, ARRAY_SIZE, timeDiffMs, PAGE_SIZE);
}
