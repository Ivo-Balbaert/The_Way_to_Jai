# 29 Interacting with C
We compared Jai to C/C++ in § 1B - 1.1.2. In § 19.7, we discussed how to work with C strings from Jai, and discussed their differences.
In this section, we will effectively let C and Jai code work together. Jai can indicate that it will use a C function, or call into C libraries through its Foreign Function Interface (FFI).

## 29.1 Why would you call C?
Calling C is not necessary for performance reasons, benchmarks show that Jai's performance is comparable to C (see § 1B 1.1.1). But of course a whole universe of ready-made C libraries exist, that can be used off the shelf (in game development especially libraries for graphics display, see § 33).  
C can be useful to speed up the development of a project, so that you don't have to write everything in Jai from the start.  
Also it can ease the migration of an existing C project to Jai: project parts can be converted to Jai incrementally, and the Jai parts can call into the remaining C modules.

## 29.2 How to call C? The #foreign directive
To access a C function, use the **#foreign**  directive after the Jai declaration of the C function. After `#foreign` you must specify the name of the C-library that contains the function. The compiler will then import the C function with the specified name in the Jai code. You can also specify an alternative name for the function as shown in the lz4 examples below.

> #foreign specifies a foreign (C) procedure 

_Some examples:_
These statements look for C functions with respectively as names `rand`, `clock`, `strlen`, `array_count` and `printf,  with the same signature as shown, and import them from the C standard library `libc` (on Linux).    

`rand :: () -> s64                            #foreign libc;`  
`clock :: () -> s64                           #foreign libc;`  
`strlen := (s: string) -> int                 #foreign libc;`  
`array_count := (array: Any [] *) -> int      #foreign libc;`    
`printf := (s: string, args: ..[] Any) -> int #foreign libc;`    

Since these statements are used in Jai code, the signature must be in Jai syntax, using The corresponding Jai types for the original C types. The C library they come from is in these examples `libc`.  

Use the **#system_library** directive to specify as a constant an OS system file (library) for foreign functions.  
For example, declare `libc` as: `libc :: #system_library "libc";`

To use the Windows version of the C run time, specify:  `crt :: #system_library "msvcrt";`  
To use the Windows `kernel32` library, specify:          `kernel32 :: #system_library "kernel32";`  

Linking to the 3D rendering library for DirectX, version number 11 is done as follows:     
`d3d11 :: #system_library "d3d11";`

## 29.3 Mapping a dynamic library
Functions from a dynamic library (.dll or .so file) also need two directives to be specified.

The **#library** directive specifies a file (library) for foreign functions written in C, Jai or another language.  
For example, if you want to use the `lz4` fast-compression C library in your Jai code, you specify it as:  
`lz4 :: #library "liblz4";`

The path to the foreign library is best expressed as relative to the program file, for example:  
`FMOD :: #library "../../lib/fmod";`  

> Inside the "" you can write the full path to the library
> The .dll (or .so) file must be copied next to the Jai .exe 

Then you declare the functions (their signatures) from that library you want to use, for example:
```
LZ4_compressBound :: (inputSize: s32) -> s32    #foreign lz4;
LZ4_compress_fast :: (source: *u8, dest: *u8, sourceSize: s32, maxDestSize: s32, acceleration: s32)  
 -> s32  #foreign lz4;
LZ4_sizeofState :: () -> s32    #foreign lz4;
```
You can also give them another name to use in Jai code like this:
```
compress_bound :: (inputSize: s32) -> s32 #foreign lz4 "LZ4_compressBound";
compress_fast :: (source: *u8, dest: *u8, sourceSize: s32, maxDestSize: s32, acceleration: s32)  
 -> s32 #foreign lz4 "LZ4_compress_fast";
size_of_state :: () -> s32 #foreign lz4 "LZ4_sizeofState";
```

For an example of how to build a dynamic library from Jai source code and call it from another Jai file, see § 30.13.

## 29.4 Converting a C header (.h) file
Jai doesn't use header files, but C header files contain the signatures for the C functions. The following info can be helpful in converting such code:  

The conversion steps are:  
- put in the `::`
- move the return type to the end 
- add the `#foreign` library declaration
- swap the parameter types and names. 

Pay attention to the following points:  
- a C pointer to char becomes a `*u8`
- remove extraneous prefixes (i.e. const before parameters, macros, and so on)
- C references become pointers (i.e. & becomes `*`)
- almost always specify a 32-bit size for an enum, for example:  
   `IL_Result :: enum s32`, or `D3DCOMPILE_FLAGS :: enum_flags u32`.
