# 30 Integrated build system.md

C/C++ compilers do not have a way to specify how to build a program, and are reliant on outside systems foreign to the language to build projects, such as Makefiles, Ninja, and CMake. All these build systems are clunky, need to use a different system for different operating systems, and building a large program can be incredibly messy. 
In Jai, all you would ever need to compile your code is the Jai language and compiler itself, there are no external dependencies.

> JAI provides an integrated build process.

We learned about compiling a program with the `jai` command in § 3, while all command-line options were reviewed in § 2B. This chapter talks about building (compiling/linking while setting options) a Jai project through running another Jai program: the meta-program, which is usually called `build.jai`.

## 30.1 
See _30.1_.jai_:
```c++
```

