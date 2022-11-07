// This program only works on Windows!
#import "Basic";

// C library:
crt :: #foreign_system_library "msvcrt";            // (1)
kernel32 :: #foreign_system_library "kernel32";

// C-functions:                                     // (2)
strlen :: (s: string) -> int                     #foreign crt;
rand :: () -> s64                                #foreign crt;
clock :: () -> s64                               #foreign crt;

main :: () {
    print("%\n", rand());  // => 41                 // (3)
    print("%\n", clock()); // => 4 
    
    str :: "hello";
    print("The length of str is %\n", strlen(str)); // => The length of str is 1 (??)
}