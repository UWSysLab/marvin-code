#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

typedef enum {READ, WRITE} operation_t;

long doWrite(const char * fileName, int fileSize, int blockSize) {
    char * buf = malloc(blockSize);
    for (int i = 0; i < blockSize; i++) {
        buf[i] = 'a';
    }

    int ret;
    struct timeval startTime;
    ret = gettimeofday(&startTime, NULL);
    if (ret < 0) {
        perror("gettimeofday");
        return -1;
    }
    

    int fd = open(fileName, O_CREAT | O_WRONLY, 0666);
    if (fd < 0) {
        perror("open");
        return -1;
    }

    for (int i = 0; i < fileSize / blockSize; i++) {
        ret = write(fd, buf, blockSize);
        if (ret < 0) {
            perror("write");
            return -1;
        }
        else if (ret < blockSize) {
            fprintf(stderr, "Write %d ony wrote %d bytes\n", i, ret);
            return -1;
        }
    }

    ret = fsync(fd);
    if (ret < 0) {
        perror("fsync");
        return -1;
    }

    ret = close(fd);
    if (ret < 0) {
        perror("close");
        return -1;
    }

    struct timeval endTime;
    ret = gettimeofday(&endTime, NULL);
    if (ret < 0) {
        perror("gettimeofday");
        return -1;
    }

    long timeMillis = (endTime.tv_sec - startTime.tv_sec) * 1000 + (endTime.tv_usec - startTime.tv_usec) / 1000;
    return timeMillis;
}

long doRead(const char * fileName, int fileSize, int blockSize) {
    char * buf = malloc(blockSize);

    int ret;
    struct timeval startTime;
    ret = gettimeofday(&startTime, NULL);
    if (ret < 0) {
        perror("gettimeofday");
        return -1;
    }

    int fd = open(fileName, O_RDONLY);
    if (fd < 0) {
        perror("open");
        return -1;
    }

    for (int i = 0; i < fileSize / blockSize; i++) {
        ret = read(fd, buf, blockSize);
        if (ret < 0) {
            perror("read");
            return -1;
        }
        else if (ret < blockSize) {
            fprintf(stderr, "Read %d only read %d bytes\n", i, ret);
            return -1;
        }
    }

    ret = close(fd);
    if (ret < 0) {
        perror("close");
        return -1;
    }

    struct timeval endTime;
    ret = gettimeofday(&endTime, NULL);
    if (ret < 0) {
        perror("gettimeofday");
        return -1;
    }

    long timeMillis = (endTime.tv_sec - startTime.tv_sec) * 1000 + (endTime.tv_usec - startTime.tv_usec) / 1000;
    return timeMillis;
}

int main(int argc, char **argv) {
    const int FILE_SIZE = 256 * 1024 * 1024; // bytes
    const int BLOCK_SIZE = 4 * 1024; // bytes
    const char * FILE_NAME = "tempfile";
    const char * USAGE_STR = "./benchmark [read|write]";

    operation_t op;

    if (argc != 2) {
        fprintf(stderr, "%s\n", USAGE_STR);
        exit(1);
    }

    if (strcmp(argv[1], "read") == 0) {
        op = READ;
    }
    else if (strcmp(argv[1], "write") == 0) {
        op = WRITE;
    }
    else {
        fprintf(stderr, "%s\n", USAGE_STR);
        exit(1);
    }

    long timeMillis = -1;
    if (op == WRITE) {
        timeMillis = doWrite(FILE_NAME, FILE_SIZE, BLOCK_SIZE);
    }
    else if (op == READ) {
        timeMillis = doRead(FILE_NAME, FILE_SIZE, BLOCK_SIZE);
    }

    if (timeMillis < 0) {
        printf("Operation %s failed\n", argv[1]);
    }
    else {
        printf("Operation %s took %ld ms\n", argv[1], timeMillis);
    }

    return 0;
}
