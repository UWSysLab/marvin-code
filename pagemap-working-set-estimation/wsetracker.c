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

int getBit(unsigned char word[8], int index) {
    int byteIndex = index / 9;
    int bitIndex = index % 8;
    return (word[byteIndex] >> bitIndex) & 1;
}

uint64_t convertBytesToLongWord(unsigned char bytes[8]) {
    uint64_t word = 0;
    for (int i = 0; i < 8; i++) {
        printf("%d: %u, %lu\n", i, bytes[i], ((uint64_t)bytes[i] << (i * 8)));
        word += ((uint64_t)bytes[i] << (i * 8));
    }
    return word;
}

uint64_t getPfn(unsigned char pagemapEntry[8]) {
    uint64_t pagemapEntryWord = convertBytesToLongWord(pagemapEntry);
    printf("pagemapEntryWord: %lu\n", pagemapEntryWord);
    uint64_t pfn = pagemapEntryWord & PFN_MASK;
    printf("pfn: %lu\n", pfn);
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

int checkPageSoftDirty(uint64_t page) {
    unsigned char word[8];
    readLongWordBytes(pagemapFd, page, word);
    int softDirtyBit = getBit(word, 55);
    return softDirtyBit;
}

int checkPageIdle(uint64_t page) {
    unsigned char word[8];
    readLongWordBytes(pagemapFd, page, word);
    uint64_t pfn = getPfn(word);

    off_t bitmapWordOffset = pfn / 64;
    unsigned char bitmapWordBytes[8];
    readLongWordBytes(idleBitmapFd, bitmapWordOffset, bitmapWordBytes);

    unsigned int bitOffset = pfn % 64;
    //uint64_t bitmapWord = convertBytesToLongWord(bitmapWordBytes);
    //int idleBit = (bitmapWord << bitOffset) & 1;
    int idleBit = getBit(bitmapWordBytes, bitOffset);
    printf("idle bit: %d\n", idleBit);

    return 0;
}

int countSoftDirtyPages(uint64_t startAddress, uint64_t endAddress) {
    if (startAddress % PAGE_SIZE != 0) {
        fprintf(stderr, "countSoftDirtyPages: start address %lu is not page-aligned\n",
                startAddress);
        exit(1);
    }
    if (endAddress % PAGE_SIZE != 0) {
        fprintf(stderr, "countSoftDirtyPages: end address %lu is not page-aligned\n",
                endAddress);
        exit(1);
    }

    uint64_t startPage = startAddress / PAGE_SIZE;
    uint64_t endPage = endAddress / PAGE_SIZE;

    int count = 0;
    for (uint64_t page = startPage; page < endPage; page++) {
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

    const char * idleBitmapPath = "/sys/kernel/mm/page_idle/bitmap";

    pagemapFd = open(pagemapPath, O_RDONLY);
    if (pagemapFd < 0) {
        perror("open pagemap");
        exit(1);
    }

    idleBitmapFd = open(idleBitmapPath, O_RDONLY);
    if (idleBitmapFd < 0) {
        perror("open idle bitmap");
        exit(1);
    }

    int softDirtyPages = countSoftDirtyPages(0xc0000000, 0xc0100000);
    printf("Soft-dirty pages: %d\n", softDirtyPages);

    checkPageIdle(0xc0000000 / PAGE_SIZE);

    return 0;
}
