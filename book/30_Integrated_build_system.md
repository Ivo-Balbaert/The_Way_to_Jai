# 30 Integrated build system
> Note: Because the build system is so powerful in Jai, this has become a huge chapter. In due time, it will be split into a number of digestible sections. 

**A built-in build system**

## Intro: What is a meta-program?
C/C++ compilers do not have a way to specify how to build a program, and are reliant on outside systems foreign to the language to build projects, such as Makefiles, Ninja, and CMake. All these build systems are clunky, need to use a different system for different operating systems, and building a large program can be incredibly messy. 
In Jai, all you would ever need to compile your code is the Jai language and compiler itself, there are no external dependencies.

> Jai provides an integrated build process. Essentially, your source code is the project file, and the compile options are specified in your code. You communicate with the compiler using the same language you’re writing the program in.

We learned about compiling a program with the `jai` command in § 3, while all command-line options were reviewed in § 2B.  

This chapter talks about building (compiling/linking while setting options) a Jai project through running another Jai program: the **meta-program**, which is usually called `build.jai` (it used to be called `first.jai`).  
Most of the procedures we will need are define in module _Compiler_, so we'll import this module in the programs in this chapter. Most of these programs will also be run at compile-time with #run.  
By convention a procedure called `build()` is run with `#run build()`, but you can also just run a code block with `#run {...}` (see *30.11_using_notes.jai*).  

Your meta-program gets a lot of very useful information about the target program, including:  
* syntax trees representing every procedure
* the types of all variables and all expressions
* information about which declaration each identifier binds to
You can do a whole lot of stuff with this information and perform analyses that would not be possible in most programming languages.

Behind the scenes when you do a: `jai program.jai`, the compiler internally runs another meta-program at startup to compile the first workspace. This **default meta-program** does things such as setting up the working directory for the compiler, setting the default name of the output executable based on command-line arguments, and changing between debug and release build based on command-line arguments. It only accepts arguments preceded by a `-`. The source for this meta-program is in _modules/Default_Metaprogram.jai_. 

> Any procedure that has the **#compiler** directive is a proc that interfaces with the compiler as a library; it works with compiler internals.

## 30.1 Workspaces
You've probably noticed that every successful compile output (let's say `jai program.jai`) contains the sentence:  
`Stats for Workspace 2 ("Target Program"):`
The 'Target Program' mentioned here is `program.jai`. For each program that is built by the compiler, a different **workspace** is used.  
A workspace represents a completely separate environment, inside which we can compile programs. When the compiler starts up, it makes a workspace for the first files that you tell it to compile on the command-line. 

See *30.1_workspaces.jai*:
```c++
#import "Basic";
#import "Compiler";

build :: () {
  w2 := get_current_workspace();        // (1)
  print("The current workspace is %\n", w2); // => The current workspace is 2
 
  w3 := compiler_create_workspace();    // (2)
  if !w3 {                              // (2B)
    print("Workspace creation failed.\n");
    return;
  }
  assert(w3 != 0);                      // (2C)
  print("The workspace w3 is %\n", w3); // => The workspace w3 is 3

  ws4 := compiler_create_workspace("Workspace 4");
  // do build for workspace 4...
  ws5 := compiler_create_workspace("Workspace 5");
  // do build for workspace 5...
}

main :: () { }

#run build();
```

A Workspace is defined in module _Preload_ as just a constant: `Workspace :: s64;`  
To know the current workspace the compiler is working at, use the procedure `get_current_workspace :: ()` (see line (1)). This returns 0 at run-time.   
You can ask the compiler to create one or several different new workspaces with the procedure `compiler_create_workspace();` which returns a variable of type Workspace (see line (2)). It can only be run at compile-time. Have a look at the ways to check (2B-C) whether your workspace is ready. 
Different workspaces run completely separate from each other, one workspace does not affect another workspace.

_Why is the workspace for the target program at the command-line called 'Workspace 2'?_  
When launching the compiler, the Default_Metaprogram that builds your program is started in workspace #1.  

## 30.2 The source file location directives
See *30.2_location.jai*:
```c++
#import "Basic";

add :: (x: int, y: int, loc := #caller_location) -> int {
    print("add was called from line %.\n", loc.line_number); // => add was called from line 18.
    return x + y;
}

main :: () { 
    print("In file % line %\n", #file, #line); // (1)
    // => In file d:/Jai/The_Way_to_Jai/examples/30/30.2_location.jai line 4
    print("Filepath is %\n", #filepath);       // (2)
    // => Filepath is d:/Jai/The_Way_to_Jai/examples/30/
    loc := #location(code);                    // (3)
    print("The code is at location %:%\n", loc.fully_pathed_filename, loc.line_number);
    // => The code is at location d:/Jai/The_Way_to_Jai/examples/30/30.2_location.jai:3
    add(2, 4);
}
```
A few directives exist that can be handy when providing file location information, at run-time as well as during compiling:  
  **#file**         contains the complete path, filename included of the current file  
  **#line**         gives the number of the line of code where this directive is used  
  **#filepath**     contains the path to the current file, without the filename; it can be a remote filepath.  
  **#location**     given a piece of Code, it can extract the full path to that code, as well as its line number.  
  **#caller_location**  it gives the line number from where a procedure is called.  

