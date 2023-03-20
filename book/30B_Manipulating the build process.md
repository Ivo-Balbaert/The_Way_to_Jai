# 30B Manipulating the build process

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
    message_loop();  
    compiler_end_intercept(w);       // (1B)
}

message_loop :: () {
    while true {                     // (2)          
        message := compiler_wait_for_message();  // (3)
//        print(" >> %\n", <<message); // (4) => see output below
        if !message break; 
        if message.kind == {
            case .COMPLETE;          // (5)
                print(" >> %\n", <<message);
                break;
            case .FILE; {            
                message_file := cast(*Message_File) message;    // (6)
//                print("Loading file '%'.\n", message_file.fully_pathed_filename); // (7)
            }
            case .IMPORT; {            
                message_import := cast(*Message_Import) message;          // (8)
//               print("Imported '%', module_type %, with path '%'.\n", m.module_name, m.module_type, 
// m.fully_pathed_filename); // (9)
            }
            case .PHASE; {            
                message_phase := cast(*Message_Phase) message;     // (10)
//              print("Entering phase %\n", message_phase.phase);  // (11)
                if message_phase.phase == .TYPECHECKED_ALL_WE_CAN  {  // (11B)
//                    print("Typechecking done - stop compilation");
//                    exit(0);
                }
                if message_phase.phase == .POST_WRITE_EXECUTABLE {
                    print("\n");
                    if message_phase.executable_write_failed {
                        print("FAILED writing '%'! Linker exit code was %.\n",  
                        message_phase.executable_name, message_phase.linker_exit_code);
                    } else {
                        print("Success writing '%'! Linker exit code was %.\n",  
                        message_phase.executable_name, message_phase.linker_exit_code);
                    }
                }
            }
            case .TYPECHECKED; {            
                 message_typechecked := cast(*Message_Typechecked) message; // (12)
                 for message_typechecked.declarations {  // (13)
//                    print("Code declaration: %\n", it);
                }
                n := message_typechecked.all.count;
                if n == 1 {
                    print("  1 thing has been typechecked.\n");
                } else {
                    print("  % things have been typechecked.\n", n);
                }
            }
            case .DEBUG_DUMP; {            
                dump_message := cast(*Message_Debug_Dump) message;   // (14)
                print("Here is the dump text: %\n", dump_message.dump_text); // (15)
            }
            case .ERROR; {            
                // handle error
            }
            case;
                compiler_report(tprint("Unhandled message type %!\n", message.kind));
        }
    }
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

You do that by getting a hook into the compiler loop with `compiler_begin_intercept(w);` (line (1)); it causes us to get compiler messages from this workspace.
The hook is removed after the compiler access with `compiler_end_intercept(w);` (line (1B)).

We process all compiler messages in the `message_loop();` procedure. This is a while true loop. In line (3), we do: `message := compiler_wait_for_message();` and print out the message. Because this is an infinite loop, we need to stop when the compiler signals the end of its work with the COMPLETE message; this is done in line (5).

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

2) `.IMPORT` is signalled whenever a new module is loaded. Every module is imported only once; even when you have for example several `#import "Basic"`, importing of _Basic_ happens only one time. You can see which modules are imported: see lines (8)-(9).  

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

If you want Jai to do just the typechecking and not to compile anything, the meta-program (build.jai) should exit after compiler message `TYPECHECKED_ALL_WE_CAN` (see lines 11B and following). On the other hand, if you want to generate code, you can do this after this message (see 30.11_using_notes.jai and how_to 460).

