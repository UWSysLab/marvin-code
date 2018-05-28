#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

typedef enum {READ, WRITE} operation_t;

long doOps(const char * fileName, int fileSize, int blockSize, operation_t op, bool random) {
    char * buf = malloc(blockSize);
    if (op == WRITE) {
        for (int i = 0; i < blockSize; i++) {
            buf[i] = 'a';
        }
    }

    int numBlocks = fileSize / blockSize;
    off_t offsets[numBlocks];
    if (random) {
        for (int i = 0; i < numBlocks; i++) {
            offsets[i] = (rand() % numBlocks) * blockSize;
        }
    }

    int ret;
    struct timeval startTime;
    ret = gettimeofday(&startTime, NULL);
    if (ret < 0) {
        perror("gettimeofday");
        return -1;
    }
    
    int fd = -1;
    if (op == WRITE && !random) {
        fd = open(fileName, O_CREAT | O_WRONLY, 0666);
    }
    else if (op == WRITE && random) {
        fd = open(fileName, O_WRONLY);
    }
    else if (op == READ) {
        fd = open(fileName, O_RDONLY);
    }
    if (fd < 0) {
        perror("open");
        return -1;
    }

    for (int i = 0; i < numBlocks; i++) {
        if (random) {
            off_t offset = offsets[i];
            ret = lseek(fd, offset, SEEK_SET);
            if (ret < 0) {
                perror("lseek");
                return -1;
            }
        }

        if (op == WRITE) {
            ret = write(fd, buf, blockSize);
            if (ret < 0) {
                perror("write");
                return -1;
            }
            else if (ret < blockSize) {
                fprintf(stderr, "Write %d only wrote %d bytes\n", i, ret);
                return -1;
            }
        }
        else if (op == READ) {
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
    }

    if (op == WRITE) {
        ret = fsync(fd);
        if (ret < 0) {
            perror("fsync");
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
    const char * USAGE_STR = "./benchmark [read|write] [seq|random]";

    operation_t op;
    bool random;

    if (argc != 3) {
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

    if (strcmp(argv[2], "seq") == 0) {
        random = false;
    }
    else if (strcmp(argv[2], "random") == 0) {
        random = true;
    }
    else {
        fprintf(stderr, "%s\n", USAGE_STR);
        exit(1);
    }

    srand(time(NULL));

    printf("Performing %d reps of operation %s with access pattern %s, file size %d, block size %d\n",
            FILE_SIZE / BLOCK_SIZE, argv[1], argv[2], FILE_SIZE, BLOCK_SIZE);
    long timeMillis = doOps(FILE_NAME, FILE_SIZE, BLOCK_SIZE, op, random);
    if (timeMillis < 0) {
        printf("Operations failed\n");
    }
    else {
        printf("Operations took %ld ms\n", timeMillis);
    }

    return 0;
}
