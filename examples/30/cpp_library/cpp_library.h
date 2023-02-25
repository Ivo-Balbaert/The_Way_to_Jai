#pragma once

#include <stdio.h>

#ifdef WIN32
#define DLL_API __declspec(dllexport)
#else
#define DLL_API 
#endif

struct CppBase {
    DLL_API CppBase() {
        printf("CppBase\n");
    }

    DLL_API void normal_method();
    DLL_API virtual void virtual_method();
    DLL_API ~CppBase();
    DLL_API virtual void virtual_method2();
};

struct CppSub : public CppBase {
    DLL_API CppSub();

    DLL_API void normal_method();
    DLL_API virtual void virtual_method();
    DLL_API ~CppSub();
    DLL_API virtual void virtual_method2();
};


struct VirtualCppBase {
    DLL_API VirtualCppBase();

    DLL_API void normal_method();
    DLL_API virtual void virtual_method();
    DLL_API virtual ~VirtualCppBase();
    DLL_API virtual void virtual_method2();
};

struct VirtualCppSub : public VirtualCppBase {
    DLL_API VirtualCppSub();

    DLL_API void normal_method();
    DLL_API virtual void virtual_method();
    DLL_API ~VirtualCppSub();
    DLL_API virtual void virtual_method2();
};

CppSub::CppSub() {
    printf("CppSub\n");
}

