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

    bool done = false;
    int sum = 0;
    while (!done) {
        char input = 0;
        std::cin >> input;
        switch (input) {
        case 'w':
            writeMemory(startAddr, length, 'w');
            std::cout << "Wrote memory." << std::endl;
            break;
        case 'r':
            sum = readMemory(startAddr, length);
            std::cout << "Read memory; sum is " << sum << std::endl;
            break;
        case 'd':
            done = true;
            std::cout << "Exiting program." << std::endl;
            break;
        default:
            std::cout << "Unrecognized input: " << input << std::endl;
        }
    }

    return 0;
}
