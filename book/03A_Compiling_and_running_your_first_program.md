# Chapter 3 – Compiling and running your first program

## 3.1 Some preliminary remarks
  * Jai source code files have the extension **.jai**. But this is a convention, the compiler doesn't force you to use this extension.

  * In a code file, as is customary in all C type languages, every code line ends with a semi-colon **;**  
  You can place several code lines on one line, if you separate them with a ; but this is not so readable.
  
   * Documenting your code is crucial for maintenance. This can be done in Jai with _comments_:  
   // for a single-line comment, at the start of the line or in the middle of a line  
   /*    
   …  
   \*/  
   for a multi-line comment   
   These can contain nested comments:  /* block /* nested */ */  
   Comments are not compiled. Use comments sparingly, in general names of variables should show what they contain, and names of procedures should tell us what they do.

   * As you will soon see, programmers use spaces and indentation to make the program text more readable for humans (the compiler doesn't care). The following rule is mostly used: at _each indentation level_, the code moves _4 spaces_ to the right.  

## 3.2 The main entry point

To start, let's create a folder _jai_projects_.
Open this folder in VSCode by selecting File, Open Folder.
Now create a new (empty) text file, and save it as 
*3.1_hello_sailor.jai*. 

Now try to compile this empty file: `jai 3.1_hello_sailor.jai`

The compiler protests with:  
_In Workspace 2 ("Target Program"):
Error: No program entry point was found. (The designated entry point name is 'main'.)_

Don't worry about the Workspace thing, we'll explain this later (see § 30.1).
What does this mean?
This error tells us the following:  
Every Jai program needs a so called _entry point_ called **main**.  This is the starting point for code execution, as in all C-like languages.  
After all, the computer needs to know where to start executing your program!

In Jai syntax, this looks like:

```c++
main :: () {
}
```
This is simply a _procedure_ with name `main`.
(Jai calls **procedures** what most other languages call **functions**.)
Not only is the main procedure a starting point, it also envelops the complete program execution from start to end.  
:: means that `main` is in fact a constant, we'll see what that means later (see § 5.2.2).  
() is the parameter list, which is empty for main. We also don't see a -> after ) This means main has no return value, unlike C.  
Then come the curly braces { } which contain the code to execute line by line.

> An error you might get into in the beginning is writing main () :: {}. You get an Error: ... This does not make sense! ;-)
> Jai doesn't need a special keyword like proc, function or func or even fn to indicate a function.

Because there is no code, it doesn't do anything. But this is the first program which can be compiled!  
`jai 3.1_hello_sailor.jai` now produces the output:

```
Running linker: "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\link.exe" /nologo d:/Jai/jai*projects/.build/hello_sailor_0_w2.obj d:/Jai/jai*projects/.build/hello_sailor_1_w2.obj d:/Jai/jai*projects/.build/hello_sailor_2_w2.obj d:/Jai/jai*projects/.build/hello_sailor_3_w2.obj /OUT:hello_sailor.exe /MACHINE:AMD64 /INCREMENTAL:NO /DEBUG /IMPLIB:d:/Jai/jai*projects/.build/hello_sailor.lib /libpath:"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\lib\x64" /libpath:"C:\Program Files (x86)\Windows Kits\10\Lib\10.0.18362.0\um\x64" /libpath:"C:\Program Files (x86)\Windows Kits\10\Lib\10.0.18362.0\ucrt\x64" -nodefaultlib libcmt.lib vcruntime.lib ucrt.lib kernel32.lib msvcrt.lib kernel32.lib
   Creating library d:/Jai/jai*projects/.build/hello_sailor.lib and object d:/Jai/jai*projects/.build/hello_sailor.exp

Stats for Workspace 2 ("Target Program"):
Lexer lines processed: 663 (983 including blank lines, comments.)
Front-end time: 0.043859 seconds.  
llvm      time: 0.012493 seconds.  

Compiler  time: 0.056352 seconds.  
Link      time: 0.273129 seconds.  
Total     time: 0.329482 seconds.  
```

This displays some useful compiler and linker info. You will see this whenever you compile Jai code.

On Linux, you will see an output like this:

