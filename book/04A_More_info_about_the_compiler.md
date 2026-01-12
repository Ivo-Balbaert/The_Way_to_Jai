# Chapter 4 – More info about the compiler
## 4.1 General info

In its first version, Jai compiled to C, and this C code was compiled with gcc or the LLVM clang C compiler.    
Now the compiler (written in C++) generates first an IR (intermediate representation) _byte-code_. This is then turned into LLVM IR code and then machine-code through the LLVM tool-chain, or directly into machine-code by the x64 backend.     

The compiler size grew through its evolution:  
  - at the initial stages: 10,000 LOC (lines of code)  
	- this expanded to around 50,000 LOC after adding the LLVM backend, macros, operator overloading, multiple return values, unions, etc.   
	- it jumped to around 75,000 LOC of code after adding inline assembly support   
	- it is now some 87,000 LOC. (? update ?)   
The compiler source is proprietary at this time (Jan 2026), and will not be self-hosting (meaning: not written in Jai) in the near future. The compiler is _very fast_: all typical debug-builds even up to 250,000 LOC are processed fully in under 1 s.

> To reduce build-time further:
> * remove the .pdb file before compiling
> * compile for the x64 backend

The compiler does not process code in a single-pass, in a lexically ordered way like C++ does. Instead the compiler does multiple passes to find all definitions if it needs to. This means _forward declarations are not needed_, and the _ordering of definitions and declarations is irrelevant_.

The compiler uses a hand-written _recursive descent top-down parser_. It runs _multi-threaded_ as a kind of job system.  

Here is an overall schema of the compiler architecture:  
![Compiler schema](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/compiler_schema.png)

As we see in the diagram, Jai source code is first converted to an _abstract syntax tree_ (AST), which is then converted to an internal _byte-code_.

The developer can modify the generated AST at compile-time (see Meta-programming and macros § 26), and can access the compiler through a _compiler message loop_ (see § 30.5).


## 4.2 Internal byte-code interpreter
Jai can run programs in its byte-code during compilation, so only at compile-time, for example using the `#run` command. This is possible because the compiler contains a _byte-code interpreter_.    

When a procedure (function) or program is run at compile-time, its byte-code is executed by this interpreter. The results (for example: calculation of values, construction of procedures through meta-programming, etc. see § 26) are funneled back into the source code, and then the compiler continues as normal.  

At runtime, a Jai executable (binary) is running machine code directly. 

## 4.3 Front-end
The AST and byte-code boxes in the schema above form the front-end, which is primarily written by Jon Blow.  
During compilation, the time this phase takes is for example reported as:  
_Front-end time: 0.078980 seconds_

## 4.4 Back-ends
The back-end is the part that converts the internal byte-code to produce the executable machine code.  

Two compiler backends exist: an _x64_ and an _LLVM_ backend.

The **x64 backend** was developed from scratch by J. Blow and his compiler team. It converts the internal byte-code to x64 machine code. It does fast, but naive code generation, without any code optimization.  
It is intended to be used during the development phase, but because the difference in total compile-time between x64 and llvm is negligible, this isn’t necessary at this moment.  

During compilation , the time this takes is for example reported as:      	
_x64 time: 0.534119 seconds._

The **LLVM backend** is the default. It can be explicitlyspecified with: `jai -llvm filename.jai`, but being the default, `-llvm` can be left out.  
In this LLVM compiler chain, the Jai internal byte-code is further converted to LLVM IR-code.  

LLVM is an external compiler [tool-chain](https://en.wikipedia.org/wiki/LLVM) that does much more elaborate code optimization, but at the expense of slower compilation speed. You get all the LLVM optimizations for free, and the whole range of architectures and platforms that LLVM targets. It's slower, but compiling a release build using LLVM is only needed for a definitive release or for specific platforms and targets.
It is intended to be used in production, when deploying an app.   

During compilation , the time this takes is for example reported as:  
_llvm time: 0.062771 seconds._

The sum of front-end time and back-end time is then reported as:    
_Compiler  time: 0.587162 seconds._    
	Front-end time + x64 time = Compiler time (for x64 backend)  
	Front-end time + llvm time = Compiler time (for llvm backend)

## 4.5 Linking
The backend compiler produces several compiler artifacts in the hidden _.build_ folder (in Windows: .obj, .exp and .lib files). It is the task of the linker (_link.exe_ from MSVC on Windows, _lld-linux_ on Linux, _lld-macos_ on MacOs ) to combine these object files and (sometimes) OS specific libraries statically into one output executable (.exe on Windows).  
The time this takes is for example reported as:   
_Link      time: 0.328986 seconds._

The link phase with the llvm backend on Windows can take about 3-30 x longer than the compilation phase.  
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
- Experiment: 
   Compile the program _4.1_hello_sailor.jai_ (which we will discuss shortly) with both the llvm and x64 backends and compare the different times:

**llvm**:
Lexer lines processed: 9915 (15691 including blank lines, comments.)
Front-end time: 0.024913 seconds.
llvm      time: 0.041086 seconds.
Compiler  time: 0.065999 seconds.

Link      time: 0.248504 seconds.
Total     time: 0.314503 seconds.

**x64**:
Lexer lines processed: 9915 (15695 including blank lines, comments.)
Front-end time: 0.024845 seconds.
x64       time: 0.042985 seconds.
Compiler  time: 0.067830 seconds.

Link      time: 0.255121 seconds.
Total     time: 0.322952 seconds.

## 4.6 Architectures  
One of the big advantages of LLVM is that it is _platform independent_: it can produce executable binary code for a wide variety of platforms, amongst them game consoles.  
Specifically at this time, Jai supports:  
    • 	x86 architecture only (and limited Nintendo Switch support).  
    • 	OS / Platforms: Windows, (Ubuntu) Linux, MacOs support, at least one gaming console

## 4.7 Debug and release build
While developing, you’ll work with normal _debug builds_ which is the default, because you want to have as much info as possible when something goes wrong. For example a .pdb file with debugging info is produced, stack trace info will be shown, and optimizations which can hide erroneous behavior must be disabled.

When, after a thorough test process, you decide that your application is production-ready, you will want to deploy a _release version_, optimized for speed. Here you don’t want any debugging or stack-trace info, and you require all optimizations turned on. At this stage you’ll want to use the llvm backend and the -release option, as in:	`jai -release program.jai`

Alternatively and advisably (because you can fine-tune the process much more), you can define this in the Jai build-system itself (see § 30.4).

Experiment:
Compare the size of the generated executable, both for llvm and x64 builds, in debug- and release mode:
**Size executable :**
```
debug-builds:              command:
x64:  367 Mb test(async)   jai -x64 .\4.1_hello_sailor.jai
llvm: 268 Mb               jai .\4.1_hello_sailor.jai
release-builds:
x64: 314 Mb                jai -release -x64 .\4.1_hello_sailor.jai
llvm: 122 Mb               jai -release .\4.1_hello_sailor.jai
```

[4B - Options for giving code at the command-line](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/04B_Options_for_giving_code_at_the_command-line.md)    
[4C -The Preload module](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/04C_The_Preload_module.md)    
[4D - Memory management](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/04D_Memory_management.md)    
[4E - What happens when Jai starts up?](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/04E_What_happens_when_Jai_starts_up.md)    
