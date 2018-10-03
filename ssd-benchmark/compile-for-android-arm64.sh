STANDALONE_TOOLCHAIN_DIR=~/research/standalone-android-toolchain-24
$STANDALONE_TOOLCHAIN_DIR/bin/aarch64-linux-android-clang -fPIE -pie -o benchmark-arm64 benchmark.c
$STANDALONE_TOOLCHAIN_DIR/bin/aarch64-linux-android-clang++ -fPIE -pie -static-libstdc++ -o cpp-benchmark-arm64 cpp-benchmark.cc
