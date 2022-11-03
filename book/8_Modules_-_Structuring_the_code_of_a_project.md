# Chapter 8 – Modules - Structuring a project's code

A Jai project consists of a start-up file, usually called ´main.jai´, which contains tne `main :: ()` entry-point procedure.
In § 3.2.2 we saw how we can import a module in our project by using `#import`. We encountered the implicitly loaded _Preload_ module in § 4.9

**Searching for identifier names**
When an identifier for a type, variable or procedure is encountered while compiling, the compiler first looks in the current source file. Then it searches the imported modules (if any, see § 8.1), and it also searches the loaded files (see § 8.2).
Modules are more o

Imported modules are always built from source, in full, every time you compile your program.

## 8.1 Structuring with modules
Modules mostly contain code that is commonly used to provide basic functionality, what in most languages is called the _standard library_. For example: to use the `print` function we had to import the _Basic_ module with `#import "Basic";`.  

Modules are stored in the _jai\modules_ folder.
They are installed globally on a machine, so that all Jai applications need to use the same modules collection. 
> A system will be made so that modules you use get copied locally into your application. The advantage is that you have a stable build that doesn't randomly break unless you decide to update those modules (see also § 8.5).

A module can be one file, for example `Random.jai`, imported if needed with `#import "Random";`.  

When a module contains several files, you need to give the module its own folder with the same name, and in it a file `module.jai` is required.
For example, the _Basic_ module has its own folder _/modules/Basic_. In it you'll find a file _Print.jai_, which contains the definition of `print`. But it also contains other source files.

You can make your own module(s) in /jai/modules. But these could be deleted when a new version of Jai is installed, so better make a separate folder for your own modules, and make it known to Jai with `-import_dir` (see § 8.5).

The `module.jai` file often serves as a way to assemble all these source files. It uses `#load` for this.

When you look at the start of the `module.jai` for _Basic_, you can see that it loads the other .jai files in the folder:

```c++
#load "Array.jai";
#load "Simple_String.jai";
#load "String_Builder.jai";
#load "Print.jai";
#load "Apollo_Time.jai";
#load "string_to_float.jai";
```

This is a common way to structure a module, or indeed a main file of any substantial project. The following section details how it works.

## 8.2 Loading files with #load
Besides the #import to take in a module, you also would want to be able to take in one (or more) Jai source code file(s) and add it to your project. Like modules, we use the `#load` directive to do this.  

The `#load` directive effectively copies in the contents from the loaded source file into the current file. Think of loading a file as pasting the code directly into the calling file. While building this current file, all code from the loaded files will be automatically build with it.  
Have a look at this example:

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
This way code like procedure definitions or struct declarations and so on can be divided over several source files, and our `main.jai` can be like a summary of the code, containing also the starting `main()` procedure.
`#load` provides us with a way to structure the code in a project: code that belongs together can be put in one file. In this way, the main file of a project can be structured as a collection of all these component source files.  
In a more complex project, this principle could be applied to lower levels as well: `part1.jai` could also contain #load (s), and so on: it is a hierarchical process.

To illustrate this, `part1.jai` contains the declaration of the variable a_part1: `a_part1 := 42;` which is printed out in `main()`. From `part2.jai` you see that you can load a file from an arbitrary path; the path is relative to the calling file.

> Code from a #load-ed file has access to the global scope. Code from a #import-ed module has not!

## 8.3 Named imports
Sometimes you want to qualify a function name with the module name it came from (perhaps because that name has already been used, it is duplicate) you can do a named import as follows:	 `Math :: #import "Math";`

Then you have to qualify all functions from that module with its module name (in other words: you give the proc a namespace), like this:

```
	y := Math.sqrt(2.0);
```

This improves readability: it makes it clear where a function comes from. The name can also be completely different, so it can be shorter:

```
    Long :: #import "Long_Name_Library";
```

or be used to differentiate between two modules with the same name.

## 8.4 Structuring a project
A project can consist of many source files and modules that are called. But there can only be one main source file. This file contains the `main()` procedure and structures the project with #imports and #loads. It is often called `main.jai` or `first.jai`.

The order of statements in a Jai source file is not mandatory. However, for readability  it can be good to adhere to some conventions, particularly in a big codebase.

>It is a good convention to put the #import and #load directives at the top of the main file, starting with the #import (s), followed by the  #load (s). That way you know immediately which modules are loaded in the current file, and which source code is copied in. When many modules and files are imported/loaded, it can even be good to order them alphabetically.  

After the imports/loads come the global declarations of constants, variables, types, and so on. Then all the procedure code is listed.

You always want to be able to find the `main()` procedure quickly, to get an overview of what the program is doing. For that reason:
> Put the main() procedure at the bottom of the main file.

## 8.5 -import_dir
An imported module is searched in the _jai\modules_ folder. Additional modules from other directories can be imported via the `-import_dir "Path/To/Module"` flag.
Examples:
- To load a `module.jai` in the same folder as program.jai:  
    `jai program.jai -import_dir "./"`
- To load a module from a folder /path/to/mod1:  
    `jai program.jai -import_dir "/path/to/mod1"`  
  Or if arg1 == "/path/to/mod1"  
    `jai program.jai -import_dir arg1`
- You can specify several path arguments to module directories at the same time:
    `jai program.jai -import_dir arg1, arg2, arg3`