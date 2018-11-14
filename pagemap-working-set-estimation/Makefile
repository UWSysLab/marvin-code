ANDROID_TOOLCHAIN_PATH = /home/nl35/research/standalone-android-toolchain-24
ANDROID_CLANG = $(ANDROID_TOOLCHAIN_PATH)/bin/aarch64-linux-android-clang
ANDROID_CLANG++ = $(ANDROID_TOOLCHAIN_PATH)/bin/aarch64-linux-android-clang++

all: testapp-x86 wsetracker-x86 testapp-arm64 wsetracker-arm64

testapp-x86: testapp.cpp
	g++ -o testapp-x86 testapp.cpp

wsetracker-x86: wsetracker.c
	gcc -o wsetracker-x86 wsetracker.c

testapp-arm64: testapp.cpp
	$(ANDROID_CLANG++) -fPIE -pie -static-libstdc++ -o testapp-arm64 testapp.cpp

wsetracker-arm64: wsetracker.c
	$(ANDROID_CLANG) -fPIE -pie -o wsetracker-arm64 wsetracker.c

clean:
	rm testapp-x86
	rm wsetracker-x86
	rm testapp-arm64
	rm wsetracker-arm64
