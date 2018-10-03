#include <chrono>
#include <cstring>
#include <fstream>
#include <iostream>

int main(int argc, char ** argv) {
    const int FILE_SIZE = 256 * 1024 * 1024; // bytes
    const std::string FILE_NAME = "cpptempfile";
    const std::string USAGE_STR("usage: ./cpp-benchmark {read|write} block_size");

    bool doWrites;
    int blockSize; // bytes

    if (argc < 3) {
        std::cerr << USAGE_STR << std::endl;
        std::exit(1);
    }

    if (strcmp(argv[1], "read") == 0) {
        doWrites = false;
    }
    else if (strcmp(argv[1], "write") == 0) {
        doWrites = true;
    }
    else {
        std::cerr << USAGE_STR << std::endl;
        std::exit(1);
    }

    blockSize = atoi(argv[2]);
    if (blockSize == 0) {
        std::cerr << USAGE_STR << std::endl;
        std::exit(1);
    }

    char * buf = new char[blockSize];

    std::fstream file;
    if (doWrites) {
        file.open(FILE_NAME, std::fstream::binary | std::fstream::in | std::fstream::out | std::fstream::trunc);
    }
    else {
        file.open(FILE_NAME, std::fstream::binary | std::fstream::in | std::fstream::out);
    }
    for (int i = 0; i < FILE_SIZE / blockSize; i++) {
        if (doWrites) {
            file.write(buf, blockSize);
        }
        else {
            file.read(buf, blockSize);
        }
    }
    file.close();
    std::cout << "fstream is good? " << file.good() << std::endl;

    delete[] buf;

    return 0;
}