- the size of int and float may be hard to determine; if you can't work it out from the code, comments or documentation then go for 32-bit versions; if your data comes out mangled you try a different-size type.
- rename any C parameter/variable which happens to coincide with a Jai keyword: for example: context -> ctx.
- when the code compiles and runs, check the data that's being passed back and forth from the library: incorrect values will likely indicate incorrectly sized struct members, variables, constants, or parameters.

## 29.5 Examples on Linux 
See *29.1_call_c_linux.jai*:
```c++
// This program only works on Linux!
#import "Basic";

libc :: #system_library "libc";                 // (1)

// C-functions:                                 // (2)
rand :: () -> s64                                #foreign libc;
clock :: () -> s64                               #foreign libc;
strlen :: (s: string) -> int                     #foreign libc;
printf :: (s: string, args: ..[] Any) -> int     #foreign libc;

main :: () {
   print("%\n", rand());  // => 1804289383      // (3)
   print("%\n", clock()); // => 2446
}
```

In line (1) we declare the Linux C standard library `libc`, lines (2) and following declare some C functions from that library. In lines (3) and following, we call some of these C functions from Jai.

## 29.6 Examples on Windows 
### 29.6.1 Calling system library functions
See *29.2_call_c_windows.jai*:
```c++
// This program only works on Windows!
#import "Basic";

// C library:
crt      :: #system_library "msvcrt";            // (1)
kernel32 :: #system_library "kernel32";

// C-functions:                                  // (2)
rand :: () -> s64              #foreign crt;
clock :: () -> s64             #foreign crt;
strlen :: (s: string) -> int   #foreign crt;

main :: () {
    print("%\n", rand());  // => 41               // (3)
    print("%\n", rand());  // => 18467
    print("%\n", rand());  // => 6334 
    print("%\n", clock()); // => 4 
    
    str :: "hello";
    print("Length of str is %\n", strlen(str)); // => Length of str is 1 
}
```

In line (1) we declare the Windows C standard library `crt`, lines (2) and following declare some C functions from that library. In lines (3) and following, we call some of these C functions from Jai. The length of str is 1, because C only sees a pointer to the first byte.

### 29.6.2 Calling user-defined library functions
(The source code for this example is in _examples/29/mylib_, it is shown on Windows, but the steps are the same on Linux.)

**STEPS**  
_1) Write your C source code_   
Suppose we have some useful C functions (here they are not especially useful but deliberately kept simple) gathered in a file called *my.c*:

```c++
int add_int(int a, int b) {                 // (1)
    return a + b;
}

double add_double(double a, double b) {     // (2)
    return a + b;
}
```

We want to call these functions from within Jai code.

_2) Write your Jai source code_  

See *29.5_callc.jai*:
```c++
#import "Basic";

add_int    :: (a: s32, b: s32) -> s32                #foreign my;   // (3A)
add_double :: (a: float64, b: float64) -> float64    #foreign my;   // (3B)
my         :: #library "libmy";                                     // (4)

main :: () {
    print("%\n", add_int(3, 8));            // (5A) => 11
    print("%\n", add_double(38.3, 83.5));   // (5B )=> 121.8
}
```

In lines (3A-B), we have translated the C headers of the functions in Jai, and we say that they are defined in a #foreign library called `my`. In line (4), we
tell Jai that the real library name is `libmy`. Then we can call these C functions as in lines (5A-B).

At this stage, this of course doesn't work. Compiling this program with `jai 29.5_callc.jai` gives:  
`Error: D:/Jai/The_Way_to_Jai/examples/29/mylib/libmy.dll: Dynamic library load failed. Error code 126, message: The specified module could not be found, on line (4).`    
We see that Jai looks for a dynamic library file _libmy.dll_ , which doesn't exist yet!

_3) Compile your C source code_  
Run the following command in a terminal window (we use [gcc](https://winlibs.com/) here):  
`gcc -c my.c`  
This creates an object file `my.o`, containing machine code.

_4) Make a C dynamic library (.dll or .so)_  
This is done with the -shared option, setting the output file with -o to `libmy.dll`:  
`gcc -shared -o libmy.dll my.c`
This creates a dynamic library `libmy.dll` (size: 89.650 bytes)

If we now compile our Jai program, we don't get a compiler error anymore.  
But we do get a linker error:  
`Running linker: ... D:/Jai/The_Way_to_Jai/examples/29/mylib/libmy.lib ...
LINK : fatal error LNK1181: cannot open input file 'D:\Jai\The_Way_to_Jai\examples\29\mylib\libmy.lib'`

It seems the linker needs an import library `libmy.lib`, indeed we cut out mentioning this filename in the giant linker command between ...

_5) Make a C import library (.lib)_  
This can be done with the `ar` tool from the gcc toolchain and we need the result from step 3 here. Issue the command:  
`ar rcs libmy.lib my.o`  
This creates an import library `libmy.lib` (size: 976 bytes)

