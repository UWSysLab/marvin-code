#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <time.h>

int main(int argc, char ** argv) {
    const char * USAGE_STR = "usage: ./mm-syscall-benchmark num-bytes";

    if (argc != 2) {
        fprintf(stderr, "%s\n", USAGE_STR);
        return 1;
    }

    uint64_t numBytes = atol(argv[1]);
    printf("numBytes: %lu\n", numBytes);

    void * map = mmap((void *)0xc0000000, numBytes, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (map == (void *)-1) {
        perror("mmap");
        return 1;
    }
    printf("map: %lx\n", (uint64_t)map);

    for (int i = 0; i < numBytes; i++) {
        *((uint8_t *)map + i) = 42;
    }

    int ret;
    struct timespec startTime;
    ret = clock_gettime(CLOCK_MONOTONIC, &startTime);
    if (ret < 0) {
        perror("clock_gettime");
        return -1;
    }

    munmap(map, numBytes);

    struct timespec endTime;
    ret = clock_gettime(CLOCK_MONOTONIC, &endTime);
    if (ret < 0) {
        perror("clock_gettime");
        return -1;
    }

    uint64_t timeUs = (endTime.tv_sec - startTime.tv_sec) * (1000 * 1000) + (endTime.tv_nsec - startTime.tv_nsec) / 1000;
    printf("Time (us): %lu\n", timeUs);

    return 0;
}