```
Running linker: /home/ivo/jai//bin/lld-linux -flavor Gnu --eh-frame-hdr -export-dynamic -o hello_sailor /home/ivo/jai*projects/.build/hello_sailor_0_w2.obj /home/ivo/jai*projects/.build/hello_sailor_1_w2.obj /home/ivo/jai*projects/.build/hello_sailor_2_w2.obj /home/ivo/jai*projects/.build/hello_sailor_3_w2.obj /lib/x86_64-linux-gnu/crt1.o /lib/x86_64-linux-gnu/crti.o /lib/x86_64-linux-gnu/crtn.o -L /home/ivo/jai*projects --dynamic-linker /lib64/ld-linux-x86-64.so.2 -rpath='$ORIGIN' -L /lib -L /lib64 -L /usr/lib -L /usr/lib64 -L /usr/local/lib/x86_64-linux-gnu -L /lib/x86_64-linux-gnu -L /usr/lib/x86_64-linux-gnu -L /usr/local/lib -L /usr/lib/x86_64-linux-gnu/libfakeroot -L /usr/lib/wsl/lib -L /home/ivo/jai/modules/ --start-group /lib/x86_64-linux-gnu/libpthread.so /lib/x86_64-linux-gnu/libm.so /lib/x86_64-linux-gnu/libc.so /lib/x86_64-linux-gnu/libdl.so /lib/x86_64-linux-gnu/librt.so /home/ivo/jai/modules/stb_sprintf/linux/stb_sprintf.a --end-group

Stats for Workspace 2 ("Target Program"):
Lexer lines processed: 7582 (11448 including blank lines, comments.)
Front-end time: 0.096169 seconds.  
llvm      time: 0.080191 seconds.  

Compiler  time: 0.176359 seconds.  
Link      time: 0.000830 seconds.  
Total     time: 0.177189 seconds.  
```

We won't display this output again, unless it contains something interesting.

## 3.3 Compiling our first program

### 3.3.1 Compile-time
You see that in the compilation phase, that only took a fraction of a second, which is called **compile-time**, a lot of things happen. As we will see later (§ 3.3.4 and chapter § 26 and 30), Jai can do very complex things during compilation, even running entire programs! 
But as we will soon see with real programs that do something, Jai always compiles very fast.

Let's analyze the compilation output:
First it displays the full _linker command_ (this could be useful when something goes wrong at this stage). Here (on Windows) we see Microsoft's `link.exe` at work; on Linux the `lld-linux` command is used.  
Calling the compiler creates a hidden _.build_ folder, in which `.obj` files like _hello_sailor_1_w2.obj_ are created, as well as a `.lib` and `.exp` file.  

The linker then combines all these files and helper libraries in one executable named _hello_sailor.exe_ on Windows and _hello_sailor_ on Linux and macOS. You will also see a file with `.pdb` extension, which is used for debugging.

Compilation/linking produces a single executable as output: Jai follows the _single compilation unit model_.  
You can execute this by typing:  `hello_sailor` (or even `3` when the source file is named `3.1_hello_sailor.jai`). On Linux it is `./hello_sailor`
But as expected, nothing is displayed.

### 3.3.2 Printing output

Now we want to display a greeting to a sailor, let's say: _Hello, Sailor from Jai!_  
This is a string and must be enclosed within double quotes "", like: _"Hello, Sailor from Jai!"_.  
To produce an output in Jai, we use the `print` procedure, which can take this string as argument, like this:

```c++
print("Hello, Sailor from Jai!");
```
This is a complete code statement, so it must end with a semicolon **;**  
We now have the following code:

```c++
main :: () {
   print("Hello, Sailor from Jai!");
}
```

Let's compile it again:  `jai 3.1_hello_sailor.jai`   
But there is a problem, we get the following output:

```c++
In Workspace 2 ("Target Program"):
d:/Jai/The Way to Jai/3-Compiling_and_running_your_first_program/code/hello_sailor.jai:2,4:  
Error: Undeclared identifier 'print'.

    main :: () {
       print("Hello, Sailor from Jai!");
...
``` 
The error  
**Error: Undeclared identifier 'print'.**  
means the compiler can't find the `print` procedure. That's because this procedure is defined elsewhere, in a **module** called _Basic_.

In order to make this clear to the compiler, we must **import** that module with the following statement:  `#import "Basic";`
Add this at the start, so that our code file looks like:

```c++
#import "Basic";

main :: () {
   print("Hello, Sailor from Jai!");
}
```

Now compilation succeeds and an executable is created!

### 3.3.3 Run-time

When we now run the _hello_sailor_ executable as shown above, we see the expected output:  
_Hello, Sailor from Jai!_

Congratulations: you made your first working Jai program!.

Here is a screenshot where the program is edited, compiled and run from within VSCode:

![Program in VSCode](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/program_vscode.png)


The phase when the Jai program binary file executes is called **run-time**. 
Compile-time and run-time are very distinct:
 1. first you compile a program in a time period which is **compile-time** 
 2. then you execute or run it, which is during **run-time**.
   
During compile-time, your code is carefully examined, and if needed a _compiler error_ is shown and the compilation stops without producing an executable. If you get a _warning_ (these are rare), compilation is not stopped. An executable binary is produced only when the compiler and linker can finish without errors.

At run-time, a program can still be stopped (it crashes or panics) when a certain abnormal condition is encountered producing a _run-time error_, such as for example during bounds-checking on arrays or strings (when an index is used that lies outside the size of the array/string) or a divide-by-zero condition.

Due to its extensive meta-programming capabilities, Jai can even 
_run a program during compile-time_!

### 3.3.4 Running code during compile-time