If you want to output info gathered during compilation, use the phase `PRE_WRITE_EXECUTABLE, which occurs after we have received all the typecheck data, but before COMPLETE (otherwise it would overlap with any diagnostic output printed by the compiler itself, see how_to 490).

4) `.TYPECHECKED` every time code has passed typechecking, this gives a huge amount of output : see lines (12)-(13).  

```
Code declaration: {adb_1168, [adb_11f0, adb_1168]}
Code declaration: {adb_22f0, [adb_2378, adb_22f0]}
Code declaration: {adb_23d8, [adb_2460, adb_23d8]}
Code declaration: {adb_24a8, [adb_2530, adb_24a8]}
...
```

In this phase code can be inspected, searched for things, and modified. You can loop over the type-checked structs with  
`for message_typechecked.structs`  
This is used in how_to 460 to search all subclasses of "Entity" (see § 16.2). 

5) `.DEBUG_DUMP` when a crash occurs during compilation, the dump info can be viewed like in lines (14)-(15).

6) `.ERROR`: when an error occurs in the compilation process itself, you can handle it here.  
   
7) `.COMPLETE`: triggers when compilation is finished. Here you will `break` out of the `while true` compiler message loop.

All these enum options contain a lot more useful info (see module _Compile_).
You can also run any other program after successful completion.

Another use-case would be to run the program after successful completion of the compilation, or any other program for that matter.  

## 30.7 Building and running on successful compilation
What if we want to build our project, and run it on successful completion?

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
This program was built with meta-program 30.8_build_and_run.jai
...
*/
```

This is easily done: when the .COMPLETE message is received, we check that the error_code of the message is 0. If so, we set a global variable `success` to true (see lines (2) and (3)). Then at the end of our build program, we print a "SUCCES" message, and run our compiled program with the `run_command` procedure from module _Process_.  
In the output we see:
```
...
>> {COMPLETE, 3}
[SUCCESS!]
This program was built with meta-program 30.8_build_and_run.jai
...
```

## 30.8 Getting the file to compile from the command-line and inlining
(Example from Jai Community Wiki)

Sometimes it is easier to specify the file to compile at the command-line, instead of hardcoded within the build program. The following example shows how to do this:

See *30.14_build_inlining.jai*:
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
    
    options := get_build_options(w);

    args := options.compile_time_command_line;     // (1)
    print("\nargs: %\n", args);
    filename := args[2];

    options.output_executable_name = filename;
    options.enable_bytecode_inliner = true;        // (2)
    
    set_build_options(options, w);

    compiler_begin_intercept(w);
    add_build_file(sprint("%.jai", filename), w);  // (3)
    message_loop();
    compiler_end_intercept(w);

    set_build_options_dc(.{do_output=false});
}

message_loop :: () {
    while true {
        message := compiler_wait_for_message();

        if message.kind == {
            case .COMPLETE;
                break;
        }
    }
}
```

Inlining is activated in line (2).

In line (1) we read in the compile-time command-line arguments in an []string args. In our case this will be like: `jai 30.14_build_inlining.jai - main8`. 
args is printed as:  `args: ["30.14_build_inlining.jai", "-", "main8"]`
args[0] is the program name (30.14_...jai), args[1] the separator '-' and main8 will be args[2], stored in the variable `filename`. This file is then added to be compiled in line (3) with `add_build_file`.

> The space between - and run is needed! Otherwise you get an error like:
> Command line: Missing argument to -run.

Here is the contents of main8.jai:
```c++
#import "Basic";

