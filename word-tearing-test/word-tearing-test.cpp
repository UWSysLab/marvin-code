#include <iostream>
#include <thread>

/*
 * A C++ version of the word-tearing test program from the Java 7 spec:
 * https://docs.oracle.com/javase/specs/jls/se7/html/jls-17.html#jls-17.6
 */

const int LENGTH = 8;
const int ITERS = 1000000;
char counts[LENGTH];
std::thread * threads[LENGTH];

void run(int id) {
    char v = 0;
    for (int i = 0; i < ITERS; i++) {
        char v2 = counts[id];
        if (v != v2) {
            std::cout << "Word-Tearing found: counts[" << id << "] = " << static_cast<int>(v2)
                      << ", should be " << static_cast<int>(v) << std::endl;
            return;
        }
        v++;
        counts[id] = v;
    }
}

int main() {
    for (int i = 0; i < LENGTH; i++) {
        threads[i] = new std::thread(run, i);
    }

    for (int i = 0; i < LENGTH; i++) {
        threads[i]->join();
        delete threads[i];
    }
    std::cout << "Done." << std::endl;
}