A dll on Windows needs an import library (a .lib) to link it in. This import library contains only the things used during linking; it’s a smaller file because it does not contain actual code. The normal static library (also .lib) containing the full library code is much bigger and is not needed for linking. 

_6) Compile the Jai code from step 2_  
Run the command: `jai 29.5_callc.jai`  
Compiling and linking works perfect now. An executable (here `29.exe`) is produced.

_7) Run the executable from the preceding step_  
Type `29` in a terminal. This displays:
```
11
121.8
```
Splendid!

## 29.7 Callbacks and the #c_call directive 
The **#c_call** directive is used to indicate that a procedure follows C ABI conventions: it makes the procedure use the C calling convention. It is used for interacting with libraries written in C.

The **#type** directive lets us specify the expected parameters of the callback, rather than just using a *void.
`IL_Logger_Callback` is an example of a callback-function which has both directives.

See *29.3_c_call.jai*:
```c++
#import "Basic";

IL_LoggingLevel :: u16;
IL_Logger_Callback :: #type(level: IL_LoggingLevel, text: *u8, ctx: *void) -> void #c_call; // (1)

logger_callback :: (level: IL_LoggingLevel, text: *u8, ctx: *void) #c_call {  // (2)
    new_context: Context;  
    // print("I am in logger callback"); // (2B)
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

In line (1) we declare a proc called `IL_Logger_Callback` as having the signature type that follows and as following the #c_call conventions. If it doesn't return anything, `void` needs to be specified.
This is the Jai version of this C signature from a header file:
`typedef void(*IL_Logger_Callback)(IL_LoggingLevel level, const char* text, void* context);`

Then we define a concrete proc `logger_callback` which has the exact same type as `IL_Logger_Callback`. This proc creates a temporary new Context called `new_context`, and calls the proc `log` in this context to log a string `text`. This is of type `*u8`, so it could be a C string.     
When we write an actual callback procedure to use with our definition, we need to push a new context inside it. In line (2B) we see that `print` cannot be called inside a #c_call routine, but it can be called inside the `push_context` section.  
(See https://jai.community/docs?topic=137 for a more thorough discussion of this case.)

## 29.8 Getting the computer name: using #if, OS and C interaction
(Example adapted from */how_to/095_static_if.jai*)

See *29.4_get_computer_name.jai*:
```c++
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
    kernel32 :: #system_library "kernel32";
    GetComputerNameA :: (lpBuffer: *u8, nSize: *u32) -> s32 #foreign kernel32; // (1B)

    get_computer_name :: () -> string {
        buffer: [500] u8;
        size: u32 = buffer.count;
        
        success := GetComputerNameA(buffer.data, *size); 
        if success return alloc_string(buffer.data, size);
        return copy_string("unknown");
    }
} else #if OS == .LINUX {               // (2)
    libc   :: #system_library "libc";
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
```

Because the way to get to that info is OS dependent, we need to write (at least) two different `get_computer_name` procs. This is easily managed with #if (see lines (1) and (2)). We also need a platform independent routine to allocate a string; `alloc_string`.  
In Windows, we use the `GetComputerNameA` proc from the kernel32 system-library   (1B).   
In Linux, we use the `gethostname` proc from the libc system-library (2B).

Due to the #if, only the code specified for the current OS will be compiled: ine line (3), the OS-specific version of `get_computer_name` is called. In line (4), we see the different computer names that happen to be the names of my Windows- and Ubuntu machines.

## 29.9 The Bindings_Generator module
When you want to use a C/C++ library in your Jai project, getting Jai to work with it implies writing Jai signatures for all definitions in C++ .h header files. This is often an immense and painstaking work if you need to do this manually.  
Luckily, the standard distribution comes with a *Bindings_Generator* module, which automates this work by generating Jai wrappers (FFI bindings) from the C/C++ source files. This might perhaps not generate all you need. Considering most languages don’t even have a bindings generator, you'll be quite happy to use it.       
To understand how this works, we first must learn how a build file is made (see § 30). Then we will apply this for a simple for a simple example Cpp library in § 30B - 30.16.
