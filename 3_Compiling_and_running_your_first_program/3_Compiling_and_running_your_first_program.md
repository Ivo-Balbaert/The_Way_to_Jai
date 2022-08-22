# Chapter 3 – Compiling and running your first program

Some preliminary remarks:
  * Jai source code files have the extension **.jai**. But this is a convention, the compiler doesn't force you to use this extension.

  * In a code file, as is customary in all C type languages, every code line ends with a **;**. You can place several code lines on one line, if you separate them with ; but this is not so readable.
  
   * Sometimes it can be useful to document your code. This can be done in Jai with _comments_:  
   // for a single-line comment, at the start of the line or in the middle of a line  
   /*    
   …  
   \*/  
   for a multi-line comment   
   These can contain nested comments:  /* block /* nested */ */  
   Comments are not compiled. Use comments sparingly, in general names of variables should show what they contain, and names of procedures should tell us what they do.

   * As you will soon see, programmers use spaces and indentation to make the program text more readable for humans (the compiler doesn't care). The following rule is mostly used: at _each indentation level_, the code moves _4 spaces_ to the right.  

## 3.1 The main entry point

To start, let's create a folder _jai_projects_.
Open this folder in VSCode by selecting File, Open Folder.
Now create a new (empty) text file, and save it as 
_3.1_hello_sailor.jai_. 

Now try to compile this empty file: `jai 3.1_hello_sailor.jai`

The compiler protests with:  
_In Workspace 2 ("Target Program"):
Error: No program entry point was found. (The designated entry point name is 'main'.)_

(Don't worry about the Workspace, we'll explain this later (see ??).)  
What does this mean?
This error tells us the following:  
Every Jai program needs a so called _entry point_ called **main**, as in all C-like languages, which is the starting point for code execution. 
After all, the computer needs to know where to start executing your program!

In Jai syntax, this looks like:

```
main :: () {
}
```
This is simply a _procedure_ with name `main`.
(Jai calls **procedures** what most other languages call **functions**.)
Not only is the main procedure a starting point, it also encompasses the complete program execution from start to end.  
:: means that main is in fact a constant, we'll see what that means later (see ??).  
() is the parameter list, which is empty for main. We also don't see anything after ): main has no return value, unlike C.  
Then follow the curly braces { } which normally contain the code to execute line by line.

> Remark that Jai doesn't need a special keyword like function or func or even fn to indicate a function.

Because there is no code, it doesn't do anything. But this is the first program which can be compiled!  
`jai hello_sailor.jai` now produces the output:

```
Running linker: "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\link.exe" /nologo d:/Jai/jai_projects/.build/hello_sailor_0_w2.obj d:/Jai/jai_projects/.build/hello_sailor_1_w2.obj d:/Jai/jai_projects/.build/hello_sailor_2_w2.obj d:/Jai/jai_projects/.build/hello_sailor_3_w2.obj /OUT:hello_sailor.exe /MACHINE:AMD64 /INCREMENTAL:NO /DEBUG /IMPLIB:d:/Jai/jai_projects/.build/hello_sailor.lib /libpath:"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\lib\x64" /libpath:"C:\Program Files (x86)\Windows Kits\10\Lib\10.0.18362.0\um\x64" /libpath:"C:\Program Files (x86)\Windows Kits\10\Lib\10.0.18362.0\ucrt\x64" -nodefaultlib libcmt.lib vcruntime.lib ucrt.lib kernel32.lib msvcrt.lib kernel32.lib
   Creating library d:/Jai/jai_projects/.build/hello_sailor.lib and object d:/Jai/jai_projects/.build/hello_sailor.exp

Stats for Workspace 2 ("Target Program"):
Lexer lines processed: 663 (983 including blank lines, comments.)
Front-end time: 0.043859 seconds.  
llvm      time: 0.012493 seconds.  

Compiler  time: 0.056352 seconds.  
Link      time: 0.273129 seconds.  
Total     time: 0.329482 seconds.  
```

This only displays some useful compiler and linker info. You will see this whenever you compile Jai code.

On Linux, you will see an output like this:

```
Running linker: /home/ivo/jai//bin/lld-linux -flavor Gnu --eh-frame-hdr -export-dynamic -o hello_sailor /home/ivo/jai_projects/.build/hello_sailor_0_w2.obj /home/ivo/jai_projects/.build/hello_sailor_1_w2.obj /home/ivo/jai_projects/.build/hello_sailor_2_w2.obj /home/ivo/jai_projects/.build/hello_sailor_3_w2.obj /lib/x86_64-linux-gnu/crt1.o /lib/x86_64-linux-gnu/crti.o /lib/x86_64-linux-gnu/crtn.o -L /home/ivo/jai_projects --dynamic-linker /lib64/ld-linux-x86-64.so.2 -rpath='$ORIGIN' -L /lib -L /lib64 -L /usr/lib -L /usr/lib64 -L /usr/local/lib/x86_64-linux-gnu -L /lib/x86_64-linux-gnu -L /usr/lib/x86_64-linux-gnu -L /usr/local/lib -L /usr/lib/x86_64-linux-gnu/libfakeroot -L /usr/lib/wsl/lib -L /home/ivo/jai/modules/ --start-group /lib/x86_64-linux-gnu/libpthread.so /lib/x86_64-linux-gnu/libm.so /lib/x86_64-linux-gnu/libc.so /lib/x86_64-linux-gnu/libdl.so /lib/x86_64-linux-gnu/librt.so /home/ivo/jai/modules/stb_sprintf/linux/stb_sprintf.a --end-group

Stats for Workspace 2 ("Target Program"):
Lexer lines processed: 7582 (11448 including blank lines, comments.)
Front-end time: 0.096169 seconds.  
llvm      time: 0.080191 seconds.  

Compiler  time: 0.176359 seconds.  
Link      time: 0.000830 seconds.  
Total     time: 0.177189 seconds.  
```

We won't display this output again, unless it contains something interesting.

## 3.2 Compiling our first program

### 3.2.1 Compile-time
You see that in the compilation phase, that only took a fraction of a second, which is called **compile-time**, a lot of things happen. As we will see later (§ 3.2.4 and chapter ??), Jai can do very complex things during compilation, even running entire programs! 
But as we will soon see with real programs that do something, Jai always compiles very fast.

Let's analyze the compilation output:
First it displays the full _linker command_ (this could be useful when something goes wrong at this stage). Here (on Windows) we see Microsoft's `link.exe` at work; on Linux the lld-linux command is used.  
Calling the compiler creates a hidden _.build_ folder, in which _.obj_ files like _hello_sailor_1_w2.obj_ are created, as well as a .lib and .exp file.  

The linker then combines all these and helper libraries in one executable named _hello_sailor.exe_ on Windows and _hello_sailor_ on Linux and macOS. You will also see a file with **.pdb** extension, which is used when debugging.

Compilation/linking produces a single executable as output: Jai follows the _single compilation unit model_.  
You can execute this by typing:  `hello_sailor`
(`./hello_sailor` on Linux), but as expected, nothing is displayed.

### 3.2.2 Printing output

No we want to display a greeting to a sailor, let's say: _Hello, Sailor from Jai!_  
This is a string and must be enclosed within double quotes "", like:  
_"Hello, Sailor from Jai!"_.  
To produce an output in Jai, we use the **print** procedure, which can take this string as argument, like this:

```
print("Hello, Sailor from Jai!");
```
This is a complete code statement, so it must end with a semicolon **;**  
We now have the following code:

```
main :: () {
   print("Hello, Sailor from Jai!");
}
```

Let's compile it again:  `jai hello_sailor.jai`   
But there is a problem, we get the following output:

```
In Workspace 2 ("Target Program"):
d:/Jai/The Way to Jai/3-Compiling_and_running_your_first_program/code/hello_sailor.jai:2,4:  
**Error: Undeclared identifier 'print'.**

    main :: () {
       print("Hello, Sailor from Jai!");
...
```  
The error means the compiler can't find the `print` procedure. That's because this procedure is defined elsewhere, in a **module** called _Basic_.

> Modules are stored in the _jai\modules_ folder. There we find a subfolder _Basic_, containing a file _Print.jai_, which contains the definition of `print`.

In order to make this clear to the compiler, we must **import** that module with the following statement:  `#import "Basic";`
Add this at the start, so that our code file looks like:

```
#import "Basic";

main :: () {
   print("Hello, Sailor from Jai!");
}
```

Now compilation succeeds and an executable is created!

### 3.2.3 Run-time

When we now run the hello_sailor executable, we see the expected output:  
_Hello, Sailor from Jai!_

Congratulations! You made your first Jai program.

Here is a screenshot where the program is edited, compiled and run from within VSCode:

![Program in VSCode](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/program_vscode.png)


The phase when the Jai program binary file executes is called **run-time**. 
Compile-time and run-time are very distinct:
 1. first you compile a program which is **compile-time** 
 2. then you execute or run it, which is **run-time**.

But due to its extensive meta-programming capabilities, Jai can even 
_run a program during compile-time_!

### 3.2.4 Running code during compile-time

Make a new source file called _3.2_hello_sailor_comptime.jai_ and add the following line after main: `#run main();`, so that we get:

```
#import "Basic";

main :: () {
   print("Hello, Sailor from Jai!\n");
}

#run main();
```

Now compile the program as before and carefully look at the output:
```
   Hello, Sailor from Jai!
   
   Running linker: ...
```

You see the same extensive output starting with _Running linker_ as previously.
But before the linking starts (so  **_during compile-time_** !), you already see our printed output.
This means `main()` has already been executed at compile-time!
This is because of the **#run** command. This **directive** tells the compiler to run the procedure called after `#run` in compile-time.

In case of `#run main()`, you run the whole program during compile-time (see ?? for more info on `#run`).


### 3.2.5 Some remarks

  1) Source code file names are usually in lowercase, separated by _ if needed, like _hello_sailor.jai_ or _struct_literals.jai_. In chapters with multiple code files, we'll number them also like _3.1_hello_sailor.jai_.

  2) You might have noticed that the displayed string is immediately followed by the OS-prompt. You can separate them with a blanc line by adding a newline character _\n_ to the string like this:  `print("Hello, Sailor from Jai!\n");`  
  Compile and check it.


### 3.2.6 Errors

Let's see some other compile-time errors.  
Remove the ; at the end of the print statement and compile again. The compiler gives you the following error-message:

```
d:/Jai/The Way to Jai/3-Compiling_and_running_your_first_program/code/hello_sailor.jai:4,37:  
**Error: Semicolon expected after expression.**

    main :: () {
       print("Hello, Sailor from Jai!\n")
```
This is very clear: it gives you the line (4) on which the error occurred, and even the exact column (37)!  
You'll find that Jai has strong compiler checks and helpful error messages following the motto: _better resolve errors at compile-time than having to deal with bugs at run-time_.  
Also the Jai compiler stops at the first error it encounters and only reports that.

**Exercises:**
Experiment to understand the error messages.

1- Leave out the closing } of main
2- Leave out the () parameter list in main
3- Try changing the order of the #import, main procedure and #run statement.  
You'll notice that the order in which definitions and procedures appear in a Jai source file doesn’t matter: `#import` can come as last, `main :: () { }` as first or last or somewhere in between, and so on. This is because the compiler does several passes.

*TIP*: In general it is useful to find `main` quickly, so by convention `main` is usually placed at the end (bottom) of the source file.