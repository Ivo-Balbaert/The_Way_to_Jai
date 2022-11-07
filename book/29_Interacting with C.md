# 29 Interacting with C

We compared Jai to C/C++ in § 1B - 1.1.2. In § 19.7, we discussed how to work with C strings from Jai.
In this section, we will effectively let C and Jai code work together. Jai can indicate that it will use a C function, or call into C libraries through its Foreign Function Interface (FFI).

## 29.1 Why would you call C?
Calling C is not necessary for performance reasons, but of course a whole universe of ready-made C libraries exist, that can be used of the shelf. So C can be useful to speed up the development of a project, so that you don't have to write everything in Jai from the start.  
Also it can ease the migration of an existing C project to Jzi: project parts can be converted to Jai incrementally, and the Jai parts can call into the remaining C modules.

## 29.2 How to call C? The #foreign directives
To access a C function, use the **#foreign**  directive after the Jai declaration of the C function. The compiler will then import the C function with the specified name in the code. After `#foreign` you can optionally specify an alternative name for the function.

> #foreign		specifies a foreign (C) procedure 

Some examples:	
This statement looks for a C function with the name `strlen` and with the same signature and imports it from the C standard library `libc` (on Linux).
`strlen := (s: string) -> int     #foreign libc;`

`array_count := (array: Any [] *) -> int       #foreign libc;`
`printf := (s: string, args: ..[] Any) -> int  #foreign libc;`
`rand :: () -> s64                             #foreign libc;`
`clock :: () -> s64                            #foreign libc;`	

The C library (here libc) also needs to be declared.
Use the **#foreign_system_library** directive to specify as a constant a system file (library) for foreign functions. For example, declare `libc` as: `libc :: #foreign_system_library "libc";`  
To use the Windows version of the C run time, specify:  `crt :: #foreign_system_library "msvcrt";`  
To use the Windows `kernel32` library, specify:         `kernel32 :: #foreign_system_library "kernel32";`  

The **#foreign_library** directive specifies a file (library) for foreign functions. For example, if you want to use the `lz4` fast-compression C library in your Jai code, you specify it as:
`lz4 :: #foreign_library "liblz4";`

Then you declare the functions from that library you want to use, for example:
```
LZ4_compressBound :: (inputSize: s32) -> s32 #foreign lz4;
LZ4_compress_fast :: (source: *u8, dest: *u8, sourceSize: s32, maxDestSize: s32, acceleration: s32) -> s32 #foreign lz4;
LZ4_sizeofState :: () -> s32 #foreign lz4;
```

You can also give them another name to use in Jai code like this:
```
compress_bound :: (inputSize: s32) -> s32 #foreign lz4 "LZ4_compressBound";
compress_fast :: (source: *u8, dest: *u8, sourceSize: s32, maxDestSize: s32, acceleration: s32) -> s32 #foreign lz4 "LZ4_compress_fast";
size_of_state :: () -> s32 #foreign lz4 "LZ4_sizeofState";
```

## 29.3 Examples on Linux 
See _29.1_call_c_linux.jai_:
```c++
// This program only works on Linux!
#import "Basic";

libc :: #foreign_system_library "libc";         // (1)

// C-functions:                                 // (2)
strlen :: (s: string) -> int                     #foreign libc;
printf :: (s: string, args: ..[] Any) -> int     #foreign libc;
rand :: () -> s64                                #foreign libc;
clock :: () -> s64                               #foreign libc;

main :: () {
   print("%\n", rand());  // => 1804289383      // (3)
   print("%\n", clock()); // => 2446
}
```

In line (1) we declare the Linux C standard library `libc`, lines (2) and following declare some C function from that library. In lines (3) and following, we call some of these C functions from Jai.

## 29.4 Examples on Windows 
See _29.1_call_c_windows.jai_:
```c++
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
    print("Length of str is %\n", strlen(str)); // => Length of str is 1 (??)
}
```

In line (1) we declare the Windows C standard library `crt`, lines (2) and following declare some C function from that library. In lines (3) and following, we call some of these C functions from Jai.

## 29.5 The #c_call directive 
The **#c_call** directive is used to indicate that a procedure follows C ABI conventions: it makes the procedure use the C calling convention. It is Used for interacting with libraries written in C. 