main :: () {
  print("This program was built with a meta-program 30.14_build_inlining.jai\n");
}
```

When we run `main8`, we get the output: `This program was built with meta-program 30.14_build_inlining.jai`.

## 30.9 Building and running with a compiler command-line argument 
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

We define a new global variable `run_on_success` which will become true when we give a meta-program argument `- run`.
In line (1) we get these argument(s) from the property `Build_Options.compile_time_command_line`.  

Starting in line (2), we loop over them and set `run_on_success` when finding `- run`. In line (3) we now test both success parameters before running the executable.  

To get the same output as in the previous section, you now have to call the compiler with:  `jai 30.7_build_and_run2.jai - run` 

## 30.10 Choosing a debug / release build with a compiler command-line argument
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
`This program was built with meta-program 30.8_debug_release_build.jai`

`build_debug` shows the recommended debug options:  
* backend = .X64  
* optimization_level = .DEBUG
* array_bounds_check = .ON

The X64 backend is faster than the LLVM backend, but for most programs the difference is negligible.

This build compiles faster with as much debugging information as possible, but has some overhead in order to help debug. An executable built in debug mode will, for example, tell the programmer on which line of code the program crashed on, and check for array out of bounds errors. As expected from debug builds, the code is not as optimized as a release build.

`build_release` shows the recommended release options:  
* backend = .LLVM 
* optimization_level = .RELEASE
* set_optimization_level(target_options, 2, 0); // same as clang -O2  
(for a complete overview of release options, check Appendix D: Performance.)

The LLVM compiler backend is slower than the X64 backend, because it does a lot more optimizations. An optimized build does not have debug information built into it, and takes longer to compile. This build makes the compiler produce the best possible optimized code. 

## 30.11 Enforcing coding standards
Another use-case would be enforcing coding house rules, an example is shown in 30.9_house_rules.jai , which shows how to enforce compile-time code checking, for example the MISRA standards (in this case: Check for Multiple Levels of Pointer Indirection, so that you cannot do you cannot do `a: ***int = b;` for example).  

MISRA coding standards are a set of C and C++ coding standards, developed by the Motor Industry Software Reliability Association (MISRA). These are standards specific to the automotive industry,.

See *30.9_house_rules.jai*:
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

During the compiler message loop in line (1), we inject a proc `misra_checks()`, which tests every message on a specific code rule, here the `check_pointer_level_misra_17_5` rule which forbids more than 2 levels of pointer indirection. Line (2) ensures that this meta-program does not generate any output executable.

Run the check with: `jai 30.9_house_rules.jai`. If the program obeys the rule(s), nothing is shown, but if you substitute main5.jai (which has too many levels of indirection) for main.jai, you get the output:
```
In Workspace 2 ("Target Program"):
D:/Jai/The_Way_to_Jai/examples/30/main5.jai:4,3: Error: Too many levels of pointer indirection.


    a: *int;
    b := *a;
    c := *b; // Too many levels of pointer indirection! c is of Type (***int)
```

(See other MISRA checks implemented in how_to/480.)
How_to/490 shows how to get info on loaded files and imported modules at compile-time.

## 30.12 Generating optimized LLVM bitcode
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

## 30.13 Using notes to do special meta-programming
Notes on a struct or function were described in § 15.7, and code was shown to display them in § 15.5. The note tags will also show up in a meta-program, and you can use them to do special meta-programming such as custom program typechecking and modifying the executable based on the meta-program.

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

The program contains no `main` proc; this will be created by the meta-program!

The meta-program finds all the procs tagged @note and adds them to an array of strings called `procs` declared in line (1). It then sorts procs alphabetically, and generates a main proc that calls all procs tagged @fruit in alphabetical order.

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
The code starting in line (3) shows how to generate new code (in this case a `main` proc) after the TYPECHECKED_ALL_WE_CAN phase. `generate_code()` (called in line (4) and defined in line (6)) is a macro that produces a string which contains the code for a `main` proc, printing out the names of all procs with the note @fruit alphabetically.

The sorting is done by first calling `bubblesort` from module _Sort_, which also calls a `compare` proc from module _String_.
A bool flag variable gen_code is used so that this generation is done only once.  
Let's see the results. First run the meta-program:  
`jai 30.11_using_notes.jai`  
Then run the generated executable `notes.exe`:   
which produces as output:  
```
apple
banana
cherry
dog
elephant
```
(See also how_to/470, first.jai for code to check if a procedure has a certain note and the [Jai Cookbook](https://github.com/onelivesleft/jai-cookbook) modules and tools folder.)

## 30.14 Writing and loading dynamic libraries and #program_export
(Example from Jai Community Wiki; see also examples/dll)

The following code builds a dynamic library *dynlib.dll* on Windows and *dynlib.so* on Linux. 

See *30.13_dynamic_libraries.jai*:
```c++
#import "Basic";
#import "Compiler";