When using or setting file-paths in Jai, always use the forward slash / as path-separator, even on Windows!

**Exercise**
In § 17.1.2 Exercise (5) we made a naive implementation of the assert statement.   
But now we can show in our code where an assertion fails with `#location`.  
Moreover with the metaprogramming tools of § 26 (`compiler_get_nodes` used in `code_to_string`, see § 26.15),  we can make the difference between displaying a proc call and its value in displaying an assert, like this:  
```c++
assert_eq(42, factorial(3));
  left: 42  expr: 42
  right: 6  expr: factorial(3)
  loc: {"d:/Jai/testing/assert_eq.jai", 30, 15}
```
(see *assert_eq.jai*)

## 30.3 A minimal build file
### 30.3.1 Compiling with add_build_file
See *30.3_build.jai*:
```c++
#import "Basic";
#import "Compiler";

build :: () {
    w := compiler_create_workspace();                     // (1)
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    print("The workspace w is %\n", w);   // => The workspace is 3

    target_options := get_build_options(w);               // (2)
    target_options.output_executable_name = "program";    // (3)
    set_build_options(target_options, w);                 // (4)
    // add_build_file("main.jai", w);
    add_build_file(tprint("%/main.jai", #filepath), w);   // (5)
    set_build_options_dc(.{do_output=false});             // (6)
    }

    main :: () {}

    #run build();
```

The building process started with `jai build.jai` is done at compile-time when `#run build();` is executed.  