Make a new source file called *3.2_hello_sailor_comptime.jai* and add the following line after (or before) main: `#run main();`, so that we get:

```c++
#import "Basic";

main :: () {
   print("Hello, Sailor from Jai!\n");
}

#run main();
```

Now compile the program as before and carefully look at the output:
```c++
   Hello, Sailor from Jai!
   
   Running linker: ...
```

You see the same extensive output starting with _Running linker_ as previously.
But before the linking starts (Running linker, which is **_during compile-time_** !), you see our printed output.
This means `main()` has already been executed at compile-time!
This is because of the **#run** command. This so-called **directive** tells the compiler to run the procedure called after `#run` during compile-time.

In case of `#run main()`, you run the whole program during compile-time (see § 26.2 for more info on `#run`).

_On Linux_ we can use the **#!** mechanism so that we can run the Jai source file as a kind of script at compile-time. Add the following line at the start of *3.2_hello_sailor_comptime.jai*:  
`#! /path/to/jai/bin/jai`  
This has to be the full path to the `jai` executable on your machine, for example /home/username/jai/bin/jai (the executable is by default jai-linux, which we renamed to jai in § 2.2).
Now make your script executable with:  
`chmod u+x ./3.2_hello_sailor_comptime.jai`
Now you can execute your jai script (running at compile-time) by typing in:  
`./3.2_hello_sailor_comptime.jai`

This displays:  
**Hello, sailor from Jai!**
Running linker: /home/ivo/jai//bin/lld-linux ...  
...  
This is just a nice trick, and by no means a commonly used way of doing things.

> Jai uses a lot of directives and we'll discuss them in several coming chapters. You could consider them as special instructions for the compiler. They all start with the **#** character.


### 3.3.5 Some remarks

  1) Source code file names are written usually in lowercase, separated by _ if needed, like *hello_sailor.jai* or *struct_literals.jai*. Never use space characters in a Jai filename!  
  > Note:
  > If you really need to work with a source file containing spaces (like in *space invaders.jai*), you can use "" on Windows to compile the source like this: `jai "space invaders.jai"`  
  In chapters with multiple code files, we'll number them like *3.1_hello_sailor.jai*.

  2) You might have noticed that the displayed string is immediately followed by the operating system (OS)-prompt. You can separate them with a blanc line by adding a newline character _\n_ to the string like this:  `print("Hello, Sailor from Jai!\n");`  
  Compile and check it.


### 3.3.6 Errors

Let's see some other compile-time errors.  
Remove the ; at the end of the print statement and compile again. The compiler gives you the following error-message:

```
d:/Jai/The Way to Jai/3-Compiling_and_running_your_first_program/code/hello_sailor.jai:4,37:  
Error: Semicolon expected after expression.

    main :: () {
       print("Hello, Sailor from Jai!\n")
```
This is very clear: it gives you the line (4) on which the error occurred, and even the exact column (37)!  
You'll find that Jai has strong compiler checks and helpful error messages following the motto: _better resolve errors at compile-time than having to deal with bugs at run-time_.  
Also the Jai compiler stops at the first error it encounters and only reports that, and no executable is generated. This means that after correcting the error, the next  compilation might flag new error(s)! You must continue correcting them until the compilation succeeds.

Sometimes the compiler signals a _Warning_ instead of an _Error_; a warning means that something strange is detected in the code, but the executable is generated.

### 3.3.7 Exiting a program
Normally a Jai program will stop after execution of the last statement in `main()`.
In exceptional circumstances, a program can encounter a run-time error and crash, which means that the OS has terminated the program. 
Jai also provides the `exit` procedure to stop the program at any condition it encounters or reaches, see for example the following program (see 3.3_exit.jai):

```c++
#import "Basic";

main :: () {
  print("Before exiting\n"); // => Before exiting
  exit(0); // exits the program
  print("After exiting\n"); // <= this will never print!
}
```
Statements coming after `exit` will never be executed.
`exit` must pass an integer to the OS, so that a script which invoked our Jai program could act upon the returned value.  
Typical is:  
   0: everything is OK  
   < 0: the program encountered an error-condition.

*Exercises:*   
Experiment to understand the error messages.

1- Leave out the closing } of main  
2- Leave out the () parameter list in main  
3- Try changing the order of the #import, main procedure and #run statement.    
You'll notice that the order in which definitions and procedures appear in a Jai source file doesn’t matter: `#import` can come as last, `main :: () { }` as first or last or somewhere in between, and so on. This is because the compiler does several passes (see § 4.1).  
*TIP*: In general it is useful to find `main` quickly, so by convention `main` is usually placed at the end (bottom) of the source file.  
4- Write a Jai program that prints "One" and  "Two!" on consecutive lines, and then "Three!" on the same line (See *mini.jai*).  
5- Investigate whether the compiler really needs source files to have the extension .jai (See *mini.txt_).