/*
 * This file started life by being copied from wsetracker.c. I made a separate
 * file to prevent wsetracker.c from getting too cluttered, but this approach
 * has the downside of having some duplicated code.
 */

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


int getSwapBit(uint64_t page) {
    unsigned char word[8];
    readLongWordBytes(pagemapFd, page, word);
    int swapBit = getBit(word, 62);
    return swapBit;
}

int countSwappedPages(uint64_t startAddress, uint64_t endAddress) {
    uint64_t startPage;
    uint64_t endPage;
    getPageRangeChecked(startAddress, endAddress, &startPage, &endPage);

    int count = 0;
    for (uint64_t page = startPage; page < endPage; page++) {
        int swapBit = getSwapBit(page);
        count += swapBit;
    }
    return count;
}

int main(int argc, char ** argv) {
    const char * usage = "usage: ./swapinspector target-pid start-addr end-addr";
    if (argc < 4) {
        fprintf(stderr, "%s\n", usage);
        return 1;
    }

    const char * pidString = argv[1];
    uint64_t startAddr = atoll(argv[2]);
    uint64_t endAddr = atoll(argv[3]);
    printf("Using pid %s, startAddr %lu, endAddr %lu\n", pidString, startAddr, endAddr);

    char pagemapPath[100];
    strcpy(pagemapPath, "/proc/");
    strcat(pagemapPath, pidString);
    strcat(pagemapPath, "/pagemap");

    pagemapFd = open(pagemapPath, O_RDONLY);
    if (pagemapFd < 0) {
        perror("open pagemap");
        exit(1);
    }

    int count = countSwappedPages(startAddr, endAddr);
    printf("Swapped pages: %d\n", count);

    return 0;
}
