//
// This file was auto-generated using the following command:
//
// jai first.jai
//



CppBase :: struct {
    vtable: *CppBase_VTable;
    Constructor :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "??0CppBase@@QEAA@XZ";

    normal_method :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "?normal_method@CppBase@@QEAAXXZ";

    Destructor :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "??1CppBase@@QEAA@XZ";

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_virtual_method :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "?virtual_method@CppBase@@UEAAXXZ";

    virtual_virtual_method2 :: (this: *CppBase) -> void #cpp_method #foreign cpp_library "?virtual_method2@CppBase@@UEAAXXZ";
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

    Constructor :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "??0CppSub@@QEAA@XZ";

    normal_method :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "?normal_method@CppSub@@QEAAXXZ";

    Destructor :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "??1CppSub@@QEAA@XZ";

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_virtual_method :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "?virtual_method@CppSub@@UEAAXXZ";

    virtual_virtual_method2 :: (this: *CppSub) -> void #cpp_method #foreign cpp_library "?virtual_method2@CppSub@@UEAAXXZ";
}
#run {
    assert(size_of(CppSub) == 8, "CppSub has size % instead of 8", size_of(CppSub));
}

VirtualCppBase :: struct {
    vtable: *VirtualCppBase_VTable;
    Constructor :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "??0VirtualCppBase@@QEAA@XZ";

    normal_method :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "?normal_method@VirtualCppBase@@QEAAXXZ";

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.
    virtual_virtual_method :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "?virtual_method@VirtualCppBase@@UEAAXXZ";
    virtual_Destructor :: (this: *VirtualCppBase, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign cpp_library "??1VirtualCppBase@@UEAA@XZ";
    virtual_virtual_method2 :: (this: *VirtualCppBase) -> void #cpp_method #foreign cpp_library "?virtual_method2@VirtualCppBase@@UEAAXXZ";
}
VirtualCppBase_VTable :: struct #type_info_none {
    virtual_method: (this: *VirtualCppBase) -> void #cpp_method;
    Destructor: (this: *VirtualCppBase, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;
    virtual_method2: (this: *VirtualCppBase) -> void #cpp_method;
}

VirtualCppBase_virtual_method :: inline (this: *VirtualCppBase) { this.vtable.virtual_method(this); }
VirtualCppBase_Destructor :: inline (this: *VirtualCppBase, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }
VirtualCppBase_virtual_method2 :: inline (this: *VirtualCppBase) { this.vtable.virtual_method2(this); }

vtable :: (obj: *VirtualCppBase) -> *VirtualCppBase_VTable { return obj.vtable; }

#run {
    assert(size_of(VirtualCppBase) == 8, "VirtualCppBase has size % instead of 8", size_of(VirtualCppBase));
}

VirtualCppSub :: struct {
    #as using virtualcppbase: VirtualCppBase;
    Constructor :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "??0VirtualCppSub@@QEAA@XZ";

    normal_method :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "?normal_method@VirtualCppSub@@QEAAXXZ";

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.
    virtual_virtual_method :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "?virtual_method@VirtualCppSub@@UEAAXXZ";
    virtual_Destructor :: (this: *VirtualCppSub, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign cpp_library "??1VirtualCppSub@@UEAA@XZ";
    virtual_virtual_method2 :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "?virtual_method2@VirtualCppSub@@UEAAXXZ";
}
#run {
    assert(size_of(VirtualCppSub) == 8, "VirtualCppSub has size % instead of 8", size_of(VirtualCppSub));
}

#scope_file

#import "Basic"; // For assert

cpp_library :: #library "./cpp_library";
