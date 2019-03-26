ANDROID_TOOLCHAIN_PATH = /home/nl35/research/standalone-android-toolchain-24
ANDROID_CLANG = $(ANDROID_TOOLCHAIN_PATH)/bin/aarch64-linux-android-clang
ANDROID_CLANG++ = $(ANDROID_TOOLCHAIN_PATH)/bin/aarch64-linux-android-clang++

all: x86 arm64

x86: malloc-timer.c
	gcc -o malloc-timer-x86 malloc-timer.c

arm64: malloc-timer.c
	$(ANDROID_CLANG) -fPIE -pie -o malloc-timer-arm64 malloc-timer.c
clean:
	rm -f malloc-timer-x86
	rm -f malloc-timer-arm64
