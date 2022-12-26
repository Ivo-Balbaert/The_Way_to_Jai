# 30 Integrated build system

C/C++ compilers do not have a way to specify how to build a program, and are reliant on outside systems foreign to the language to build projects, such as Makefiles, Ninja, and CMake. All these build systems are clunky, need to use a different system for different operating systems, and building a large program can be incredibly messy. 
In Jai, all you would ever need to compile your code is the Jai language and compiler itself, there are no external dependencies.

> JAI provides an integrated build process. Essentially, your source code is the project file, and the compile options are specified in your code. You communicate with the compiler using the same language you’re writing the program in.

We learned about compiling a program with the `jai` command in § 3, while all command-line options were reviewed in § 2B.  

This chapter talks about building (compiling/linking while setting options) a Jai project through running another Jai program: the **meta-program**, which is usually called `build.jai` (it used to be called `first.jai`).  
Most of the procedures we will need are define in module _Compiler_, so we'll import this module in the programs in this chapter. Most of these programs will also be run at compile-time with #run.  
By convention a procedure called `build()` is run with `#run build()`, but you can also just run a code block with `#run {...}` (see 30.11_using_notes.jai).  

Behind the scenes when you do a: `jai program.jai`, the compiler internally runs another meta-program at startup to compile the first workspace. This **default meta-program** does things such as setting up the working directory for the compiler, setting the default name of the output executable based on command-line arguments, and changing between debug and release build based on command-line arguments. It only accepts arguments preceded by a `-`. The source for this metaprogram is in _modules/Default_Metaprogram.jai_. 

Any procedure that has the **#compiler** directive is a proc that interfaces with the compiler as a library; it works with compiler internals.

## 30.1 Workspaces
You've probably noticed that every successful compile output (let's say `jai program.jai`) contains the sentence:  
`Stats for Workspace 2 ("Target Program"):`
The 'Target Program' mentioned here is `program.jai`. For each program that is built by the compiler, a different **workspace** is used. A workspace represents a completely separate environment, inside which we can compile programs. When the compiler starts up, it makes a workspace for the first files that you tell it to compile on the command-line. 

See *30.1_workspaces.jai*:
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
When launching the compiler, a default hidden workspace (number 1) is started.

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

