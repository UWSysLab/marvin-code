//
// Created by nl35 on 4/27/18.
//

#ifndef SWAPTESTER_NATIVE_LIB_H
#define SWAPTESTER_NATIVE_LIB_H

#include <jni.h>

int doTheThing();

extern "C" {
    JNIEXPORT jboolean JNICALL Java_edu_washington_cs_nl35_swaptester_MainActivity_readGlobalRef(JNIEnv * env, jobject obj);
    JNIEXPORT void JNICALL Java_edu_washington_cs_nl35_swaptester_MainActivity_setGlobalRef(JNIEnv * env, jobject obj);
    JNIEXPORT jboolean JNICALL Java_edu_washington_cs_nl35_swaptester_MainActivity_readLocalRef(JNIEnv * env, jobject obj);
}

#endif //SWAPTESTER_NATIVE_LIB_H
