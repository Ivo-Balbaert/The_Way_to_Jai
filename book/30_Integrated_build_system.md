# 30 Integrated build system.md

C/C++ compilers do not have a way to specify how to build a program, and are reliant on outside systems foreign to the language to build projects, such as Makefiles, Ninja, and CMake. All these build systems are clunky, need to use a different system for different operating systems, and building a large program can be incredibly messy. 
In Jai, all you would ever need to compile your code is the Jai language and compiler itself, there are no external dependencies.

> JAI provides an integrated build process. Essentially, your source code is the project file, and the compile options are specified in your code. You communicate with the compiler using the same language you’re writing the program in.

We learned about compiling a program with the `jai` command in § 3, while all command-line options were reviewed in § 2B. This chapter talks about building (compiling/linking while setting options) a Jai project through running another Jai program: the meta-program, which is usually called `build.jai` (it used to be called `first.jai`).  
Most of the procedures we will need are define in module _Compiler_, so we'll import this module in the programs in this chapter. Most of these programs will also be run at compile-time with #run. By convention a procedure called `build()` is run:  `#run build()`
Any procedure that has the **#compiler** directive is a proc that interfaces with the compiler as a library; it works with compiler internals.

## 30.1 Workspaces
You've probably noticed that every successful compile output (let's say `jai program.jai`) contains the sentence:  
`Stats for Workspace 2 ("Target Program"):`
The 'Target Program' mentioned here is `program.jai`. For each program that is built by the compiler, a different **workspace** is used. A workspace represents a completely separate environment, inside which we can compile programs. When the compiler starts up, it makes a workspace for the first files that you tell it to compile on the command-line. 

See _30.1_workspaces.jai_:
```c++
#import "Basic";
#import "Compiler";

build :: () {
  w2 := get_current_workspace();        // (1)
  print("The current workspace is %\n", w2); // => The current workspace is 2
 
  w3 := compiler_create_workspace();    // (2)
  if !w3 {
    print("Workspace creation failed.\n");
    return;
  }
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
You can ask the compiler to create one or several different new workspaces with the procedure `compiler_create_workspace();` which returns a variable of type Workspace (see line (2)). It can only be run at compile-time.  
Different workspaces run completely separate from each other, one workspace does not affect another workspace.

_Why is the workspace for the target program at the command-line called 'Workspace 2'?_
When launching the compiler, a default workspace (number 1) is started.

## 30.2 The source file location directives
See _30.2_location.jai_:
```c++
#import "Basic";