build :: ()
{
    // Build the dll
    {
        w := compiler_create_workspace();
        options := get_build_options(w);
        options.output_type = .DYNAMIC_LIBRARY;   // (1)
        options.output_executable_name = "dynlib";
        set_build_options(options, w);

        compiler_begin_intercept(w);
        add_build_file("dynlib.jai", w);
        while true {                // is needed!
            message := compiler_wait_for_message();
            if !message break;
            if message.kind == .COMPLETE {
                mc := cast(*Message_Complete) message;
                if mc.error_code != .NONE {
                    print("DLL compilation failed; exiting without compiling the main program.\n");
                    return;
                }
                break;
            }
        }
        compiler_end_intercept(w);
    }

    // Build the exe after 
    {
        w := compiler_create_workspace();
        options := get_build_options(w);
        options.output_executable_name = "main7";
        set_build_options(options, w);
        add_build_file("main7.jai", w);
    }

    set_build_options_dc(.{do_output=false});
}

#run build();
```

Line (1) is needed for building a dynamic library, which uses the following code: 

See *dynlib.jai*:
```c++
#program_export 
dll_func :: () #no_context {
    write_string("Hello Sailor!\n");
}
```

Notice the **#program_export** directive to indicate that a function is exported to a dynamic library.
Adding #c_call and push a fresh context here are needed also if you plan on calling this from another language than Jai.

After the dynamic library `dynlib`and in a separate workspace `main7`, 30.13_dynamic_libraries.jai builds an executable *main7* from the following code:

See *main7.jai*:
```c++
dynlib :: #library,no_static_library "dynlib";
dll_func :: () #no_context #elsewhere dynlib;

main :: () {
    dll_func();
}
```

The executable calls the proc `dll_func` from the dynamic library.
Build both with:   
` jai 30.13_dynamic_libraries.jai`
and see the result of:  `main7`  
which outputs:  `Hello Sailor!`

## 30.15 Adding binary data to the executable
The compiler bakes type info data into the executable (see § 16.4.3). But you can also add your own data to it with the proc `add_global_data`.  
The following code does just that.

See *30.15_global_data.jai*:
```c++
#import "Basic";
#import "Compiler";
#import "File";
#import "String";

main :: () {
    data1 :: #run add_global_data(                  // (1)
        xx join(
            "GIF89a\x01\x00\x01\x00\x80\x01\x00\xff\xff\xff\x00",
            "\x00\x00!\xf9\x04\x01\n\x00\x01\x00,\x00\x00\x00",
            "\x00\x01\x00\x01\x00\x00\x02\x02L\x01\x00;",
        ),
        .READ_ONLY,
    );
    print("%\n", data1.count); // => 43
    
    data2 :: #run add_global_data(xx read_entire_file("pixel.png"), .READ_ONLY); // (2)
    print("%\n", data2.count); // => 43
}
```

In line (1) we join a number (43 to be exact, see the print of count) of hexadecimal byte strings (see § 19.3) and autocast this to an []u8. This is then added at compile-time through #run to the global data.

As a result, this data will be baked in into the final executable.    
The same bytes are also stored in the file `pixel.png`. In line (2) we read in this file, autocast it, and also add it to global data to be baked into the executable.  

.READ_ONLY is the 2nd argument which is a Data_Segment_Index.
This baking can also be done in different data segments if needed.

Why bake data into your main program? Well, maybe you want to distribute a standalone exe that doesn't require any data files and doesn't care where it is located in the filesystem.
Maybe you want fast access to some of your data at startup, and can load the rest later.

## 30.16 Simple example using the Bindings_Generator module
This module contains a simple example in */jai/modules/Bindings_Generator/examples*.  
Our input is a C++ program called `cpp_library.cpp` and its header file `cpp_library.h`. 

The bindings are generated by compiling the build file *first.jai*:  `jai modules/Bindings_Generator/examples/first.jai`. 
This imports the modules *Bindings_Generator* and *BuildCpp*, which is a helper module to build a C++ project using Jai.
*first.jai* starts using that module and runs the proc `build_cpp_dynamic_lib`, which creates library `cpp_library.lib` and object `cpp_library.exp`, and the dynamic `library cpp_library.dll`.  
Then the proc `generate_bindings` is executed, generating an appropriate output file for the OS you're working on (for example: *windows.jai* on Windows), which displays:
```
generating 31 global scope members...
    25 functions
    4 structs
    0 enums

