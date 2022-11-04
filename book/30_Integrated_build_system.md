# 30 Integrated build system

C/C++ compilers do not have a way to specify how to build a program, and are reliant on outside systems foreign to the language to build projects, such as Makefiles, Ninja, and CMake. All these build systems are clunky, need to use a different system for different operating systems, and building a large program can be incredibly messy. 
In Jai, all you would ever need to compile your code is the Jai language and compiler itself, there are no external dependencies.

> JAI provides an integrated build process. Essentially, your source code is the project file, and the compile options are specified in your code. You communicate with the compiler using the same language you’re writing the program in.

We learned about compiling a program with the `jai` command in § 3, while all command-line options were reviewed in § 2B. This chapter talks about building (compiling/linking while setting options) a Jai project through running another Jai program: the **meta-program**, which is usually called `build.jai` (it used to be called `first.jai`).  
Most of the procedures we will need are define in module _Compiler_, so we'll import this module in the programs in this chapter. Most of these programs will also be run at compile-time with #run.  
By convention a procedure called `build()` is run:  `#run build()`  
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
    // => In file d:/Jai/The_Way_to_Jai/examples/30/30.2_location.jai line 4
    print("Filepath is %\n", #filepath);       // (2)
    // => Filepath is d:/Jai/The_Way_to_Jai/examples/30/
    loc := #location(code);                    // (3)
    print("The code is at location %:%\n", loc.fully_pathed_filename, loc.line_number);
    // => The code is at location d:/Jai/The_Way_to_Jai/examples/30/30.2_location.jai:3 
}
```
A few directives exist that can be handy when providing file location information, at run-time as well as during compiling:  
  **#file**         contains the complete path, filename included of the current file  
  **#line**         gives the number of the line of code where this directive is used
  **#filepath**     contains the path to the current file, without the filename; it can be a remote filepath.
  **#location**     given a piece of Code, it can extract the full path to that code, as well as its line number.

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

> Remark: The use of a build() function is not mandatory: your build file could just be a #run { ... }, as illustrated in 30.7_generate_llvm_bitcode.

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
Current options are .LLVM and .X64; X64 is the fastest backend.

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

For suitable debug / release options, see § 30.8
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

1) `.FILE` is signalled whenever a new file is loaded. You can see which files are loaded: see lines (6)-(7).  
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

2) `.IMPORTED` is signalled whenever a new module is loaded. You can see which modules are imported: see lines (8)-(9).  

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

3) `.PHASE` every time when entering a new phase in the compilation. You can see the successive compilation phases : see lines (10)-(11).  
```
Entering phase ALL_SOURCE_CODE_PARSED
Entering phase ALL_SOURCE_CODE_PARSED
Entering phase ALL_SOURCE_CODE_PARSED
Entering phase ALL_SOURCE_CODE_PARSED
Entering phase TYPECHECKED_ALL_WE_CAN
Entering phase ALL_TARGET_CODE_BUILT
Entering phase PRE_WRITE_EXECUTABLE
```

4) `.TYPECHECKED` every time a code declaration is typechecked, this gives an huge amount of output : see lines (12)-(13).  

```
Code declaration: {adb_1168, [adb_11f0, adb_1168]}
Code declaration: {adb_22f0, [adb_2378, adb_22f0]}
Code declaration: {adb_23d8, [adb_2460, adb_23d8]}
Code declaration: {adb_24a8, [adb_2530, adb_24a8]}
...
```

5) `.DEBUG_DUMP` when a crash occurs during compilation, the dump info can be viewed like in lines (14)-(15).

6) `.ERROR`: when an error occurs in the compilation process itself, you can handle it here..

All these enum options contain a lot more useful info (see module _Compile_).
You can also run any other program after successful completion.

Another use-case would be to run the program after successful completion of the compilation, or any other program for that matter. 

## 30.6 Building and running on successful compilation
What if we want to build our project, and on successfull completion, run it?

See _30.6_build_and_run.jai_:
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

## 30.7 Building and running with a compiler command-line argument 
In § 2B we told you that arguments given at the end of a `jai` command with `-- ` are arguments for the meta-program. These arguments are called _arguments for the metaprogram_ or _compiler command-line arguments_.
Now we will show you how to use them, enhancing our previous program.

See _30.7_build_and_run2.jai_:
```c++
#import "Basic";
#import "Compiler";
#import "Process";

success := false;           // compile is successful
run_on_success := false;    // compiler command line argument --run

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

We define a new global variable `run_on_success` which will become true when we give a metaprogram argument `-- run`.
In line (1) we get these argument(s) from the property `Build_Options.compile_time_command_line`. Starting in line (2), we loop over them and set `run_on_success` when finding `-- run`. In line (3) we now test both success parameters before running the executable.  
To get the same output as in the previous section, you now have to call the compiler with:  
`jai 30.7_build_and_run2.jai -- run`.

## 30.8 Choosing a debug / release build with compiler command-line arguments
In the same way as in the previous section, we can decide to either do a debug build or a release build based on the given command-line argument. This is shown in the following code, which is a further development of the code in § 30.4.8:

See _30.8_debug_release_build.jai_:
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
Calling the program as `jai 30.8_debug_release_build.jai -- debug` supplies the meta-program argument  
`-- debug`, which branches to `case "debug";`, which calls `build_debug(w);` 
It print out `Choosing debug options...` during compilation.
(The same logic goes for `-- release.`)    

Calling `main3` now shows: main3
`This program was built with metaprogram 30.8_debug_release_build.jai`


## 30.9 Enforcing coding standards
Another use-case would be enforcing coding house rules, an example is shown in 30.9_house_rules.jai: 

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

    // This metaprogram should not generate any output executable:
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

## 30.10 Generating LLVM bitcode
See _30.10_generate_llvm_bitcode.jai_:
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

The program above shows how to build an optimized LLVM executable; the instructions for optimization are in lines (1) and (2). You might notice that compiling now takes a bit longer. If you don't use the compiler loop, you can just remove it or comment it out.