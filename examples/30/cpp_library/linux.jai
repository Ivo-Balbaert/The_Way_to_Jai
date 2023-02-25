//
// This file was auto-generated using the following command:
//
// jai modules/Bindings_Generator/examples/first.jai
//



CppBase :: struct {
    vtable: *CppBase_VTable;
    normal_method :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "_ZN7CppBase13normal_methodEv";

    Destructor_Base :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "_ZN7CppBaseD2Ev";
    Destructor :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "_ZN7CppBaseD1Ev";

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_virtual_method :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "_ZN7CppBase14virtual_methodEv";

    virtual_virtual_method2 :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "_ZN7CppBase15virtual_method2Ev";
}
CppBase_VTable :: struct #type_info_none {
    virtual_method: (this: *CppBase) -> void #cpp_method;

    virtual_method2: (this: *CppBase) -> void #cpp_method;
}

CppBase_virtual_method :: inline (this: *CppBase) { this.vtable.virtual_method(this); }

CppBase_virtual_method2 :: inline (this: *CppBase) { this.vtable.virtual_method2(this); }

vtable :: (obj: *CppBase) -> *CppBase_VTable { return obj.vtable; }

#run {
    assert(size_of(CppBase) == 8, "CppBase has size % instead of 8", size_of(CppBase));
}

CppSub :: struct {
    #as using cppbase: CppBase;

    Constructor :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "_ZN6CppSubC1Ev";

    normal_method :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "_ZN6CppSub13normal_methodEv";

    Destructor_Base :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "_ZN6CppSubD2Ev";
    Destructor :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "_ZN6CppSubD1Ev";

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_virtual_method :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "_ZN6CppSub14virtual_methodEv";

    virtual_virtual_method2 :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "_ZN6CppSub15virtual_method2Ev";
}
#run {
    assert(size_of(type_of(CppSub.cppbase)) == 8, "CppSub.cppbase has unexpected size % instead of 8", size_of(type_of(CppSub.cppbase)));
    assert(size_of(CppSub) == 8, "CppSub has size % instead of 8", size_of(CppSub));
}

VirtualCppBase :: struct {
    vtable: *VirtualCppBase_VTable;
    Constructor :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "_ZN14VirtualCppBaseC1Ev";

    normal_method :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "_ZN14VirtualCppBase13normal_methodEv";

    Destructor_Base :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "_ZN14VirtualCppBaseD2Ev";

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_virtual_method :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "_ZN14VirtualCppBase14virtual_methodEv";
    virtual_Destructor :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "_ZN14VirtualCppBaseD1Ev";
    virtual_Destructor_Deleting :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "_ZN14VirtualCppBaseD0Ev";
    virtual_virtual_method2 :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "_ZN14VirtualCppBase15virtual_method2Ev";
}
VirtualCppBase_VTable :: struct #type_info_none {
    virtual_method: (this: *VirtualCppBase) -> void #cpp_method;
    Destructor: (this: *VirtualCppBase) -> void #cpp_method;
    Destructor_Deleting: (this: *VirtualCppBase) -> void #cpp_method;
    virtual_method2: (this: *VirtualCppBase) -> void #cpp_method;
}

VirtualCppBase_virtual_method :: inline (this: *VirtualCppBase) { this.vtable.virtual_method(this); }
VirtualCppBase_Destructor :: inline (this: *VirtualCppBase) { this.vtable.Destructor(this); }
VirtualCppBase_Destructor_Deleting :: inline (this: *VirtualCppBase) { this.vtable.Destructor_Deleting(this); }
VirtualCppBase_virtual_method2 :: inline (this: *VirtualCppBase) { this.vtable.virtual_method2(this); }

vtable :: (obj: *VirtualCppBase) -> *VirtualCppBase_VTable { return obj.vtable; }

#run {
    assert(size_of(VirtualCppBase) == 8, "VirtualCppBase has size % instead of 8", size_of(VirtualCppBase));
}

VirtualCppSub :: struct {
    #as using virtualcppbase: VirtualCppBase;
    Constructor :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "_ZN13VirtualCppSubC1Ev";

    normal_method :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "_ZN13VirtualCppSub13normal_methodEv";

    Destructor_Base :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "_ZN13VirtualCppSubD2Ev";

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_virtual_method :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "_ZN13VirtualCppSub14virtual_methodEv";
    virtual_Destructor :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "_ZN13VirtualCppSubD1Ev";
    virtual_Destructor_Deleting :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "_ZN13VirtualCppSubD0Ev";
    virtual_virtual_method2 :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "_ZN13VirtualCppSub15virtual_method2Ev";
}
#run {
    assert(size_of(type_of(VirtualCppSub.virtualcppbase)) == 8, "VirtualCppSub.virtualcppbase has unexpected size % instead of 8", size_of(type_of(VirtualCppSub.virtualcppbase)));
    assert(size_of(VirtualCppSub) == 8, "VirtualCppSub has size % instead of 8", size_of(VirtualCppSub));
}

#scope_file

#import "Basic"; // For assert
cpp_library :: #library "./cpp_library";