The first step in the building process is always to create a new workspace w (see line (1)), which will be Workspace 3. Sot he following workspaces are created:
* Workspace 1: reserved for inner compiler workings;
* Workspace 2: reserved for the target program, here `build.jai`;
* Workspace 3: reserved for the building script (we could call it a script, although it's completely written in Jai);

Then we want to configure the build options. We first get the current build options from the workspace with the procedure `get_build_options(w)`, which returns an instance of the struct `Build_Options`. This struct is defined in module _Compiler_, and contains some 45 options you can tweak about how the compilation works!  
In this first example, we only set the field `output_executable_name` (line (3)).  
After all necessary build options have been configured, we write them back to the workspace with the proc `set_build_options` (see line (4)).  
Then we add a file which has to be compiled with the proc `add_build_file` (see line (5)). This takes a string with the complete source file path and the workspace. You can pass the complete path in any form you like, here the file was constructed with tprint for convenience, using the current path `#filepath` and name `main.jai`. In this simple case, `add_build_file("main.jai", w);` works as well. If you have other files to compile, add them one by one with `add_build_file("file.jai", w);`. The compiler will automatically build any files included with the `#load` directive.
Without line (6), compilation of the build program `30.3_build.jai` produces the specified `program.exe`, but also an executable for the build program itself (in our case named `30.exe`). Normally, you're not interested in an executable for the build process itself. To disable its generation, use line (6):
`set_build_options_dc(.{do_output=false});`
_dc means During Compile, and we specify that we don't want any output. This means no executable for the build program itself is generated and no statistics for its compilation are shown (Workspace 2).

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
    print("This program was built with metaprogram 30.3B_build_add_build_string.jai\n");
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
`This program was built with metaprogram 30.3B_build_add_build_string.jai`

Why is this useful? Because working in this way, the code string could be generated by metaprogramming at compile-time, instead of being hardcoded in a source file!

> Remark: The meta-program `build.jai` has an empty main entry: main :: () {} so as not to get the 'No entry point' compiler error.

When you run the executable `program.exe`, you get the output from `main.jai`:
`This program was built with a metaprogram build.jai`.

> Remark: The use of a build() function is not mandatory: your build file could just be a #run { ... }, as illustrated in 30.7_generate_llvm_bitcode.


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
    
    target_options.stack_trace = false;
    target_options.backtrace_on_crash = .OFF;

    target_options.array_bounds_check = .ON; // values: .OFF / .ON / .ALWAYS
    target_options.cast_bounds_check  = .FATAL; 
    target_options.null_pointer_check = .ON; 
    
    target_options.runtime_storageless_type_info = true;

    format := *context.print_style.default_format_struct;  // (1)
    format.use_newlines_if_long_form = true;
    format.indentation_width = 4;  
    print("Build_Options for Workspace % are: %\n", w, target_options);

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
Optimized builds take much longer (??) time than debug builds, but are around 2x as fast as an un-optimized build.

This automatically turns OFF all runtime checks, and specifies a number of optimizations for LLVM code production.

To stop making a .pdb file, use:
`target_options.emit_debug_info=.NONE;`

### 30.4.2 The output type
Possible values are: .NO_OUTPUT; .DYNAMIC_LIBRARY; .STATIC_LIBRARY; .OBJECT_FILE; with as default .EXECUTABLE;

### 30.4.3 The output executable name
This is only the filename of the executable, it includes no extension.

### 30.4.4 The backend options
Current options are .LLVM and .X64; X64 is the fastest backend.

### 30.4.5 Info about runtime errors and crashes
The `stack_trace` option is by default true. For a release build, set `target_options.stack_trace = false;`  
The `backtrace_on_crash` option is by default .ON

### 30.4.6 Checks at runtime
Array bounds operations, castings and null pointer checks can be turned ON or FATAL/NONFATAL (for cast checks) at runtime to increase robustness of your program, they are so by default. If you are very sure, you can turn them OFF to increase performance

### 30.4.7 runtime_storageless_type_info
With this option, you can specify whether type_table info is available at runtime (see § 26.1). If you set its value to _true_, type table info is not available at runtime, which reduces the executable's size somewhat. This could be useful when writing for an embedded system. However even when true, the `type_info` function still works.

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
To build for production (release), you would do only `#run build_release();`, or use the command-line option `-run build_release()` while doing `jai build_debug_release.jai`

## 30.5 Changing the default metaprogram
Here is how to substitute the default metaprogram with your own:  
Your own metaprogram should be a module (let's call it Build, but any name is ok). This Build module must be in a folder Build (either in the default `jai/modules` folder or in a dedicated `modules_folder`) containing a file module.jai. This file has to contain a `build()` proc and a `#run build()` (it should not contain a `main` proc. You can start from 30.3_build.jai or  _modules/Minimal_Metaprogram.jai_ to make your Build() module. You can then use your metaprogram as follows: 
`jai main.jai -- meta Build`  
if Build is in the default jai/modules folder, or  
`jai main.jai -- import_dir "d:/Jai/my_modules" meta Build`  
if Build is in a dedicated _d:/Jai/my_modules_.
(--- instead of -- are also allowed. The compiler now accepts either -- or --- as the delimiter of hardcoded compiler arguments.)
## 30.6 Intercepting the compiler message loop
As developer you can access the workings of the compiler through the compiler message loop.

See *30.5_compiler_intercept.jai*:
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
            print(" >> %\n", <<message);
            break;
            }
            case .FILE; {            
            message_file := cast(*Message_File) message;    // (6)
//          print("Loading file '%'.\n", message_file.fully_pathed_filename); // (7)
            }
            case .IMPORT; {            
                message_import := cast(*Message_Import) message;          // (8)
//              print("Import module '%'\n", message_import.module_name); // (9)
            }
            case .PHASE; {            
                message_phase := cast(*Message_Phase) message;     // (10)
//              print("Entering phase %\n", message_phase.phase);  // (11)
            }
            case .TYPECHECKED; {            
                message_typechecked := cast(*Message_Typechecked) message; // (12)
                for message_typechecked.declarations {  // (13)
//                    print("Code declaration: %\n", it);
               }
            }
            case .DEBUG_DUMP; {            
               dump_message := cast(*Message_Debug_Dump) message;   // (14)
//             print("Here is the dump text: %\n", dump_message.dump_text); // (15)
            }
            case .ERROR; {            
                // handle error
            }
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
Firstly, we can examine what is exactly happening during code compilation:  
(Comment out line (4) to focus on a specific message.)
For other useful examples, see § 30.6 - 30.8.

1) `.FILE` triggers once for each source code file loaded during compilation. You can see which files are loaded: see lines (6)-(7).  
This gives as output:  
```
Loading file 'c:/jai/modules/Preload.jai'.
Loading file 'D:/Jai/The_Way_to_Jai/examples/30/main.jai'.
Loading file 'c:/jai/modules/Runtime_Support.jai'.
Loading file 'c:/jai/modules/Basic/module.jai'.
Loading file 'c:/jai/modules/Basic/Array.jai'.
Loading file 'c:/jai/modules/Basic/Simple_String.jai'.
Loading file 'c:/jai/modules/Basic/String_Builder.jai'.
Loading file 'c:/jai/modules/Basic/string_to_float.jai'.
Loading file 'c:/jai/modules/Basic/Apollo_Time.jai'.
Loading file 'c:/jai/modules/Basic/Print.jai'.
Loading file 'c:/jai/modules/Basic/windows.jai'.
Loading file 'c:/jai/modules/Windows_Utf8.jai'.
Loading file 'c:/jai/modules/Windows.jai'.
Loading file 'c:/jai/modules/Runtime_Support_Crash_Handler.jai'.
Loading file 'c:/jai/modules/stb_sprintf/module.jai'. 
```

