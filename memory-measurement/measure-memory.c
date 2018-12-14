#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char ** argv) {
    const char * USAGE = "usage: ./measure-memory pid";
    if (argc != 2) {
        fprintf(stderr, "%s\n", USAGE);
        return -1;
    }

    int pid = atoi(argv[1]);
    printf("Using pid %d\n", pid);

    int fileNameLength = 100;
    char fileName[fileNameLength];
    snprintf(fileName, fileNameLength, "/proc/%d/statm", pid);

    int bufSize = 100;
    char buf[bufSize];
    int ret;

    struct timespec startTime;
    ret = clock_gettime(CLOCK_MONOTONIC, &startTime);
    if (ret < 0) {
        perror("clock_gettime");
        return -1;
    }

    int done = 0;
    struct timespec prevTime = startTime;
    while (!done) {
        struct timespec curTime;
        ret = clock_gettime(CLOCK_MONOTONIC, &curTime);
        if (ret < 0) {
            perror("clock_gettime");
            return -1;
        }

        int prevTimeDiffMs =  (curTime.tv_sec - prevTime.tv_sec) * 1000
                            + (curTime.tv_nsec - prevTime.tv_nsec) / (1000 * 1000);
        if (prevTimeDiffMs < 1) {
            continue;
        }

        int fd;
        fd = open(fileName, O_RDONLY);
        if (fd < 0) {
            perror("open");
            return -1;
        }

        ret = read(fd, buf, bufSize);
        if (ret < 0) {
            perror("read");
            return -1;
        }

        if (ret <= bufSize - 1) {
            buf[ret] = '\0';
        }
        int startTimeDiffMs =  (curTime.tv_sec - startTime.tv_sec) * 1000
                             + (curTime.tv_nsec - startTime.tv_nsec) / (1000 * 1000);
        printf("%d,%s", startTimeDiffMs, buf);

        ret = close(fd);
        if (ret < 0) {
            perror("close");
            return -1;
        }

        prevTime = curTime;
    }
}