OK! generated 'windows.jai'
```

`windows.jai` contains only the Jai versions of C++ struct definitions and function signatures.  
For example: `cpp_library.cpp` contains the following definition of a `VirtualCppSub::normal_method()` function, containing a printf statement.
```c++
void VirtualCppSub::normal_method() {
    printf("VirtualCppSub::normal_method\n");
}
``` 
The header file `cpp_library.h` contains this signature:
```c++  
struct VirtualCppSub : public VirtualCppBase {
    DLL_API VirtualCppSub();

    DLL_API void normal_method();
    DLL_API virtual void virtual_method();
    DLL_API ~VirtualCppSub();
    DLL_API virtual void virtual_method2();
};
```

This gets translated to the following definition in `windows.jai` (Line 5 starting with `normal_method`):
```c++  
VirtualCppSub :: struct {
    #as using virtualcppbase: VirtualCppBase;
    Constructor :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "??0VirtualCppSub@@QEAA@XZ";

    normal_method :: (this: *VirtualCppSub) -> void #cpp_method  #foreign cpp_library "?normal_method@VirtualCppSub@@QEAAXXZ";

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.
    virtual_virtual_method :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "?virtual_method@VirtualCppSub@@UEAAXXZ";
    virtual_Destructor :: (this: *VirtualCppSub, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign cpp_library "??1VirtualCppSub@@UEAA@XZ";
    virtual_virtual_method2 :: (this: *VirtualCppSub) -> void #cpp_method #foreign cpp_library "?virtual_method2@VirtualCppSub@@UEAAXXZ";
}
#run {
    assert(size_of(VirtualCppSub) == 8, "VirtualCppSub has size % instead of 8", size_of(VirtualCppSub));
}
```
Note that the generated binding in Jai does NOT contain the printf statement. A bindings generation is not the same as a conversion from C++ to Jai. Rather, through the binding, Jai can **call** the compiled C++ code of that function in `cpp_library.dll`, using the FFI interface through the `#foreign` directive (see § 29.2).

`windows.jai` is an auto-generated file, so any changes you make to it are overwritten when `first.jai` is compiled the next time! If you really need to make some changes, don't forget to take a backup copy.

Here is the code of *first.jai*:  
```c++
#run build();

build :: () {
    set_build_options_dc(.{do_output=false});

	options := get_build_options();
    do_debug := (options.optimization_level == .DEBUG);
    success := build_cpp_dynamic_lib("cpp_library", "cpp_library.cpp", debug=do_debug);
    if !success {
        compiler_set_workspace_status(.FAILED);
        return;
    }

    if !generate_bindings() {
        compiler_set_workspace_status(.FAILED);
        return;
    }

    w := compiler_create_workspace("Main program");
    
    options.output_type     = .EXECUTABLE;
    options.output_executable_name = "example";
    set_build_options(options, w);
    
    compiler_begin_intercept(w);
    add_build_file("main.jai", w);

    while true {
        message := compiler_wait_for_message();
        if message.kind == {
          case .TYPECHECKED;
            do_error_checking(null, message);
            
          case .COMPLETE;
            break;
        }
    }

    compiler_end_intercept(w);
}

generate_bindings :: () -> bool {
    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;

        #if OS == .WINDOWS {
            output_filename          = "windows.jai";
            strip_flags = 0;
        } else #if OS == .LINUX {
            output_filename          = "linux.jai";
            strip_flags = .INLINED_FUNCTIONS; // Inlined constructor doesn't exist in the library
        } else #if OS == .MACOS {
            // @ToDo: Determine dynamically? Customize?
            array_add(*system_include_paths, "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include");
            output_filename          = "macos.jai";
            strip_flags = .INLINED_FUNCTIONS; // Inlined constructor doesn't exist in the library
        } else {
            assert(false);
        }

        array_add(*libpaths,       ".");
        array_add(*libnames,      "cpp_library");
        array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);
        array_add(*source_files,  "cpp_library.h");
        array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");

        // strip_flags &= ~(Strip_Flags.CONSTRUCTORS | .DESTRUCTORS);
    }

    return generate_bindings(opts, output_filename);
}

#scope_file

#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Check";
#import "Bindings_Generator";
#import "File";
```

