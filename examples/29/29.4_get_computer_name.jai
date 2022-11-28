#import "Basic";

alloc_string :: (data: *u8, bytes_excluding_zero: s64) -> string { 
    count := bytes_excluding_zero;
    assert(count >= 0);
    
    s: string;
    s.count = count;
    s.data  = alloc(count);
    memcpy(s.data, data, count);

    return s;
}

#if OS == .WINDOWS {                    // (1)
    kernel32 :: #foreign_system_library "kernel32";
    GetComputerNameA :: (lpBuffer: *u8, nSize: *u32) -> s32 #foreign kernel32; // (1B)

    get_computer_name :: () -> string {
        buffer: [500] u8;
        size: u32 = buffer.count;
        
        success := GetComputerNameA(buffer.data, *size); 
        if success return alloc_string(buffer.data, size);
        return copy_string("unknown");
    }
} else #if OS == .LINUX {               // (2)
    libc   :: #foreign_system_library "libc";
    size_t :: u64;
    gethostname :: (name: *s8, namelen: size_t) -> s32 #foreign libc; // (2B)

    get_computer_name :: () -> string {
        buffer: [500] u8;

        result := gethostname(cast(*s8) buffer.data, buffer.count); 
        if result != 0 return copy_string("unknown");
        return alloc_string(buffer.data, c_style_strlen(buffer.data));
    }
} else {
    // Fall back to some other default processing
    get_computer_name :: () -> string {
        return copy_string("unknown");
    }
}
    
main :: () {
    print("OS is %\n", OS);
    name := get_computer_name();                // (3)
    defer free(name);   
    print("The computer name is: '%'\n", name); // (4)
    // On Windows:
    // => OS is Windows
    // => The computer name is: 'DESKTOP-KN14QQK'
    // On Ubuntu 21:
    // OS is Linux
    // => The computer name is: 'ivo-B460MDS3H'
}