2) `.IMPORT` is signalled whenever a new module is loaded. Every module is important only once; even when you have for example several #import "Basic", importing happens only one time. You can see which modules are imported: see lines (8)-(9).  

```
Import module 'Preload'
Import module ''
Import module 'Runtime_Support'
Import module 'Basic'
Import module 'Runtime_Support'
Import module 'Windows'
Import module 'Windows_Utf8'
Import module 'Runtime_Support_Crash_Handler'
Import module 'stb_sprintf'
```

3) `.PHASE` every time when entering a new phase in the compilation (defined in the enum Message_Phase). You can see the successive compilation phases : see lines (10)-(11).  
```
Entering phase ALL_SOURCE_CODE_PARSED
Entering phase ALL_SOURCE_CODE_PARSED
Entering phase ALL_SOURCE_CODE_PARSED
Entering phase ALL_SOURCE_CODE_PARSED
Entering phase TYPECHECKED_ALL_WE_CAN
Entering phase ALL_TARGET_CODE_BUILT
Entering phase PRE_WRITE_EXECUTABLE
```

Here are all possible compilation phases:  
```c++
phase: enum u32 {
  ALL_SOURCE_CODE_PARSED        :: 0;
  TYPECHECKED_ALL_WE_CAN        :: 1;
  ALL_TARGET_CODE_BUILT         :: 2;
  PRE_WRITE_EXECUTABLE          :: 3;
  POST_WRITE_EXECUTABLE         :: 4;
  READY_FOR_CUSTOM_LINK_COMMAND :: 5;
}
```

If you want Jai to do just the typechecking and not to compile anything, the metaprogram (build.jai) should exit after compiler message TYPECHECKED_ALL_WE_CAN (see lines 11B and following).

4) `.TYPECHECKED` every time code has passed typechecking, this gives an huge amount of output : see lines (12)-(13).  

```
Code declaration: {adb_1168, [adb_11f0, adb_1168]}
Code declaration: {adb_22f0, [adb_2378, adb_22f0]}
Code declaration: {adb_23d8, [adb_2460, adb_23d8]}
Code declaration: {adb_24a8, [adb_2530, adb_24a8]}
...
```

5) `.DEBUG_DUMP` when a crash occurs during compilation, the dump info can be viewed like in lines (14)-(15).

6) `.ERROR`: when an error occurs in the compilation process itself, you can handle it here.  
   
7) `.COMPLETE`: triggers when compilation is finished. Here you will `break` out of the `while true` compiler message loop.

All these enum options contain a lot more useful info (see module _Compile_).
You can also run any other program after successful completion.

Another use-case would be to run the program after successful completion of the compilation, or any other program for that matter.  

## 30.7 Building and running on successful compilation
What if we want to build our project, and on successfull completion, run it?

See *30.6_build_and_run.jai*:
```c++
#import "Basic";
#import "Compiler";
#import "Process";

success := false;

build :: () {
    w := compiler_create_workspace();                     
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    target_options := get_build_options(w);               
    target_options.output_executable_name = "brun";    
    set_build_options(target_options, w);                 

    compiler_begin_intercept(w);     
    add_build_file("main2.jai", w);   
    
    while true {                     
        message := compiler_wait_for_message();  
        if !message break; 
        if message.kind == {
            case .COMPLETE;          // (1)
                print(" >> %\n", <<message);
                message_complete := cast(*Message_Complete) message;  // (2)
                success = message_complete.error_code == 0;           // (3)
                break;
        }
    }
    compiler_end_intercept(w);   

    if success {            
        print("[SUCCESS!]\n");
        run_command(target_options.output_executable_name);  // (4)
    }    
}

main :: () {}

#run build();

/*
...
>> {COMPLETE, 3}
[SUCCESS!]
This program was built with metaprogram 30.8_build_and_run.jai
...
*/
```

