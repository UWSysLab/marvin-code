#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>

int main() {
    const int FILE_SIZE = 256 * 1024 * 1024; // bytes
    const int BLOCK_SIZE = 4 * 1024; // bytes
    const char * pathName = "tempfile";

    char * buf = malloc(BLOCK_SIZE);
    for (int i = 0; i < BLOCK_SIZE; i++) {
        buf[i] = 'a';
    }

    int ret;
    struct timeval startTime;
    ret = gettimeofday(&startTime, NULL);
    if (ret < 0) {
        perror("gettimeofday");
    }
    

    int fd = open(pathName, O_CREAT | O_WRONLY);
    if (fd < 0) {
        perror("open");
    }

    for (int i = 0; i < FILE_SIZE / BLOCK_SIZE; i++) {
        ret = write(fd, buf, BLOCK_SIZE);
        if (ret < 0) {
            perror("write");
        }
    }

    ret = fsync(fd);
    if (ret < 0) {
        perror("fsync");
    }

    ret = close(fd);
    if (ret < 0) {
        perror("close");
    }

    struct timeval endTime;
    ret = gettimeofday(&endTime, NULL);
    if (ret < 0) {
        perror("gettimeofday");
    }

    long timeMillis = (endTime.tv_sec - startTime.tv_sec) * 1000 + (endTime.tv_usec - startTime.tv_usec) / 1000;
    printf("%ld\n", timeMillis);

    return 0;
}
