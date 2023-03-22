# 2B - Compiler command-line options

The structure of a minimal jai command is as follows:  
`jai -option1 -option2 program.jai`  
It can contain 0 or more options.

**Examples:**
`jai program.jai`  : no options, defaults to LLVM backend.  
`jai -x64 -release program.jai`  
It is also allowed to add the options after the source-file name, like this:  
 `jai program.jai -x64`

`jai -help` or `jai -?` shows you all the command-line options that exist:


A complete jai command using all possibilities for giving arguments looks like this:  
`jai <options> program.jai - <user metaprogram args> -- meta <custom metaprogram>` 

`<user metaprogram args>` are also called compiler command-line arguments (see § 30.8).  
Every argument after `-` is ignored by the compiler itself, and is passed to the user-level meta-program for its own use.
Any argument not starting with a -, and before a `- ` by itself, is the name of a file to compile.

**Examples:**  
`jai 30.7_build_and_run2.jai - run`  : see § 30.9  
`jai program.jai -- import_dir "d:/Jai/my_modules" meta Build` : see § 30.5
jai example.jai -plug My_Plugin --- import_dir ../../ : see § 36

The jai-command help text can be found in module  *Default_Metaprogram*. This module also translates the options into build-options (see § 30.4) used by the compiler. 

Here are the possible options:  

**Backends**:  
 `-x64`              Use the x64 backend by default (unless overridden by a meta-program).

 `-llvm`             Use the LLVM backend by default (unless overridden by a meta-program). LLVM is the default backend.

**Command-line args**:  
 `-add arg`          Add the string 'arg' to the target program as code.
                     Example: `-add "MY_VARIABLE :: 42"`;
                     
 `-run arg`          Start a #run directive that parses and runs 'arg' as code.
                     Example: `-run write_string(\"Hello!\n\")` or `-run procedure()`
                   
**Debugging**:  
 `-debugger`         If there is a crash in compile-time execution, drop into the interactive debugger.
 `-debug_for`        Enable debugging of for_expansion macros. (Otherwise the debugger will never step into them to make stepping through for loops more convenient.)

 `-msvc_format`      Use Visual Studio's message format for error messages.

 `-natvis`           Use natvis compatible type names in debug info (array<T> instead of [] T, etc).

 `-verbose`          Output some extra information about what this meta-program is doing.

**Output**:  
 `-output_path`     Set the path where your output files (such as the executable) will go.  
 `-exe name`         Set output_executable_name on the target workspace to 'name'.  
 `-no_color`         Disable ANSI terminal coloring in output messages.    
 `-quiet`            Reduces the (statistics) output from the compiler 

**Modules**:  
 `-import_dir arg`   Add this directory (arg is path/to/dir) to the list of directories searched by #import. Can be used multiple times. (see § 12.12). Also `-- import_dir arg` when importing modules for the Metaprogram (see § 30.5)

**Performance**:  
 `-release`          Build a release build, i.e., tell the default meta-program to disable stack traces and enable optimizations. This compiles the program with LLVM backend -O2 optimization

 `-no_dce`     Turn off dead code elimination. This is a temporary option, provided because dead code elimination is a new and potentially unstable feature. This will eventually be removed; the preferred way to turn off dead code elimination is via Build_Options.

 `-no_check`         Do not import modules/Check and run it on the code. The result will be that you won't get augmented error checking for stuff like `print()` calls. Use this if you want to substitute your own error checking plugin, or for higher speeds in builds known to be good.

 `-no_check_bindings`  	Disable checking of module bindings when running modules/Check. If modules/Check is not run due to -no_check, this does nothing.

 `-no_backtrace_on_crash`    Do not catch OS-level exceptions and print a stack trace when your program crashes. Causes less code to be imported on startup. Depending on your OS (for example, on Windows), crashes may look like silent exits.

**MetaProgram**  
`-- meta MetaProgram`  To replace the default meta-program by MetaProgram.
The -- command line arguments are not for the compiler itself; 
they are passed from the default meta-program to your compile-time execution environment. 

**Miscellaneous**:  
 `-no_cwd`  Turn off the compiler's initial change of working directory. This is a temporary option, provided because the policy around working directories is new and is still being worked out.

 `-plug name`  or `-plugin name`  Import module 'name' into the meta-program and use it as a plugin.  

 `-version`      Print the version of the compiler.

 `-report_poly`  Print the Polymorph Report when compilation is done.  

Other _compiler-front-end options_:
To see these, type:  `jai -- help`

which outputs the following additional options:  
Developer options: `-no_jobs, -randomize, -seed some_number, -extra, -chaos`

These options are deliberately minimal compared to other programming languages. As we'll see later Jai provides a very sophisticated system to build your application and setting these options from Jai code itself (see § 30). It favors _configuration from code_ which is the same and all platforms and lets you use the Jai programming language you know. This is in sharp contrast to many other programming language environments, where you have separate complicated build systems often using a separate language, that also often changes depending on which platform you are on.

> Note: This is different from getting command-line arguments to a program itself (see § 19B).