# Chapter 4 – More info about the compiler
## 4.1 General info

Originally, Jai compiled to C, and this C code was compiled with gcc or the LLVM clang C compiler.    
Now the compiler (written in C++) generates first an IR (intermediate representation) _byte-code_, which is then turned into machine-code through the LLVM tool-chain.  
Its growing size:
    - at the initial stages: 10,000 LOC (lines of code)
	- this expanded to around 50,000 LOC after adding the LLVM backend, macros, operator overloading, multiple 	return values, unions, etc.; 
	- it jumped to around 75,000 LOC of code after adding inline assembly support, 
	- it is now some 87,000 LOC.  
The compiler source is proprietary at this time (Aug 2022), and will not be self-hosting (meaning: written in Jai) in the near future. The compiler is _very fast_: all typical debug-builds even up to 250,000 LOC are processed fully in under 1 s.

> To reduce build-time further:
> * remove the .pdb file before compiling
> * compile for the x64 backend

The compiler does not process code in a single-pass, lexically ordered way like C++ does. Instead the compiler does multiple passes to find all definitions if it needs to. This means _forward declarations are not needed_, and the _ordering of definitions and declarations is irrelevant_.

The compiler uses a hand-written _recursive descent top-down parser_. It runs _multi-threaded_ as a kind of job system.  

Here is an overall schema of the compiler architecture:  
![Compiler schema](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/compiler_schema.png)

As we see in the diagram, Jai source code is first converted to an _abstract syntax tree_ (AST), which is then converted to an internal _byte-code_.

The developer can modify the generated AST at compile-time(see Metaprogramming and macros § 26), and can access the compiler through a _compiler message loop_ (see § 30.5).


## 4.2 Internal byte-code interpreter
Jai can run programs in its byte-code during compilation, so only at compile-time, for example with the `#run` command. This is possible because the compiler contains a _byte-code interpreter_.    

When a function or program is run at compile-time, its byte-code is executed by this interpreter. The results (for example: calculation of values, construction of procedures through metaprogramming, see ??) are funneled back into the source code, and then the compiler continues as normal.  

At runtime, a Jai executable (binary) is running machine code directly. 

## 4.3 Front-end
The AST and byte-code boxes in the schema above form the front-end, which is primarily written by J. Blow.  
During compilation, the time this phase takes is for example reported as:  
_Front-end time: 0.078980 seconds_

## 4.4 Back-ends
The back-end is the part that converts the internal byte-code to produce the executable machine code.  

Two compiler backends exist: an _x64_ and an _LLVM_ backend.

The **x64 backend** was developed from scratch by J. Blow and his compiler team. It converts the internal byte-code to x64 machine code. It does fast but naive code generation, without any code optimization.  
It is intended to be used during the development phase, but because the difference in total compile-time between x64 and llvm is negligible, this isn’t necessary at this moment.  

During compilation , the time this takes is for example reported as:      	
_x64 time: 0.534119 seconds._

The **LLVM backend** is the default. It can explicitly be specified with: `jai -llvm filename.jai`, but being the default, -llvm can be left out.  
In this LLVM compiler chain, the Jai internal byte-code is further converted to LLVM IR-code.  

