#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#ifndef PAGE_SIZE
#define PAGE_SIZE 4096
#endif

int pagemapFd = -1;

int getBit(unsigned char word[8], int index) {
    int byteIndex = index / 8;
    int bitIndex = index % 8;
    return (word[byteIndex] >> bitIndex) & 1;
}

int checkPageSoftDirty(unsigned int page) {
    unsigned int offset = page * 8;
    off_t retOffset = lseek(pagemapFd, offset, SEEK_SET);
    if (retOffset < 0) {
        perror("lseek on pagemap");
        exit(1);
    }

    unsigned char word[8];
    ssize_t bytesRead = read(pagemapFd, word, 8);
    if (bytesRead < 0) {
        perror("read on pagemap");
        exit(1);
    }

    int softDirtyBit = getBit(word, 55);
    return softDirtyBit;
}

int countSoftDirtyPages(unsigned int startAddress, unsigned int endAddress) {
    if (startAddress % PAGE_SIZE != 0) {
        fprintf(stderr, "countSoftDirtyPages: start address %u is not page-aligned\n",
                startAddress);
        exit(1);
    }
    if (endAddress % PAGE_SIZE != 0) {
        fprintf(stderr, "countSoftDirtyPages: end address %u is not page-aligned\n",
                endAddress);
        exit(1);
    }

    unsigned int startPage = startAddress / PAGE_SIZE;
    unsigned int endPage = endAddress / PAGE_SIZE;

    int count = 0;
    for (unsigned int page = startPage; page < endPage; page++) {
        int isSoftDirty = checkPageSoftDirty(page);
        count += isSoftDirty;
    }
    return count;
}

int main(int argc, char ** argv) {
    const char * usage = "usage: ./wsetracker target-pid";
    if (argc < 2) {
        fprintf(stderr, "%s\n", usage);
        return 1;
    }

    const char * pidString = argv[1];
    printf("Using pid %s\n", pidString);

    char pagemapPath[100];
    strcpy(pagemapPath, "/proc/");
    strcat(pagemapPath, pidString);
    strcat(pagemapPath, "/pagemap");

    pagemapFd = open(pagemapPath, O_RDONLY);
    if (pagemapFd < 0) {
        perror("open pagemap");
        exit(1);
    }

    int softDirtyPages = countSoftDirtyPages(0xc0000000, 0xc0100000);
    printf("Soft-dirty pages: %d\n", softDirtyPages);

    return 0;
}