Finally a *main.jai* file is compiled to an executable *example*. It calls some of the C++ functions in cpp_library.cpp and prints that out, proving that we use the original C++ library from Jai.    
Here is its source:

```c++
main :: () {
    #if OS == .WINDOWS {
        log("CppBase:");
        base: CppBase = ---;
        CppBase.Constructor(*base);
        defer CppBase.Destructor(*base);

        CppBase_virtual_method(*base);
    }
    {
        log("CppSub:");
        sub: CppSub = ---;
        CppSub.Constructor(*sub);
        defer CppSub.Destructor(*sub);

        CppBase_virtual_method(*sub);
    }
    {
        log("VirtualCppBase:");
        base: VirtualCppBase = ---;
        VirtualCppBase.Constructor(*base);
        defer VirtualCppBase_Destructor(*base);

        VirtualCppBase_virtual_method(*base);
        VirtualCppBase_virtual_method2(*base);
    }
    {
        log("VirtualCppSub:");
        sub: VirtualCppSub = ---;
        VirtualCppSub.Constructor(*sub);
        defer VirtualCppBase_Destructor(*sub);

        VirtualCppBase_virtual_method(*sub);
        VirtualCppBase_virtual_method2(*sub);
    }
}

#if OS == .WINDOWS {
    #load "windows.jai";
    #import "Windows";
} else #if OS == .LINUX {
    #load "linux.jai";
} else #if OS == .MACOS {
    #load "macos.jai";
} else {
    #assert(false);
}

#import "Basic";
```

Running this executable prints:
```
CppBase:
CppBase
CppBase::virtual_method
CppSub:
CppBase
CppSub
CppSub::virtual_method
~CppSub
~CppBase
VirtualCppBase:
VirtualCppBase
VirtualCppBase::virtual_method
VirtualCppBase::virtual_method2
~VirtualCppBase
VirtualCppSub:
VirtualCppBase
VirtualCppSub
VirtualCppSub::virtual_method
VirtualCppSub::virtual_method2
~VirtualCppSub
~VirtualCppBase
~CppBase
```

All files of this cpp_library example are contained in the subfolder *cpp_library* (the exe and the pdb file are zipped for security reasons).

When generating FFI bindings for more complex C++ libraries (like ImGui), the build file is often called *generate.jai*, so the bindings generation is done with the command: `jai generate.jai`.

Here is an example of a build file from a more complex project: `https://github.com/shiMusa/Jai-Plot/blob/main/first.jai`

## 30.17 Generating bindings for the Raylib C library
Here is another example where bindings are generated for the C++ raylib library:  
`https://git.koikoder.com/shared/jai_raylib_module`

We'll go through it step by step.

*Step 1* Create a folder *jai_raylib* to contain the whole project.

