#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#ifndef PAGE_SIZE
#define PAGE_SIZE 4096
#endif

const uint64_t PFN_MASK = 0x7FFFFFFFFFFFFF;

int pagemapFd = -1;
int idleBitmapFd = -1;
int pageFlagsFd = -1;

int getBit(unsigned char word[8], int index) {
    int byteIndex = index / 8;
    int bitIndex = index % 8;
    return (word[byteIndex] >> bitIndex) & 1;
}

void setBit(unsigned char word[8], int index) {
    int byteIndex = index / 8;
    int bitIndex = index % 8;
    word[byteIndex] = word[byteIndex] | (1 << bitIndex);
}

uint64_t convertBytesToLongWord(unsigned char bytes[8]) {
    uint64_t word = 0;
    for (int i = 0; i < 8; i++) {
        word += ((uint64_t)bytes[i] << (i * 8));
    }
    return word;
}

uint64_t getPfn(unsigned char pagemapEntry[8]) {
    uint64_t pagemapEntryWord = convertBytesToLongWord(pagemapEntry);
    uint64_t pfn = pagemapEntryWord & PFN_MASK;
    return pfn;
}

void readLongWordBytes(int fd, uint64_t wordOffset, unsigned char output[8]) {
    off_t offset = wordOffset * 8;
    off_t retOffset = lseek(fd, offset, SEEK_SET);
    if (retOffset < 0) {
        perror("lseek");
        exit(1);
    }

    ssize_t bytesRead = read(fd, output, 8);
    if (bytesRead < 0) {
        perror("read");
        exit(1);
    }
}

void writeLongWordBytes(int fd, uint64_t wordOffset, unsigned char input[8]) {
    off_t offset = wordOffset * 8;
    off_t retOffset = lseek(fd, offset, SEEK_SET);
    if (retOffset < 0) {
        perror("lseek");
        exit(1);
    }

    ssize_t bytesWritten = write(fd, input, 8);
    if (bytesWritten < 0) {
        perror("write");
        exit(1);
    }
}

int getPageFlag(uint64_t page, int flagOffset) {
    unsigned char pagemapEntry[8];
    readLongWordBytes(pagemapFd, page, pagemapEntry);
    uint64_t pfn = getPfn(pagemapEntry);
    if (pfn == 0) {
        return -1;
    }

    unsigned char pageFlags[8];
    readLongWordBytes(pageFlagsFd, pfn, pageFlags);

    return getBit(pageFlags, flagOffset);
}


int checkPageSoftDirty(uint64_t page) {
    unsigned char word[8];
    readLongWordBytes(pagemapFd, page, word);
    int softDirtyBit = getBit(word, 55);
    return softDirtyBit;
}

int checkPageNonIdle(uint64_t page) {
    unsigned char word[8];
    readLongWordBytes(pagemapFd, page, word);
    uint64_t pfn = getPfn(word);
    if (pfn == 0) {
        // If there is no PFN, then the page is not mapped (?). In that case,
        // count it as idle.
        return 0;
    }

    off_t bitmapWordOffset = pfn / 64;
    unsigned char bitmapWordBytes[8];
    readLongWordBytes(idleBitmapFd, bitmapWordOffset, bitmapWordBytes);

    unsigned int bitOffset = pfn % 64;
    int idleBit = getBit(bitmapWordBytes, bitOffset);

    return !idleBit;
}

void markPageIdle(uint64_t page) {
    unsigned char word[8];
    readLongWordBytes(pagemapFd, page, word);
    uint64_t pfn = getPfn(word);

    off_t bitmapWordOffset = pfn / 64;
    unsigned char bitmapWordBytes[8];
    readLongWordBytes(idleBitmapFd, bitmapWordOffset, bitmapWordBytes);

    unsigned int bitOffset = pfn % 64;
    setBit(bitmapWordBytes, bitOffset);

    writeLongWordBytes(idleBitmapFd, bitmapWordOffset, bitmapWordBytes);
}