This is easily done: when the .COMPLETE message is received, we check that the error_code of the message is 0. If so, we set a global variable `success` to true (see lines (2) and (3)). Then at the end of our build program, we print a "SUCCES" message, and run our compiled program with the `run_command` procedure from module _Process_.  
In the output we see:
```
...
>> {COMPLETE, 3}
[SUCCESS!]
This program was built with metaprogram 30.8_build_and_run.jai
...
```

## 30.8 Building and running with a compiler command-line argument 
In § 2B we told you that arguments given at the end of a `jai` command with `- ` are arguments for the meta-program. These arguments are called  _compiler command-line arguments_.
Now we will show you how to use them, enhancing our previous program.

See *30.7_build_and_run2.jai*:
```c++
#import "Basic";
#import "Compiler";
#import "Process";

success := false;           // compile is successful
run_on_success := false;    // compiler command line argument - run

build :: () {
    w := compiler_create_workspace();                     
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    target_options := get_build_options(w);               
    
    args := target_options.compile_time_command_line;  // (1)
    for args {                                         // (2)
        print ("% / ", it);
        if it == {
            case "run";
                run_on_success = true;
        }
    }
   
    target_options.output_executable_name = "brun";    
    set_build_options(target_options, w);                 

    compiler_begin_intercept(w);     
    add_build_file("main2.jai", w);   
    
    while true {                     
        message := compiler_wait_for_message();  
        if !message break; 
        if message.kind == {
            case .COMPLETE;         
                print(" >> %\n", <<message);
                message_complete := cast(*Message_Complete) message;  
                success = message_complete.error_code == 0;           
                break;
        }
    }
    compiler_end_intercept(w);   

    if success && run_on_success {         // (3)   
        print("[SUCCESS!]\n");
        run_command(target_options.output_executable_name);  
    }    
}

main :: () {}

#run build();
```

We define a new global variable `run_on_success` which will become true when we give a metaprogram argument `- run`.
In line (1) we get these argument(s) from the property `Build_Options.compile_time_command_line`. Starting in line (2), we loop over them and set `run_on_success` when finding `- run`. In line (3) we now test both success parameters before running the executable.  
To get the same output as in the previous section, you now have to call the compiler with:  
`jai 30.7_build_and_run2.jai - run`.

## 30.9 Choosing a debug / release build with compiler command-line arguments
In the same way as in the previous section, we can decide to either do a debug build or a release build based on the given command-line argument. This is shown in the following code, which is a further development of the code in § 30.4.8:

See *30.8_debug_release_build.jai*:
```c++

#import "Basic";
#import "Compiler";

#run {
    w := compiler_create_workspace("workspace");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    target_options := get_build_options(w);
    args := target_options.compile_time_command_line;
    for arg: args {       // (1)
        if arg == {
            case "debug";
                build_debug(w);
            case "release";
                build_release(w);
        }
    }
    add_build_file("main3.jai", w);
}

build_debug :: (w: Workspace) {
    print("Choosing debug options...\n");
    target_options := get_build_options(w);
    target_options.backend =.X64; 
    target_options.optimization_level = .DEBUG;
    target_options.array_bounds_check = .ON;
    target_options.output_executable_name = "main3";   
    set_build_options(target_options, w);
}

build_release :: (w: Workspace) {
    print("Choosing release options...\n");
    target_options := get_build_options(w);
    target_options.backend = .LLVM;
    target_options.optimization_level = .RELEASE;
    set_optimization_level(*target_options, 2, 0);
    target_options.output_executable_name = "main3";   
    set_build_options(target_options, w);
}

main :: () {}
```

Again we loop over the meta-program arguments starting in line (1).
Calling the program as `jai 30.8_debug_release_build.jai - debug` supplies the meta-program argument `- debug`, which branches to `case "debug";`, which calls `build_debug(w);` 
It prints out `Choosing debug options...` during compilation.
(The same logic goes for `- release.`)    

Calling `main3` now shows: main3
`This program was built with metaprogram 30.8_debug_release_build.jai`

`build_debug` shows the recommended debug options:  
- backend = .X64  
// it is faster than the LLVM backend, but for most programs the difference is negligible
- optimization_level = .DEBUG
- array_bounds_check = .ON