LLVM is an external compiler [tool-chain](https://en.wikipedia.org/wiki/LLVM) that does much more elaborate code optimization, but at the expense of slower compilation speed. You get all the LLVM optimizations for free, and the whole range of architectures and platforms LLVM targets. It's slower, but compiling a release build using LLVM is only needed for a definitive release or for specific platforms and targets.
It is intended to be used in production, when deploying an app.   

During compilation , the time this takes is for example reported as:  
_llvm time: 0.062771 seconds._

The sum of front-end time and back-end time is then reported as:    
_Compiler  time: 0.587162 seconds._    
	Front-end time + x64 time = Compiler time (for x64 backend)  
	Front-end time + llvm time = Compiler time (for llvm backend)

## 4.5 Linking
The backend compiler produces several compiler artefacts in the hidden _.build_ folder (.obj, .exp and .lib files). It is the task of the linker (_link.exe_ from MSVC on Windows, _lld-linux_ on Linux) to combine these object files and OS specific libraries statically into one output executable (.exe on Windows).  
The time this takes is for example reported as:   
_Link      time: 0.328986 seconds._

The link phase with the llvm backend on Windows can take about 3 x longer than the compilation phase.  
Finally, the sum of compilation and link time is reported as _Total time:    0.425573 seconds._
	Compiler time + Link time = Total time 

Here is a complete example output again:

```c++
Stats for Workspace 2 ("Target Program"):
Lexer lines processed: 6481 (11075 including blank lines, comments.)
Front-end time: 0.054479 seconds.
llvm      time: 0.042108 seconds.

Compiler  time: 0.096587 seconds.
Link      time: 0.328986 seconds.
Total     time: 0.425573 seconds.
```

## 4.6 Architectures  
One of the big advantages of LLVM is that it is _platform independent_: it can produce executable binary code for a wide variety of platforms, amongst them game consoles.  
Specifically at this time, Jai supports:  
    • 	x86 architecture only (limited Nintendo Switch support).  
    • 	OS / Platforms: Windows, Ubuntu Linux, limited Mac support, at least one gaming console

## 4.7 Debug and release build
While developing, you’ll work with normal _debug builds_ which is the default, because you want to have as much info as possible when something goes wrong. For example a .pdb file with debugging info is produced, stack trace info will be shown and optimizations which can hide erroneous behavior must be disabled.

When, after a thorough test process, you decide that your application is production-ready, you will want to deploy a _release version_, optimized for speed. Here you don’t want any debugging or stack-trace info, and you require all optimizations turned on. At this stage you’ll want to use the llvm backend and the -release option, as in:	`jai -release program.jai`

Alternatively and advisably (because you can fine-tune the process much more), you can define this in the Jai build-system itself (see § 30.4).

## 4.8 Options for giving code at the command-line
With `-run arg`, you can start a #run directive that parses and runs 'arg' as code.  
      Example:  `jai -run write_string(\"Hello!\n\")`   
The string Hello! is then shown at the start of the compiler output.

With `-add arg`, you can add the string 'arg' to the target program as code.  
       Example: `jai -add "a := 42"; 1_hello_sailor.jai`  
Now the variable a is know in the program, and we can print it out with for example:  `print("%", a);`

The `-verbose` option gives some extra information about what the metaprogram is doing, for example:  
	`jai -run write_string(\"Hello!\n\") -add "a := 42"; -verbose 1_hello_sailor.jai`  
shows the following at the start of the compiler output:
            
```c++
Basename: 1_hello_sailor
Path:
Input files: ["1_hello_sailor.jai"]
Add strings: ["a := 42;"]
Run strings: ["write_string("Hello!\n")"]
Plugins:     [2f2_50b8]
Hello!
Running linker: … (abbreviated)_
```
## 4.9 The Preload module
We already talked about the Basic module, which is necessary for printing. But there is also a **Preload** module, which is even more fundamental and is implicitly loaded whenever the Jai compiler is started, so it doesn’t need to be imported.
It contains the minimal definitions the compiler needs in order to compile user source code.

It contains enums for the Operating_System, the _Type_Info_ definitions, the definitions for _Allocator, Logger, Stack trace, Context, Temporary Storage, Source Code location, Array_View and Resizable_Array_.   
It also contains very low-level functions or **intrinsics** which closely mimic corresponding C functions, like the following.

   	memcpy :: (dest: *void, source: *void, count: s64) #intrinsic;
	memcmp :: (a: *void, b: *void, count: s64) -> s16  #intrinsic;
	memset :: (dest: *void, value: u8, count: s64)     #intrinsic;
   
**memcpy** copies count bytes from source to dest, see line (1). 
**memcmp** compares the first count bytes of a and b, its return value is < 0 when a is less than b, > 0 when a is greater than b and 0 when a is equal to b.  
**memset** sets count bytes of dest to value.  

> Notice the #intrinsic directive with which these functions are marked.

For some example code, See *4.1_intrinsics.jai*:
```c++
#import "Basic";

main :: () {
    x: int = 42;
    y: type_of(x);

    memcpy(*y, *x, size_of(type_of(x)));    // (1)
    print("y is %\n", y);  // => y is 42; 
}
```

## 4.10 Memory management
In Jai, developers have complete control over where and when memory is allocated. Jai does a much better job of packing values in memory so they are close together, which increases runtime performance.   
Optimal memory use places data **contiguous in memory**, that means memory is assigned in consecutive blocks (having consecutive addresses) that are adjacent to each other.
  
The compiler knows how much memory each type uses. It also knows the type of each variable. A variable's memory is allocated at type declaration, for example: variable `counter` of type int will allocate 8 bytes. It will occupy one word on a 64 bit machine. 

Variables of a basic type are stored by default in _stack_ memory for performance reasons. This memory is freed automatically when the variable is no longer needed (when it goes out of scope), see § 7.  
However most of your program's memory will be allocated in the _heap_. Jai has no automatic memory management, so the developer is responsable for releasing (freeing) that memory.
We'll later (see ??) detail the mechanisms Jai offers to do that.

For a good discussion about these two types of memory, see [Stack vs Heap](https://hackr.io/blog/stack-vs-heap).  

## 4.11 What happens when Jai starts up?
The actual entry point of any Jai program is called `__system_entry_point`, found in _modules/Runtime_Support.jai_:

```c++
#program_export "main"
__system_entry_point :: (argc: s32, argv: **u8) -> s32 #c_call {
    __jai_runtime_init(argc, argv);  // (1)

    push_context first_thread_context {
        #if ENABLE_BACKTRACE_ON_CRASH {
            Handler :: #import "Runtime_Support_Crash_Handler";
            Handler.init();
        }

        __instrumentation_first ();
        __instrumentation_second();
        
        __program_main :: () #runtime_support;
        __program_main();   // (2)
    }
    
    return 0;
}
```

This first starts up a `__jai_runtime_init(argc, argv);` proc. This proc is also defined in the _Runtime_Support_ module. Its job is to take in the command-line arguments, and initialize the primary context.
Then back in `__system_entry_point` the runtime crash handler is activated and `main` is started.