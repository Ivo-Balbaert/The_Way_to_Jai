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