main :: () { 
  print("In file % line %\n", #file, #line); // (1)
  // => In file d:/Jai/The_Way_to_Jai/examples/30/30.2_location.jai line 5
  print("Filepath is %\n", #filepath);       // (2)
  // => Filepath is d:/Jai/The_Way_to_Jai/examples/30/
}
```
A few directives exist that can be handy when providing file location information, at run-time as well as during compiling:  
  **#file**         contains the complete path, filename included of the current file
  **#line**         gives the number of the line of code where this directive is used
  **#filepath**     contains the path to the current file, without the filename; it can be a remote filepath.

When using or setting file-paths in Jai, always use the forward slash / as path-separator, even on Windows!

## 30.3 A minimal build file
See _30.3_build.jai_:
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
    }

    main :: () {}

    #run build();
```

The building process is done at compile-time when `#run build();` is executed.  

The first step in the building process is always to create a new workspace w (see line (1)), which will be Workspace 3. So when doing `jai build.jai`:
* Workspace 1: reserved for inner compiler workings;
* Workspace 2: reserved for the target program, here `build.jai`;
* Workspace 3: reserved for the building script (we could call it a script, although it's completely written in Jai);

Then we want to configure the build options. We first get the current build options from the workspace with the procedure `get_build_options(w)`, which returns an instance of the struct `Build_Options`. This struct is defined in module _Compiler_, and contains some 45 options you can tweak about how the compilation works!  
In this first example, we only set the field `output_executable_name` (line (3)).  
After all necessary build options have been configured, we write them back to the workspace with the proc `set_build_options` (see line (4)).  
Then we add a file which has to be compiled with the proc `add_build_file` (see line (5)). This takes a string with the complete source file path and the workspace. You can pass the complete path in any form you like, here the file was constructed with tprint for convenience, using the current path `#filepath` and name `main.jai`. In this simple case, `add_build_file("main.jai", w);` works as well. If you have other files to compile, add them one by one with `add_build_file("file.jai", w);`. The compiler will automatically build any files included with the `#load` directive.

> Remark: The meta-program `build.jai` has an empty main entry: main :: () {} so as not to get the 'No entry point' compiler error.

When you run the executable `program.exe`, you get the output from `main.jai`:
`This program was built with a metaprogram build.jai`.

## 30.4 The build options
See _30.4_build_options.jai_:
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
  
  target_options.stack_trace = false;
  target_options.backtrace_on_crash = .OFF;

  target_options.array_bounds_check = .OFF;
  target_options.cast_bounds_check  = .OFF; 
  target_options.null_pointer_check = .OFF; 
  
  target_options.runtime_storageless_type_info = true;

  set_build_options(target_options, w);
  set_build_file_path("./");

  add_build_file("main.jai", w);
}

main :: () {}

#run build();
```

Specifying the build options for an application is far more easier than writing the program. In Jai all build scripting is done within the language itself, and in the same environment as the rest of the code. This avoids having to use an external build tool (like make or Visual Studio project files that bring their own complications), and makes the building process **cross-platform** and **consistent**.

The `set_build_file_path` proc let's you specify where you want the output executable to be written:
`set_build_file_path("./");`  
This setting puts the output executable in the current folder; which is the default.

A few of the most important build options are shown in the program above and discussed below.  
### 30.4.1 The optimization level
This can be either `.DEBUG` or `.RELEASE`.  
For a highly optimized build, having the same effect as `clang -O2`, you would use:
```c++
set_optimization_level(*target_options, 2, 0); 
```

This automatically turns OFF all runtime checks, and specifies a number of optimizations for LLVM code production.

### 30.4.2 The output type
Possible values are: .NO_OUTPUT; .DYNAMIC_LIBRARY; .STATIC_LIBRARY; .OBJECT_FILE; with default .EXECUTABLE;

### 30.4.3 The output executable name
This is only the filename of the executable, it includes no extension.

### 30.4.4 The backend options
Current options are .LLVM and .X64

### 30.4.5 Info about runtime errors and crashes
The `stack_trace` option is by default true. `backtrace_on_crash` is by default .ON

### 30.4.6 Checks at runtime
Array bounds operations, castings and null pointer checks can be turned ON at runtime to increase robustness of your program, they are so by default. If you are very sure, you can turn them off (which is done in this program) to increase performance

### 30.4.7 runtime_storageless_type_info
With this option, you can specify whether type_table info is available at runtime (see § 26.1). If you set its value to _true_, type table info is not available at runtime, which reduces the executable's size somewhat. However even when true, the `type_info` function still works.

### 30.4.8 Optimizing LLVM or X64 build
Llvm_options or X64_Options exist for this purpose, but to work with these you have to have a deeper knowledge of the backends.

You can set additional module import paths with the option `.import_path`, which is an array of strings.

You could make one build file which contains both the debug- and the release-options, like this:
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

To build for production (release), you would do only `#run build_release();`, or use the command-line option `-run build_release()` while doing `jai build_debug_release.jai`

## 30.5 Intercepting the compiler message loop
As developer you can access the workings of the compiler through the compiler message loop.

See _30.5_compiler_intercept.jai_:
```c++
#import "Basic";
#import "Compiler";

build :: () {
    w := compiler_create_workspace();                     
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    print("The current workspace is %\n", w); // => The current workspace is 3

    target_options := get_build_options(w);               
    target_options.output_executable_name = "program";    
    set_build_options(target_options, w);                 

    compiler_begin_intercept(w);     // (1)

    add_build_file(tprint("%/main.jai", #filepath), w);   
    
    while true {                     // (2)          
        message := compiler_wait_for_message();  // (3)
        print(" >> %\n", <<message); // (4) => see output below
        if !message break;
        if message.kind == {
            case .COMPLETE;          // (5)
            break;
        }
    }
    compiler_end_intercept(w);       // (1B)
}

main :: () {}

#run build();

/*
>> {IMPORT, 3}
 >> {FILE, 3}
 ...
 >> {PHASE, 3}
 >> {TYPECHECKED, 3}
 ...
 >> {PHASE, 3}
Running linker: 
 >> {PHASE, 3}

Stats for Workspace 3 (unnamed):
 >> {COMPLETE, 3}
 */
```

You do that by getting a hook into the compiler loop with `compiler_begin_intercept(w);` (line (1)), which is removed after the compiler access with `compiler_end_intercept(w);` (line (1B)).
Then in a while true loop in line (2), we do: `message := compiler_wait_for_message();` and print out the message. Because this is an infinite loop, we need to stop when the compiler signals the end of its work with the COMPLETE message; this is done in line (5).
In the output, the same kind of messages appear over and over (like IMPORT, FILE, PHASE, TYPECHECKED, ... which is the `kind` of the message), and at the end we get {COMPLETE, 3} (The 3 always refers to workspace 3).

What can we do with this functionality?

=======================================================
Compiler get nodes
Compiler command arguments
Placeholder ??