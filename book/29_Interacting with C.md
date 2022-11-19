# 29 Interacting with C

We compared Jai to C/C++ in § 1B - 1.1.2. In § 19.7, we discussed how to work with C strings from Jai.
In this section, we will effectively let C and Jai code work together. Jai can indicate that it will use a C function, or call into C libraries through its Foreign Function Interface (FFI).

## 29.1 Why would you call C?
Calling C is not necessary for performance reasons, but of course a whole universe of ready-made C libraries exist, that can be used of the shelf. So C can be useful to speed up the development of a project, so that you don't have to write everything in Jai from the start.  
Also it can ease the migration of an existing C project to Jzi: project parts can be converted to Jai incrementally, and the Jai parts can call into the remaining C modules.

## 29.2 How to call C? The #foreign directives
To access a C function, use the **#foreign**  directive after the Jai declaration of the C function. After `#foreign` you must specify the name of the library where the function is located in. The compiler will then import the C function with the specified name in the code. You can also specify an alternative name for the function as shown in the lz4 examples below.

> #foreign	library	specifies a foreign (C) procedure 

Some examples:	
This statement looks for a C function with the name `strlen` and with the same signature and imports it from the C standard library `libc` (on Linux).  
`strlen := (s: string) -> int     #foreign libc;`  
`array_count := (array: Any [] *) -> int       #foreign libc;`  
`printf := (s: string, args: ..[] Any) -> int  #foreign libc;`  
`rand :: () -> s64                             #foreign libc;`  
`clock :: () -> s64                            #foreign libc;`  	

The C library is here libc.  
Use the **#foreign_system_library** directive to specify as a constant a system file (library) for foreign functions.  
For example, declare `libc` as: `libc :: #foreign_system_library "libc";`  
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
See *29.1_call_c_linux.jai*:
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
See *29.2_call_c_windows.jai*:
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
The **#c_call** directive is used to indicate that a procedure follows C ABI conventions: it makes the procedure use the C calling convention. It is used for interacting with libraries written in C. 

See *29.3_c_call.jai*:
```c++
#import "Basic";

IL_LoggingLevel :: u16;
IL_Logger_Callback :: #type(level: IL_LoggingLevel, text: *u8, ctx: *void) -> void #c_call; // (1)

logger_callback :: (level: IL_LoggingLevel, text: *u8, ctx: *void) #c_call {  // (2)
    new_context:Context;                                       // print("I am in logger callback"); // (2B)
    // => Error: Cannot call into a native procedure, 
    // from a #c_call procedure, without using push_context.

    push_context new_context {
        log("%", to_string(text));
        print("I am in logger callback");
    }
}

main :: () {
    logger_callback(4, "You have been logged!", null);
    // => I am in logger callback
    // => You have been logged!
}
```

In line (1) we define a proc called `IL_Logger_Callback` as having the signature type that follows and as following the #c_call conventions (we re-used the example from § 26.13). Then we define a concrete proc `logger_callback` which has the exact same type as `IL_Logger_Callback`. This proc create a temporary new Context called new_context, and calls the proc `log` in this context to log a text string. text is of type `*u8`, so could be a C string.     
In line (2B) we see that `print` cannot be called inside a #c_call routine, but it can be called inside the `push_context` section.