# Chapter 8 – Modules - Structuring a project's code

A Jai project consists of a start-up file, usually called ´main.jai´, which contains the `main :: ()` entry-point procedure.
In § 3.2.2 we saw how we can import a module in our project by using `#import`. We encountered the implicitly loaded _Preload_ module in § 4C.

**Searching for identifier names**  
When an identifier for a type, variable or procedure is encountered while compiling, the compiler first looks in the current source file. Then it searches the imported modules (if any, see § 8.1), and it also searches the loaded files (see § 8.2).

Imported modules are always built from source, in full, every time you compile your program.

## 8.1 Structuring with modules
Modules mostly contain code that is commonly used to provide basic functionality, what in most languages is called the _standard library_. For example: to use the `print` function we had to import the _Basic_ module with `#import "Basic";`.  

Modules are stored in the _jai\modules_ folder.
They are installed globally on a machine, so that all Jai applications need to use the same modules collection. 
> A system will be made so that the modules you use get copied locally into your application. The advantage is that you have a stable build that doesn't randomly break unless you decide to update those modules (see also § 8.5).

When a module (for example TestScope) is not found, the compiler gives the error:  
`Error: Unable to find a module called 'TestScope' in any of the module search directories.

    #import "Basic";
    #import "TestScope";

Info: ... Searched path 'c:/jai/modules/'.`
Jai has searched in this search path for a file named TestScope.jai, and if it doesn't find this, for a subfolder TestScope containing a module.jai source file.

A module can be one file, for example `Random.jai`, which can be imported with `#import "Random";`.  

So it is typical to see a number of #imports being done. We place them at the start of the code file, but you can place them anywhere, also at the bottom of the file if this is your personal preference.  
Also take care to weed out the #import's you do not need. While this isn't an important problem, it does increase compilation time and size a bit.

When a module contains several files, you need to give the module its own folder with the same name, and in it a file `module.jai` is required.
For example, the _Basic_ module has its own folder _/modules/Basic_. In it you'll find a file *Print.jai*, which contains the definition of `print`. It also contains other source files. The `module.jai` file often serves as a way to assemble all these source files, using `#load` to do this. 

You can make your own module(s) in /jai/modules. But these could be deleted when a new version of Jai is installed, so a better solution is to make a separate folder for your own modules, and make it known to Jai with `-import_dir` (see § 8.5).

When you look at the start of the `module.jai` for _Basic_, you can see that it loads the other .jai files in the folder:

```c++
#load "Array.jai";
#load "Simple_String.jai";
#load "String_Builder.jai";
#load "Print.jai";
#load "Apollo_Time.jai";
#load "string_to_float.jai";
```

This is a common way to structure a module, or indeed a main file of any substantial project. Typically a `module.jai` will also `#import` the other modules the current module needs.    
The following section details how it works.

## 8.2 Loading files with #load
Besides the #import to take in a module, you also would want to be able to take in one (or more) Jai source code file(s) and add these to your project. Like modules, we use the `#load` directive to do this, which is comparable to C's #include.  

The `#load` directive effectively copies in the contents from the loaded source file into the current file. Think of loading a file as copy/pasting the code directly into the calling file. While building this current file, all code from the loaded files will be automatically build with it.  
Have a look at this example:

See *8.1_main.jai*:
```c++
#import "Basic";

#load "part1.jai";
#load "subfolder/part2.jai";
#load "part3.jai";

main :: () {
  print("Loaded all three part files\n");
  print("a_part1 is: %", a_part1);
}

/* =>
Loaded all three part files
a_part1 is: 42
*/
```
This way code like procedure definitions or struct declarations and so on can be divided over several source files, each grouping all code for a certain functionality. Our `main.jai` is then like a summary of the code, containing also the starting `main()` procedure.  
`#load` provides us with a way to structure the code in a project: code that belongs together can be put in one file. In this way, the main file of a project can be structured as a collection of all these component source files.  
In a more complex project, this principle could be applied to lower levels as well: `part1.jai` could also contain #load (s), and so on: it is a hierarchical process.

To illustrate this, `part1.jai` contains the declaration of the variable a_part1: `a_part1 := 42;` which is printed out in `main()`. From `part2.jai` you see that you can load a file from an arbitrary path; the path is relative to the calling file.

