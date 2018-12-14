ANDROID_TOOLCHAIN_PATH = /home/nl35/research/standalone-android-toolchain-24
ANDROID_CLANG = $(ANDROID_TOOLCHAIN_PATH)/bin/aarch64-linux-android-clang
ANDROID_CLANG++ = $(ANDROID_TOOLCHAIN_PATH)/bin/aarch64-linux-android-clang++

all: x86 arm64

x86: measure-memory.c
	gcc -o measure-memory-x86 measure-memory.c

arm64: measure-memory.c
	$(ANDROID_CLANG) -fPIE -pie -o measure-memory-arm64 measure-memory.c
clean:
	rm -f measure-memory-x86
	rm -f measure-memory-arm64