This build compiles faster with as much debugging information as possible, but has some overhead in order to help debug. An executable built in debug mode will, for example, tell the programmer on which line of code the program crashed on, and check for array out of bounds errors. As expected from debug builds, the code is not as optimized as a release build.

`build_release` shows the recommended release options:  
- backend = .LLVM 
// it is slower than the X64 backend, but it does a lot more optimizations. 
- optimization_level = .RELEASE
- set_optimization_level(target_options, 2, 0); // same as clang -O2

This build makes the compiler produce the best possible optimized code. An optimized build does not have debug information built into it, and takes longer to compile.

## 30.10 Enforcing coding standards
Another use-case would be enforcing coding house rules, an example is shown in 30.9_house_rules.jai , which shows how to enforce compile-time code checking, for example the MISRA standards (in this case: Check for Multiple Levels of Pointer Indirection, so that you cannot do you cannot do `a: ***int = b;` for example).  

MISRA coding standards are a set of C and C++ coding standards, developed by the Motor Industry Software Reliability Association (MISRA). These are standards specific to the automotive industry,.

See _30.9_house_rules.jai:
```c++
#import "Basic";
#import "Compiler";

#run build();

build :: () {
    w := compiler_create_workspace("Target Program");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    target_options := get_build_options(w);
    target_options.output_executable_name = "checks";
    set_build_options(target_options, w);

    compiler_begin_intercept(w);
    add_build_file("main.jai", w);

    while true {
        message := compiler_wait_for_message();
        if !message break;
        misra_checks(message);  // (1)

        if message.kind == .COMPLETE  break;
    }

    compiler_end_intercept(w);
    set_build_options_dc(.{do_output=false});   // (2)
}

misra_checks :: (message: *Message) {
    if message.kind != .TYPECHECKED return;
    code := cast(*Message_Typechecked) message;
    for code.declarations {
        decl := it.expression;
        check_pointer_level_misra_17_5(decl);
    }

    for tc: code.all {
        expr := tc.expression;
        if expr.enclosing_load {
            if expr.enclosing_load.enclosing_import.module_type != .MAIN_PROGRAM  continue;
        }
        
        for tc.subexpressions {
            // Check rule 17.5. We already did the pointer-level check for global declarations
            // but, local declarations don't come in separate messages; instead, we check them here.
            if it.kind == .DECLARATION {
                sub_decl := cast(*Code_Declaration) it;
                check_pointer_level_misra_17_5(sub_decl); 
            }
        }
    }

    check_pointer_level_misra_17_5 :: (decl: *Code_Declaration) {
        type := decl.type;
        pointer_level := 0;
    
        while type.type == .POINTER {
            pointer_level += 1;
            p := cast(*Type_Info_Pointer) type;
            type = p.pointer_to;
        }
        if pointer_level > 2 {
            location := make_location(decl);
            compiler_report("Too many levels of pointer indirection.\n", location);
        }
    }
}
```

During the compiler message loop in line (1), we inject a proc `misra_checks()`, which tests every message on a specific code rule, here the `check_pointer_level_misra_17_5` rule which forbids more than 2 levels of pointer indirection. Line (2) ensures that this metaprogram does not generate any output executable.

Run the check with: `jai 30.9_house_rules.jai`. If the program obeys the rule(s), nothing is shown, but if you substitute main5.jai (which has too many levels of indirection) for main.jai, you get the output:
```
In Workspace 2 ("Target Program"):
D:/Jai/The_Way_to_Jai/examples/30/main5.jai:4,3: Error: Too many levels of pointer indirection.


    a: *int;
    b := *a;
    c := *b; // Too many levels of pointer indirection! c is of Type (***int)
```

## 30.11 Generating optimized LLVM bitcode
See *30.10_generate_llvm_bitcode.jai*:
```c++
#import "Basic";
#import "Compiler";

#run {
    w := compiler_create_workspace();
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    target_options := get_build_options(w);
    target_options.output_executable_name = "exec";
    target_options.intermediate_path = #filepath;
    set_optimization_level(*target_options, 2, 0);      // (1)
    target_options.llvm_options.output_bitcode = true;  // (2)
    set_build_options(target_options, w);

    compiler_begin_intercept(w);
    add_build_file("main.jai", w);  

    while true {
        message := compiler_wait_for_message();
        if !message break;
        if message.kind == {
        case .COMPLETE;
        break;
        }
    }
    compiler_end_intercept(w);
    set_build_options_dc(.{do_output=false});  
}
```

