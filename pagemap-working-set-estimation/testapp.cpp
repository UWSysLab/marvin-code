#include <iostream>
#include <sys/mman.h>

void writeMemory(void * startAddr, size_t length, char val) {
    for (int i = 0; i < length; i++) {
        *(((char *)startAddr) + i) = val;
    }
}

int readMemory(void * startAddr, size_t length) {
    int sum = 0;
    for (int i = 0; i < length; i++) {
        sum += *(((char *)startAddr) + i);
    }
    return sum;
}

int main() {
    void * startAddr = (void *)0xc0000000;
    size_t length = 1 * 1024 * 1024;
    mmap(startAddr, length, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);
    *((int *)startAddr) = 4;
    std::cout << "Hello world!" << std::endl;
    writeMemory(startAddr, length, 'a');
    int sum = readMemory(startAddr, length);
    std::cout << sum << std::endl;
    writeMemory(startAddr, length, 'b');
    sum = readMemory(startAddr, length);
    std::cout << sum << std::endl;
    return 0;
}
