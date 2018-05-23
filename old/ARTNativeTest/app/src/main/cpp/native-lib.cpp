#include <jni.h>
#include <string>

extern "C"
JNIEXPORT jstring

JNICALL
Java_edu_washington_cs_nl35_artnativetest_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}

int counter = 0;

extern "C"
JNIEXPORT int JNICALL Java_edu_washington_cs_nl35_artnativetest_MainActivity_getCounter(
        JNIEnv *env,
        jobject /* this */) {
    counter++;
    return counter;
}