> Code from a #load-ed file has access to the global scope. Code from a #import-ed module has not!

## 8.3 Named imports
There are a couple of important reasons to give a name to an import, instead of just doing `#import "Math";`.
### 8.3.1 Definition
Sometimes you want to qualify a procedure name with the module name it came from (perhaps because that name has already been used, so it is a duplicate) you can do a named import as follows:	 
`Math :: #import "Math";`

The name you give doesn't have to be the same as the module name, but it is a constant. Then you have to qualify all proc calls to that module with its module name (in other words: you give the proc a namespace), like this:

```c++
	y := Math.sqrt(2.0);
```

This improves readability: it makes it clear where a function comes from.  
Alternatively, you can work with `using` so that you don't need to use the module's name:
```c++
    using Math;
    y := sqrt(2.0);
```

The name can also be an abbreviation:

```c++
    Long :: #import "Long_Name_Library";
```

or simply serve to differentiate between two modules with the same name, like we see in the next section.

### 8.3.2 Handling naming conflicts
Suppose you have two structs in two different files/libraries with the same name, causing a name conflict. You can prefix one or both of the imports to prevent naming conflicts.
Suppose both modules Lib1 and Lib2 contain a procedure `proc1`, then you can name both imports:

```c++
Lib1 :: #import "Lib1";
Lib2 :: #import "Lib2";

a: Lib1.proc1(); // call proc "proc1()" from Lib1
b: Lib2.proc1(); // call proc "proc1()" from Lib2
```

If you prefer, you can use just one named import:
```c++
#import "Lib1";
Lib2 :: #import "Lib2";

a: proc1();      // call proc "proc1()" from Lib1
b: Lib2.proc1(); // call proc "proc1()" from Lib2
```

Or you can exclude `proc1` from being visible when imported from `Lib1` like this:  
```c++
Lib1 :: #import "Lib1";
using,except(proc1) Lib1;
```

The same mechanism applies for a struct with the same name in both Lib1 and Lib2.

## 8.4 Import a file, a dir or a string
If you only want to import a specific file from a module, you can do it with `#import, file` like this:  
`module :: #import, file "module1/module.jai";`
This can be useful to avoid name-conflicts.

To load a directory from a module, use `#import, dir`:  
`module :: #import, dir "files/directory";`  
for example: `raylib :: #import,dir "../raylib/raylib";`  
This is the same as doing:  `jai program.jai -import_dir "../raylib/raylib"`

You can even import a specific string into your program with `#import, string`, for example:  
`#import, string "factorial :: (x: int) -> int { if x <= 1 return 1; return x * factorial(x-1); }";`
Then in the .build folder, a file .added_strings_w2.jai is created which contains this added string.

## 8.5 Structuring a project
A project can consist of many source files and modules that are called. But there can only be one main source file. This file contains the `main()` procedure and structures the project with #imports and #loads. It is by convention called `main.jai`.

## 8.5.1 The folder structure
For a quick test or a simple program containing a few hundreds of lines of code, a `main.jai` (or whatever you call it in that case) may be sufficient. This source file can simply be compiled with the jai tool and its command-line arguments (see § 2B and 3).  

For small to medium-sized projects, the following folder structure is often used:

```
\project_name
    \run
        \data
        project_name.exe
    \src
        main.jai
        other .jai files
    build.jai
```

The main.jai #loads the other source files in \src, perhaps also data-files from \run\data.  
`build.jai` (formerly called `first.jai`) is a Jai source file that describes (in Jai) the project's compilation process. In this case you start compilation with `jai build.jai`. This is described in detail in § 30.  
The executable produced by the compilation through build.jai is most often placed in the \run folder (formerly called `\run_tree`). It can be named after the project, but this is not necessary. This is how you code this in build.jai (see § 30):
`set_build_options_dc(.{output_path="run", output_executable_name="project_name"});`  
The \run\data can contain data files such as fonts, images, sound-files and so on.

## 8.5.2 The source code structure
The order of statements in a Jai source file is not mandatory (other than when necessary to limit scopes). However, for readability, it can be good to adhere to some conventions, particularly in a big codebase.

