//
// Created by nl35 on 4/27/18.
//

#include "native-lib.h"

jobject arrayGlobalRef;

JNIEXPORT jboolean JNICALL Java_edu_washington_cs_nl35_swaptester_MainActivity_readGlobalRef(JNIEnv * env, jobject obj) {
    jbooleanArray array = (jbooleanArray)arrayGlobalRef;
    jboolean * nativeArray = env->GetBooleanArrayElements(array, NULL);
    return nativeArray[0];
}

JNIEXPORT void JNICALL Java_edu_washington_cs_nl35_swaptester_MainActivity_setGlobalRef(JNIEnv * env, jobject obj) {
    jclass clazz = env->GetObjectClass(obj);
    jfieldID fieldId = env->GetFieldID(clazz, "testBooleanArray", "[Z");
    jobject arrayAsObj = env->GetObjectField(obj, fieldId);
    arrayGlobalRef = env->NewGlobalRef(arrayAsObj);
}

JNIEXPORT jboolean JNICALL Java_edu_washington_cs_nl35_swaptester_MainActivity_readLocalRef(JNIEnv * env, jobject obj) {
    jclass clazz = env->GetObjectClass(obj);
    jfieldID fieldId = env->GetFieldID(clazz, "testBooleanArray", "[Z");
    jobject arrayAsObj = env->GetObjectField(obj, fieldId);
    jbooleanArray array = (jbooleanArray)arrayAsObj;
    jboolean * nativeArray = env->GetBooleanArrayElements(array, NULL);
    return nativeArray[0];
}