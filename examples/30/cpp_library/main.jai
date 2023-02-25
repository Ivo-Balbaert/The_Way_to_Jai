main :: () {
    #if OS == .WINDOWS {
        log("CppBase:");
        base: CppBase = ---;
        CppBase.Constructor(*base);
        defer CppBase.Destructor(*base);

        CppBase_virtual_method(*base);
    }
    {
        log("CppSub:");
        sub: CppSub = ---;
        CppSub.Constructor(*sub);
        defer CppSub.Destructor(*sub);

        CppBase_virtual_method(*sub);
    }
    {
        log("VirtualCppBase:");
        base: VirtualCppBase = ---;
        VirtualCppBase.Constructor(*base);
        defer VirtualCppBase_Destructor(*base);

        VirtualCppBase_virtual_method(*base);
        VirtualCppBase_virtual_method2(*base);
    }
    {
        log("VirtualCppSub:");
        sub: VirtualCppSub = ---;
        VirtualCppSub.Constructor(*sub);
        defer VirtualCppBase_Destructor(*sub);

        VirtualCppBase_virtual_method(*sub);
        VirtualCppBase_virtual_method2(*sub);
    }
}


#if OS == .WINDOWS {
    #load "windows.jai";
    #import "Windows";
} else #if OS == .LINUX {
    #load "linux.jai";
} else #if OS == .MACOS {
    #load "macos.jai";
} else {
    #assert(false);
}

#import "Basic";