>It is a good convention to put the #import and #load directives at the top of the main file, starting with the #import (s), followed by the  #load (s). That way you know immediately which modules are loaded in the current file, and which source code is copied in. When many modules and files are imported/loaded, it can even be good to order them alphabetically.  

After the imports/loads come the global declarations of constants, variables, types, and so on. Then all the procedure code is listed.

You always want to be able to find the `main()` procedure quickly, to get an overview of what the program is doing. For that reason:
> Put the main() procedure at the bottom of the main file.

## 8.6 -import_dir
An imported module is searched in the _jai\modules_ folder. Additional modules from other directories can be imported via the `-import_dir "Path/To/Module"` flag. The search path which the compiler looks through in search for modules is called the _import_path_.
Examples:
- To load a `module.jai` in the same folder as program.jai:  
    `jai program.jai -import_dir "./"`
- To load a module from a folder /path/to/mod1:  
    `jai program.jai -import_dir "/path/to/mod1"`
  Or if arg1 == "/path/to/mod1"  
    `jai program.jai -import_dir arg1`
- You can specify several path arguments to module directories at the same time:
    `jai program.jai -import_dir arg1, arg2, arg3`

For an example of its use, see § 12.12

**Exercise**  
Look at the code of program 26.9_doubly_linked_list.jai* in § 26.7  
Isolate the definition of LinkedList, Node and the for_expansion macro into a module Linked_List (which is just a single file Linked_List.jai).
Place this file in the current folder, and test out that with a #load the program still works.
Then import it as a module from the current folder and test out. 
Then place the file in a module folder like *D:\Jai\The_Way_to_Jai\my_modules* and test out.

## 8.7 Module and program parameters
### 8.7.1 Definition and use
In § 6.1.3 we already encountered the ENABLE_ASSERT program parameter from _Basic_, which by default enables assert debugging (see § 20.1.2).   
A **module or program parameter** is a parameter defined in and set by a module, like `ENABLE_ASSERT := true` in _Basic_. Here is its definition at the start of _Basic/module.jai_:   
`#module_parameters () (ENABLE_ASSERT := true);`  
Code that imports this parameter automatically gets in this parameter with that value. Or it can decide to change its value. This is done in the import line, like:  
`#import "Basic"()(ENABLE_ASSERT=false);`    
The 1st list () contains the module parameters: they only have module scope, so they are only active within the imported module. Basic has no module parameters, that's why this list is empty: ()
The 2nd list (to which for example ENABLE_ASSERT belongs) is a program parameter valid in the whole program: all program code use those values for the parameters.

In fact, module _Basic_ has several module parameters:  
`#module_parameters () (MEMORY_DEBUGGER := false, ENABLE_ASSERT := true, REPLACEMENT_INTERFACE: $I/interface Memory_Debugger_Interface = Memory_Debugger_Interface, VISUALIZE_MEMORY_DEBUGGER := true);`  
(For usage of the MEMORY_DEBUGGER parameter, see § 21.4).

> So module parameters can be used to declare parameters that code can set when importing a module. If no explicit setting is done at import, the default value from the module is used.

### 8.7.2 Creating your own module parameters
Let's create our own module `TestModule_Params` in d:\my_modules\TestModule_Params\module.jai (or similar on other platforms) with the following contents:

```c++
#import "Basic";
#module_parameters(VERBOSE := false);            // (1)

#run {                                          // (2)
  if VERBOSE {
    print("The module is in VERBOSE mode\n");
  } else {
    print("The module is in NON_VERBOSE mode\n");
  }
}
```

In line (1) we define a module parameter `VERBOSE` with default value false. Line (2) runs a code block at compile-time and prints a message according to the value of `VERBOSE`. 
In our main file `8.2_main.jai` we have the code:

```c++
#import "TestModule_Params" (VERBOSE=true); // (1)

main :: () {}
```

This block executes as module `TestModule_Params` is imported in line (1).
To test this, compile the main file with the command:  
`jai 8.2_main.jai -import_dir "d:\jai\The_Way_To_Jai\my_modules"` or something similar on your system. 
The following message is printed out (at compile-time):
`The module is in VERBOSE mode`    
Verify that the other message appears when you set VERBOSE to false in `8.2_main.jai`.

  
[8B - The #scope directives](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/8B_The_scope_directives.md)
