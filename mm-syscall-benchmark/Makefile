ANDROID_TOOLCHAIN_PATH = /home/nl35/research/standalone-android-toolchain-24
ANDROID_CLANG = $(ANDROID_TOOLCHAIN_PATH)/bin/aarch64-linux-android-clang
ANDROID_CLANG++ = $(ANDROID_TOOLCHAIN_PATH)/bin/aarch64-linux-android-clang++

all: mm-syscall-benchmark-x86 mm-syscall-benchmark-arm64

mm-syscall-benchmark-x86: mm-syscall-benchmark.c
	gcc -o mm-syscall-benchmark-x86 mm-syscall-benchmark.c

mm-syscall-benchmark-arm64: mm-syscall-benchmark.c
	$(ANDROID_CLANG) -fPIE -pie -o mm-syscall-benchmark-arm64 mm-syscall-benchmark.c
clean:
	rm mm-syscall-benchmark-x86
	rm mm-syscall-benchmark-arm64
