#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

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
    printf("Pagemap path: %s\n", pagemapPath);

    int pagemapFd = open(pagemapPath, O_RDONLY);
    printf("pagemapFd: %d\n", pagemapFd);
    off_t offset = lseek(pagemapFd, 8, SEEK_SET);
    printf("offset: %ld\n", offset);
    char word[8];
    ssize_t bytesRead = read(pagemapFd, word, 8);
    printf("bytes read: %ld\n", bytesRead);
    for (int i = 0; i < 8; i++) {
        printf("%d\n", (int)word[i]);
    }

    return 0;
}
