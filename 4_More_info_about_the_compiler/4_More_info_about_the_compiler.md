# Chapter 4 – More info about the compiler
## 4.1 Some info about the compiler

Originally, Jai compiled to C, then C was compiled with gcc or the LLVM clang C compiler.  
Now the compiler is written in C++, its size:
    - initial stages: 10,000 LOC (lines of code)
	- expanded to around 50,000 LOC after adding the LLVM backend, macros, operator overloading, multiple 	return values, unions, etc.; 
	- jumped to around 75,000 LOC of code after adding inline assembly support, 
	- now some 87,000 LOC.  
It is proprietary at this time (Aug 2022), and will not be self-hosting (as meaning: written in Jai) in the near future. The compiler is _very fast_: all typical debug-builds even up to 250,000 LOC in under 1 s.

The compiler does not process code in a single-pass, lexically ordered way like C++ does. Instead the compiler does multiple passes to find all definitions if it needs to, so forward declarations are not needed, and the ordering of definitions and declaration is irrelevant.

The compiler uses a hand-written _recursive descent top-down parser_. It runs _multi-threaded_ as a kind of job system.  

Here is an overall schema of the compiler architecture:  
![Compiler schema](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/compiler_schema.png)

As we see in the diagram, Jai source code is first converted to an _abstract syntax tree_ (AST), which is then converted to an _internal byte code_.
## 4.2 Internal byte-code interpreter
Jai can run programs in IR (Intermediate Representation) byte-code during compilation, so only at compile-time, for example with the `#run` command. This is possible because the compiler contains a _byte-code interpreter_.    

When a function or program is run at compile-time, its bytecode, is executed by this interpreter. The results (for example: calculation of values, construction of procedures) are funneled back into the source code, and then the compiler continues as normal.  

At runtime, a Jai binary executable is running machine code directly. 

## 4.3 Front-end
The AST and byte-code boxes form the front-end, which is primarily written by J. Blow.  
During compilation, the time this phase takes is reported as:  
_Front-end time: 0.078980 seconds_

## 4.4 Back-ends
The back-end is the part that converts the internal byte-code to produce the executable (binary) machine code.  

Two compiler backends exist: an _x64_ and an _LLVM_ backend.

The **x64 backend** was developed from scratch by J. Blow and his compiler team. It converts the internal byte-code to x64 machine code. It does fast but naive code generation, without any code optimization.  
It is intended to be used during the development phase, but because the difference in total compile-time between x64 and llvm is negligible, this isn’t necessary at this moment.  

During compilation , the time this takes is reported as:    	
_x64 time: 0.534119 seconds._

The **LLVM backend** is the default. It can explicitly be specified with: `jai -llvm filename.jai`, but being the default -llvm can be left out.  
In this LLVM compiler chain, the Jai internal byte-code is further converted to LLVM IR-code.  

LLVM is an external compiler [tool-chain](https://en.wikipedia.org/wiki/LLVM) that does much better code optimization, but at the expense of slower compilation speed. You get all the LLVM optimizations for free, and the whole range of architectures and platforms LLVM targets. It's slower, but compiling a release build using LLVM is only needed for a definitive release or for specific platforms and targets.
It is intended to be used in production, when deploying an app.   

During compilation , the time this takes is reported as:  
_llvm time: 0.062771 seconds._

The sum of front-end time and back-end time is then reported as:    
_Compiler  time: 0.587162 seconds._  
	Front-end time + x64 time = Compiler time (for x64 backend)  
	Front-end time + llvm time = Compiler time (for llvm backend)

## 4.5 Linking
The backend compiler produces several compiler artefacts in the hidden _.build_ folder (.obj, .exp and .lib files). It is the task of the linker (_link.exe_ from MSVC on Windows, _lld-linux_ on Linux) to combine these object files and OS specific libraries statically into one output executable (.exe on Windows).  
The time this takes is reported as:   
_Link      time: 0.328986 seconds._

The link phase with the llvm backend on Windows can take about 3 x longer than the compilation phase.  
Finally, the sum of compilation and link time is reported as _Total time:    0.425573 seconds._
	Compiler time + Link time = Total time 

Here is a complete example output again:

```
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

Alternatively, you can define this in the Jai build-system itself (see ??).

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
            
```
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
The **Preload** module is implicitly loaded whenever the Jai compiler is started, so it doesn’t need to be imported.
It contains definitions the compiler needs in order to compile user source code.

It contains enums for the Operating_System, the _Type_Info_ definitions, the definitions for _Allocator, Logger, Stack trace, Context, Temporary Storage, Source Code location, Array_View and Resizable_Array_. 
It also contains low-level functions or **intrinsics**, like the following.

   	memcpy :: (dest: *void, source: *void, count: s64) #intrinsic;
	memcmp :: (a: *void, b: *void, count: s64) -> s16  #intrinsic;
	memset :: (dest: *void, value: u8, count: s64)     #intrinsic;
   
**memcpy** copies count bytes from source to dest,  
**memset** sets count bytes of dest to value.