The program above shows how to build an optimized LLVM executable; the instructions for optimization are in lines (1) and (2). 
By default, the bitcode is outputted to the `.build` folder. However, you can change where the bitcode is written by changing the intermediate path of the compiler as follows:
`target_options.intermediate_path = #filepath;`  
to write it next to the source file, or giving another folder path in the right-hand side.

Type and ENTER: `jai 30.10_generate_llvm_bitcode.jai`  
Now no .build folder is generated, and an exec.exe, exec.exp, exec.pdb, exec.lib, exec_0_w3.bc and exec_0_w3.obj are now written in the same folder as the source file. The `.bc` file contains the LLVM bitcode. exec runs the Jai code in main.jai
You might notice that compiling now takes a bit longer. If you don't use the compiler loop, you can just remove it or comment it out.

If you have LLVM installed on your system, you can use `llc` to transform the bitcode into assembler:  
`llc < your_bitcode.bc > output.asm`  
and then run the assembly code with:
`as output.asm`

## 30.12 Using notes to do special metaprogramming
Notes on a struct or function were described in § 15.7, and code was shown to display them in § 15.5. The note tags will also show up in a metaprogram, and you can use them to do special metaprogramming such as custom program typechecking and modifying the executable based on the metaprogram.

In _main4.jai_ we have tagged a number of procs with the note `@fruit`.

See *main4.jai*:
```c++
#import "Basic";

dog :: () {
  print("dog\n");
} @fruit

banana :: () {
  print("banana\n");
} @fruit

apple :: () {
  print("apple\n");
} @fruit

cherry :: () {
  print("cherry\n");
} @fruit

elephant :: () {
  print("elephant\n");
} @fruit
```

The program contains no `main` proc; this will be created by the metaprogram!

The metaprogram finds all the procs tagged @note and adds them to an array of strings called `procs` declared in line (1). It then sorts procs alphabetically, and generates a main proc that calls all procs tagged @fruit in alphabetical order.

See *30.11_using_notes.jai*:
```c++
#import "Compiler";
#import "String";
#import "Basic";
#import "Sort";

#run {
  w := compiler_create_workspace();

  options := get_build_options(w);
  options.output_executable_name = "notes";
  set_build_options(options, w);

  compiler_begin_intercept(w);
  add_build_file("main4.jai", w);  

  procs: [..] string;                           // (1)
  gen_code := false;
  while true {
    message := compiler_wait_for_message();
    if !message break;
    if message.kind == {
    case .TYPECHECKED;
      typechecked := cast(*Message_Typechecked) message;
      for decl: typechecked.declarations {
        if equal(decl.expression.name , "main") {
          continue;
        }
        for note: decl.expression.notes {       // (2)
          if equal(note.text, "fruit") {
            array_add(*procs, copy_string(decl.expression.name));
          }
        }
    }
    case .PHASE;                                // (3)
      phase := cast(*Message_Phase) message;
      if gen_code == false && phase.phase == .TYPECHECKED_ALL_WE_CAN {
        code := generate_code();                // (4)
        add_build_string(code, w);              // (5)
        gen_code = true;
    }
    case .COMPLETE;
      break;
    }
  }
  compiler_end_intercept(w);
  set_build_options_dc(.{do_output=false});

  generate_code :: () -> string #expand {       // (6)
    bubble_sort(procs, compare);                // (7)
    builder: String_Builder;
    append(*builder, "main :: () {\n");
    for proc: procs {
      print_to_builder(*builder, "  %1();\n", proc);
    }
    append(*builder, "}\n");
    return builder_to_string(*builder);
  }
}
```

In line (2), all possible notes are checked after each TYPECHECKING phase:  
`for note: decl.expression.notes { }`  
If the note contains "fruit", the proc's name is added to the array `procs`.  
The code starting in line (3) shows how to generate new code (in this case a `main` proc) after the TYPECHECKED_ALL_WE_CAN phase. `generate_code()` (called in line (4) and defined in line (6)) is a macro that produces a string which contains the code for a `main` proc, printing out the names of all procs with the note @fruit alphabetically. The sorting is done by first calling `bubblesort` from module _Sort_, which also calls a `compare` proc from module _String_.
A bool flag variable gen_code is used so that this generation is done only once.  
Let's see the results. First run the metaprogram:  
`jai 30.11_using_notes.jai`  
Then run the generated executable `notes.exe`:  
notes  
which produces as output:  
```
apple
banana
cherry
dog
elephant
```