void getPageRangeChecked(uint64_t startAddress, uint64_t endAddress, uint64_t * startPage, uint64_t * endPage) {
    if (startAddress % PAGE_SIZE != 0) {
        fprintf(stderr, "Start address %lu is not page-aligned\n",
                startAddress);
        exit(1);
    }
    if (endAddress % PAGE_SIZE != 0) {
        fprintf(stderr, "End address %lu is not page-aligned\n",
                endAddress);
        exit(1);
    }

    *startPage = startAddress / PAGE_SIZE;
    *endPage = endAddress / PAGE_SIZE;
}

int countSoftDirtyPages(uint64_t startAddress, uint64_t endAddress) {
    uint64_t startPage;
    uint64_t endPage;
    getPageRangeChecked(startAddress, endAddress, &startPage, &endPage);

    int count = 0;
    for (uint64_t page = startPage; page < endPage; page++) {
        int isSoftDirty = checkPageSoftDirty(page);
        count += isSoftDirty;
    }
    return count;
}

int countActivePages(uint64_t startAddress, uint64_t endAddress) {
    uint64_t startPage;
    uint64_t endPage;
    getPageRangeChecked(startAddress, endAddress, &startPage, &endPage);

    int count = 0;
    for (uint64_t page = startPage; page < endPage; page++) {
        int activeFlag = getPageFlag(page, 6);
        if (activeFlag == 1) {
            count += activeFlag;
        }
    }
    return count;
}

int countNonIdlePages(uint64_t startAddress, uint64_t endAddress) {
    uint64_t startPage;
    uint64_t endPage;
    getPageRangeChecked(startAddress, endAddress, &startPage, &endPage);

    int count = 0;
    for (uint64_t page = startPage; page < endPage; page++) {
        int isNonIdle = checkPageNonIdle(page);
        count += isNonIdle;
    }
    return count;
}

void markIdlePages(uint64_t startAddress, uint64_t endAddress) {
    uint64_t startPage;
    uint64_t endPage;
    getPageRangeChecked(startAddress, endAddress, &startPage, &endPage);

    for (uint64_t page = startPage; page < endPage; page++) {
        markPageIdle(page);
    }
}

int main(int argc, char ** argv) {
    const char * usage = "usage: ./wsetracker target-pid start-addr end-addr r|w|c";
    if (argc < 5) {
        fprintf(stderr, "%s\n", usage);
        return 1;
    }

    const char * pidString = argv[1];
    uint64_t startAddr = atoll(argv[2]);
    uint64_t endAddr = atoll(argv[3]);
    const char op = argv[4][0];
    printf("Using pid %s, startAddr %lu, endAddr %lu, op %c\n", pidString, startAddr, endAddr, op);

    char pagemapPath[100];
    strcpy(pagemapPath, "/proc/");
    strcat(pagemapPath, pidString);
    strcat(pagemapPath, "/pagemap");

    const char * idleBitmapPath = "/sys/kernel/mm/page_idle/bitmap";
    const char * pageFlagsPath = "/proc/kpageflags";

    pagemapFd = open(pagemapPath, O_RDONLY);
    if (pagemapFd < 0) {
        perror("open pagemap");
        exit(1);
    }

    idleBitmapFd = open(idleBitmapPath, O_RDWR);
    if (idleBitmapFd < 0) {
        perror("open idle bitmap");
        exit(1);
    }

    pageFlagsFd = open(pageFlagsPath, O_RDONLY);
    if (pageFlagsFd < 0) {
        perror("open kpageflags");
        exit(1);
    }

    int count = 0;
    switch(op) {
    case 'w':
        count = countSoftDirtyPages(startAddr, endAddr);
        printf("Soft-dirty pages: %d\n", count);
        break;
    case 'r':
        count = countNonIdlePages(startAddr, endAddr);
        printf("Non-idle pages: %d\n", count);
        break;
    case 'c':
        markIdlePages(startAddr, endAddr);
        printf("Marked pages idle.\n");
        break;
    case 'a':
        count = countActivePages(startAddr, endAddr);
        printf("Active pages: %d\n", count);
        break;
    default:
        printf("Unrecognized op: %c\n", op);
    }

    return 0;
}