*Step 2 - Download and extract the C library*  
Download the [Raylib C library](https://github.com/raysan5/raylib/releases) appropriate for your machine.
Extract it to a subfolder *vendor* in the folder created in Step 1.  
(This includes only the header files in /include and the compiles C files in /lib, namely raylib.dll and the .lib files.)

*Step 3 - Create the build-and-generate bindings file*  
This file is called *build.jai* in folder *jai_raylib*.

See *The_Way_to_Jai\examples\30\jai_raylib\build.jai*:
```c++
#import "Basic";
#import "Compiler";
#import "File_Utilities";
#import "File";
#import "Bindings_Generator";

PROJECT_NAME :: "raylib_module_example";


// build entry point:
#run {
	set_build_options_dc(.{do_output=false, write_added_strings=false});

	// (1) - Generate `Raylib` module if it does not exist:
	if !file_exists("local_modules/raylib_win64") {
		generate_raylib_module("raylib_win64", "vendor/raylib_4.2.0_win64_msvc16");
	}

	workspace := compiler_create_workspace(PROJECT_NAME);
	if !workspace {
		print("[build] workspace creation for: % failed!\n", PROJECT_NAME);
		return;
	}

	// Debug configuration:
	options := get_build_options(workspace);
	options.output_executable_name = PROJECT_NAME;
	options.backend = .X64;
	options.intermediate_path = ".build/";
	options.output_path = ".build/";
	options.output_type = .EXECUTABLE;
	options.write_added_strings = false;

	// (6) Add `local_modules` to import path:
	new_import_path: [..]string;
	array_add(*new_import_path, ..options.import_path);
	array_add(*new_import_path, "local_modules");
	options.import_path = new_import_path;

	set_build_options(options, workspace);

	// Add entry point:
	add_build_file("src/main.jai", workspace);
}


// Use to generate module from the given `Raylib` release:
generate_raylib_module :: (module_name: string, raylib_path: string) {
	using options: Generate_Bindings_Options;
	strip_flags = 0;

	// Add definitions for things that are missing:
	header = #string MODULE_HEADER
	// from: <stdarg.h> used by TraceLogCallback
	va_list :: *void;
	MODULE_HEADER

	// (2) Add Raylib files to the generator:
	raylib_library_directory := tprint("%/lib", raylib_path);
	raylib_include_directory := tprint("%/include", raylib_path);

	array_add(*libpaths, raylib_library_directory);
	array_add(*libnames, "raylib");
	array_add(*include_paths, raylib_include_directory);
	array_add(*source_files, ..string.["raylib.h", "raymath.h", "rlgl.h"]);
	array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);

	// (3) Generate module directory:
	raylib_module_directory := tprint("local_modules/%", module_name);
	raylib_module_lib_directory := tprint("%/%/lib", raylib_module_directory, raylib_path);
	raylib_module_file := tprint("%/module.jai", raylib_module_directory);

	make_directory_if_it_does_not_exist(raylib_module_directory, true);

	// (4) Generate bindings and save them as module.jai:
	generate_bindings(options, raylib_module_file);

	// (5) Copy library files to module directory:
	make_directory_if_it_does_not_exist(raylib_module_lib_directory, true);

	for string.["raylib.lib", "raylib.dll", "raylibdll.lib"] {
		file_src := tprint("%/%", raylib_library_directory, it);
		file_dest := tprint("%/%", raylib_module_lib_directory, it);
		copy_file(file_src, file_dest);
	}
}
```

In line (1) we see that it will generate the Raylib module (raylib_win64 in our case) in another subfolder *local_modules*.  
The `generate_raylib_module` first points the build process to the Raylib lib and include folders (see line (2)). It also creates the folder where the bindings file will be created: *local_modules/raylib_win64* (see line (3), the bindings file will be called *module.jai*)
In line (4) the bindings are generated and saved as *module.jai*. Lines (5) and following copies the C library files to the module directory *local_modules*.  
Then we create a workspace for a (here debug) build. In (6) we add the *local_modules* folder to the modules *import_path*.  
Finally we add a file *main.jai* (in subfolder *src*) to compile, which will test our newly created bindings.  
Here is the source of *main.jai*:  
```c++
#import "Basic";
rl :: #import "raylib_win64";

main :: () {
	rl.InitWindow(800, 600, "Raylib Module");

	while !rl.WindowShouldClose() {
		rl.BeginDrawing();
		rl.ClearBackground(.{50, 100, 150, 255});
		rl.EndDrawing();
	}
}
```

This imports our C library and bindings, and calls some Raylib functions to create a window.

*Step 4 -  Compile the build file*  
This is done with the command: `jai build.jai`, which gives as output:  
```
generating 990 global scope members...
    755 functions
    39 structs
    31 enums

OK! generated 'local_modules/raylib_win64/module.jai'
```
This also creates the executable *raylib_module_example* from main.jai inside the *.build* folder (contained in the zip file).

*Step 5 -  Test the bindings*  
 When we run *raylib_module_example*, we see that a window is created using Raylib: 

To re-generate the bindings on build (for example for another Raylib version), first delete the Raylib module. 



Some other useful code examples of meta-programming during a build can be found in the [Jai Cookbook](https://github.com/onelivesleft/jai-cookbook).
