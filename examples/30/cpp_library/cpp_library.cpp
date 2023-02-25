#include <stdio.h>

#include "cpp_library.h"

CppBase::~CppBase() {
    printf("~CppBase\n");
}

void CppBase::normal_method() {
    printf("CppBase::normal_method\n");
}

void CppBase::virtual_method() {
    printf("CppBase::virtual_method\n");
}

void CppBase::virtual_method2() {
    printf("CppBase::virtual_method2\n");
}

CppSub::~CppSub() {
    printf("~CppSub\n");
}

void CppSub::normal_method() {
    printf("CppSub::normal_method\n");
}

void CppSub::virtual_method() {
    printf("CppSub::virtual_method\n");
}

void CppSub::virtual_method2() {
    printf("CppSub::virtual_method2\n");
}

VirtualCppBase::VirtualCppBase() {
    printf("VirtualCppBase\n");
}
VirtualCppBase::~VirtualCppBase() {
    printf("~VirtualCppBase\n");
}

void VirtualCppBase::normal_method() {
    printf("VirtualCppBase::normal_method\n");
}

void VirtualCppBase::virtual_method() {
    printf("VirtualCppBase::virtual_method\n");
}

void VirtualCppBase::virtual_method2() {
    printf("VirtualCppBase::virtual_method2\n");
}


VirtualCppSub::VirtualCppSub() {
    printf("VirtualCppSub\n");
}
VirtualCppSub::~VirtualCppSub() {
    printf("~VirtualCppSub\n");
}

void VirtualCppSub::normal_method() {
    printf("VirtualCppSub::normal_method\n");
}

void VirtualCppSub::virtual_method() {
    printf("VirtualCppSub::virtual_method\n");
}

void VirtualCppSub::virtual_method2() {
    printf("VirtualCppSub::virtual_method2\n");
}