The first step in the building process is always to create a new workspace w (see line (1)), which will be Workspace 3. So the following workspaces are created:
* Workspace 1: reserved for inner compiler workings;
* Workspace 2: reserved for the target program, here `build.jai`;
* Workspace 3: reserved for the building script (we could call it a script, although it's completely written in Jai);

Then we want to configure the build options. We first get the current build options from the workspace with the procedure `get_build_options(w)`, which returns an instance of the struct `Build_Options`. This struct is defined in module _Compiler_, and contains some 45 options you can tweak about how the compilation works!  

In this first example, we only set the field `output_executable_name` (line (3)).  
After all necessary build options have been configured, we write them back to the workspace with the proc `set_build_options` (see line (4)).  

Then we add a file which has to be compiled with the proc `add_build_file` (see line (5)). This takes a string with the complete source file path and the workspace. You can pass the complete path in any form you like, here the file was constructed with tprint for convenience, using the current path `#filepath` and name `main.jai`.  

In this simple case, `add_build_file("main.jai", w);` works as well. If you have other files to compile, add them one by one with `add_build_file("file.jai", w);`. The compiler will automatically build any files included with the `#load` directive.

Without line (6), compilation of the build program `30.3_build.jai` produces the specified `program.exe`, but also an executable for the build program itself (in our case named `30.exe`). Normally, you're not interested in an executable for the build process itself. To disable its generation, use line (6):
`set_build_options_dc(.{do_output=false});`
_dc means During Compile, and we specify that we don't want any output.

If you don't want to see the generated strings either in .build, you can add: `set_build_options_dc(.{write_added_strings=false});`
This means no executable for the build program itself is generated and no statistics for its compilation are shown (Workspace 2).

### 30.3.2 Compiling with add_build_string
In the previous example, we used the `add_build_file()` proc to add source files to compile to the process. Another way of doing this is to the code as a multiline string with `add_build_string()`, as in the following minimal example:

See *30.3B_build_add_build_string.jai*:
```c++
#import "Basic";
#import "Compiler";
// (1)
TARGET_PROGRAM_TEXT :: #string DONE                
#import "Basic";

main :: () {
    print("This program was built with meta-program 30.3B_build_add_build_string.jai\n");
}
DONE

build :: () {
    w := compiler_create_workspace();                     
    target_options := get_build_options(w);             
    target_options.output_executable_name = "build_string";    
    set_build_options(target_options, w);                 
    add_build_string(TARGET_PROGRAM_TEXT, w);       // (2)
    set_build_options_dc(.{do_output=false});        
}

main :: () {
}

#run build();
```

In this case, we deliver the whole program as one big string in the line following (1), and add it to be compiled in line (2). Nothing prevents you from dividing the program text in several (meaningful) part strings, calling add_build_string for every string.  
Now build it wit the command `jai 30.3B_build_add_build_string.jai`, and run the resulting binary `build_string.exe`, which outputs:  
`This program was built with meta-program 30.3B_build_add_build_string.jai`

Why is this useful? Because working in this way, the code string could be generated by meta-programming at compile-time, instead of being hardcoded in a source file!

> The meta-program `build.jai` has an empty main entry: main :: () {} so as not to get the 'No entry point' compiler error.

When you run the executable `program.exe`, you get the output from `main.jai`:
`This program was built with a meta-program build.jai`.

A build file can instantiate multiple workspaces, to build various different kinds of binaries (executables, static/dynamic libraries). Each build is completely separate from all the others.

> The use of a build() function is not mandatory: your build file could just be a #run { ... }, as illustrated in 30.7_generate_llvm_bitcode.

### 30.3.3 The #placeholder directive
See *30.12_placeholder.jai*:
```c++
#import "Basic";

#placeholder TRUTH;                     // (1)

#run {
   #import "Compiler";
   options := get_build_options();
   add_build_string("TRUTH :: true;");  // (2)
}

main :: () {
   print("TRUTH is %, is it a constant? %\n", TRUTH, is_constant(TRUTH));
   // => TRUTH is true, is a constant? true
}
```
The **#placeholder** directive specifies to the compiler that a particular symbol will be defined/generated by the compile-time meta-program.  
In the program code, the constant TRUTH is 'announced' in line (1), it only gets declared in the #run block with the proc `add_build_string` in line (2). Note how `#import "Compiler";` also can be done in the #run block.  
`add_build_string` adds a string as a piece of code to the program.  

The first argument is a string, the second argument is the workspace (see § 30.1) you want to add it to. You can do all sorts of complex string manipulation to create complex meta-programming code, then add it to your build in string format. 

## 30.4 The build options
See *30.4_build_options.jai*:
```c++
#import "Basic";
#import "Compiler";

build :: () {
    w := compiler_create_workspace();
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    target_options := get_build_options(w);

    target_options.optimization_level = .DEBUG;    
    target_options.backend = .LLVM;               

    target_options.output_type = .EXECUTABLE;      
    target_options.output_executable_name = "my_program";
    target_options.output_path = "./.build";

    import_path: [..] string;
    array_add(*import_path, ..target_options.import_path);
    array_add(*import_path, "d:\\jai\\my_modules");
    target_options.import_path = import_path;
    
    target_options.stack_trace = false;
    target_options.backtrace_on_crash = .OFF;

    target_options.array_bounds_check = .ON; // values: .OFF / .ON / .ALWAYS
    target_options.cast_bounds_check  = .FATAL; 
    target_options.null_pointer_check = .ON;
    target_options.enable_bytecode_inliner = true; 
    
    target_options.runtime_storageless_type_info = true;
    target_options.dead_code_elimination = .NONE;

    format := *context.print_style.default_format_struct;  // (1)
    format.use_newlines_if_long_form = true;
    format.indentation_width = 4;  
    print("Build_Options for Workspace % are: %\n", w, target_options);
    set_build_options_dc(.{do_output=false});              

    set_build_options(target_options, w);
    add_build_file("main.jai", w);
}

main :: () {}

#run build();
```

Specifying the build options for an application is far more easier than writing the program. In Jai all build scripting is done within the language itself, and in the same environment as the rest of the code. This avoids having to use an external build tool (like make or Visual Studio project files that bring their own complications), and makes the building process **cross-platform** and **consistent**.

The `set_build_file_path` proc let's you specify where you want the output executable to be written:
`set_build_file_path("./");`  
This setting puts the output executable in the current folder; which is the default.

A few of the most important build options are shown in the program above and discussed below. You can simply print out the Building_Struct options for inspection as done in line (1) and following, producing this output (see program code for complete output) while running the command `jai 30.4_build_options.jai`:

```
Build_Options for Workspace 3 are: {
    output_type = EXECUTABLE;
    Commonly_Propagated = {
        optimization_level = DEBUG;
        write_added_strings = true;
        runtime_storageless_type_info = true;
        shorten_filenames_in_error_messages = false;
...
```
### 30.4.1 The optimization level
This can be either `.DEBUG` or `.RELEASE`, for example:   
`target_options.optimization_level = .RELEASE;`

For a highly optimized build, having the same effect as `clang -O2`, you would use:
```c++
set_optimization_level(*target_options, 2, 0); 
```
Optimized builds take much longer (10x) time than debug builds, but are around 2x as fast as an un-optimized build.

This automatically turns OFF all runtime checks, and specifies a number of optimizations for LLVM code production.

To enable bytecode inlining, use: `target_options.enable_bytecode_inliner = true;`   
To stop making a .pdb file, use:  `target_options.emit_debug_info=.NONE;`

### 30.4.2 The output type
Possible values are: .NO_OUTPUT; .DYNAMIC_LIBRARY; .STATIC_LIBRARY; .OBJECT_FILE; with as default .EXECUTABLE;
(For examples of usage, see how_to/400_workspaces.jai and Jai\examples\output_types)

### 30.4.3 The output executable name
This is only the filename of the executable, it includes no extension.

### 30.4.3B The output path
This is the path where the executable (and the other compiler artifacts, such as the .pdb) will be written.

### 30.4.3C The import path
If you need to import modules from another folder than the standard *jai\modules*, use options.import_path as shown here.

### 30.4.4 The backend options
Current options are .LLVM and .X64; X64 is the fastest backend.

### 30.4.5 Info about runtime errors and crashes
The `stack_trace` option is by default true. For a release build, set `target_options.stack_trace = false;`  
The `backtrace_on_crash` option is by default .ON

### 30.4.6 Checks at runtime
Array bounds operations, castings and null pointer checks can be turned ON or FATAL/NONFATAL (for cast checks) at runtime to increase robustness of your program, they are so by default. If you are very sure, you can turn them OFF to increase performance

### 30.4.7 runtime_storageless_type_info
Example: `target_options.runtime_storageless_type_info = true;`      
With this option, you can specify whether type_table info is available at runtime (see § 26.1). By default its value is _false_, but if you set its value to _true_, the type table info is not available at runtime, which reduces the executable's size. You’re than basically saying "I don’t want all that data", but you still can use Type_Info and the `type_info` function
This could be useful when writing for an embedded system.

### 30.4.7B Dead code elimination
`target_options.dead_code_elimination = .ALL;`
Normally code that isn't called at run-time (so called dead-code) is NOT compiled: the dead code is eliminated.  
For example a proc that gives a compile error when called won't give any error if not called.  
You can stop this dead-code elimination with this line in your build file:     
`target_options.dead_code_elimination = .NONE;`  
ALternatively, there is the `-no_dce` compiler command-line option (see § 2B).

### 30.4.8 Optimizing LLVM or X64 build
Llvm_options or X64_Options exist for this purpose, but to work with these you have to have a deeper knowledge of the backends.

The LLVM backend options contains many compiler options for optimizing code, turning features of LLVM on or off. Here is a list of some of the flags for the LLVM Options given the `target_options.llvm_options` struct:

```
.enable_tail_calls = false; 
.enable_loop_unrolling = false;
.enable_slp_vectorization = false; 
.enable_loop_vectorization = false; 
.reroll_loop = false; 
.verify_input = false; 
.verify_output = false;
.merge_functions = false;
.disable_inlining = true;
.disable_mem2reg = false;
```

The -O3, -O2, -O1 optimization levels for LLVM can be changed by setting the code_gen_optimization_level field to 3, 2, 1 respectively. For example:  
`target_options.llvm_options.code_gen_optimization_level = 2`  
will set the LLVM options to -O2.

### 30.4.8B Setting machine-level asm options
See 28.6.1

All possible options can be found in module _Compiler_.
You can set additional module import paths with the option `.import_path`, which is an array of strings.

### 30.4.9 Debug- and Release builds
You could make one build file which contains both the debug- and the release-options, like this:

See *build_debug_release.jai*:
```c++
#import "Basic";
#import "Compiler";

build_debug :: () {
  // insert debug compile options here...
}

build_release :: () {
  // insert release compile options here...
}

main :: () {}

#run build_debug();  
// #run build_release();
```

For suitable debug / release options, see § 30.8
To build for production (release), you would do only `#run build_release();`, or use the command-line option `-run build_release()` while executing  
`jai build_debug_release.jai`

### 30.4.10 Preventing the output of compiler messages
If you want a cleaner output, add this code line to the build:
```c++
target_options.text_output_flags = 0; 
```
This line disables most of the text output from the compiler.

## 30.5 Changing the default meta-program
Here is how to substitute the default meta-program with your own:  
Your own meta-program should be a module (let's call it Build, but any name is ok). This Build module must be in a folder Build (either in the default `jai/modules` folder or in a dedicated `modules_folder`) containing a file module.jai. This file has to contain a `build()` proc and a `#run build()` (it should not contain a `main` proc).  
You can start from 30.3_build.jai or _modules/Minimal_Metaprogram.jai_ to make your Build() module. You can then use your meta-program as follows: 
`jai main.jai -- meta Build`  
if Build is in the default jai/modules folder, or  
`jai main.jai -- import_dir "d:/Jai/my_modules" meta Build`  
if Build is in a dedicated _d:/Jai/my_modules_.

The compiler accepts either -- or --- as the delimiter of hardcoded compiler arguments.)