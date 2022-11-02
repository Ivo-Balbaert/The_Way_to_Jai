# 2B - Compiler command-line options

The structure of a typical jai command is as follows:  
`jai -option1 -option2 file_to_compile.jai -- arguments for metaprogram`

Every argument after -- is ignored by the compiler itself, and is passed to the metaprogram for its own use. Any argument not starting with a -, and before --, is the name of a file to compile.

Example:     `jai -x64 program.jai -- info for the compile_time execution` 

`jai -help` shows you all the command-line flags that exist:

**Backends**:  
 `-x64`              Use the x64 backend by default (unless overridden by a metaprogram).

 `-llvm`             Use the LLVM backend by default (unless overridden by a metaprogram).
                     LLVM is the default backend.

**Command-line args**:  
 `-add arg`          Add the string 'arg' to the target program as code.
                     Example: `-add "MY_VARIABLE :: 42"`;
                     
 `-run arg`          Start a #run directive that parses and runs 'arg' as code.
                     Example: `-run write_string(\"Hello!\n\")` or `-run procedure()`
                   
**Debugging**:  
 `-debugger`         If there is a crash in compile-time execution, drop into the interactive debugger.

 `-msvc_format`      Use Visual Studio's message format for error messages.

 `-natvis`           Use natvis compatible type names in debug info (array<T> instead of [] T, etc).

 `-verbose`          Output some extra information about what this metaprogram is doing.

**Output**:  
 `-exe name`         Set output_executable_name on the target workspace to 'name'.  
 `-no_color`         Disable ANSI terminal coloring in output messages.    
 `-quiet`            Reduces the (statistics) output from the compiler 

**Modules**:  
 `-import_dir arg`   Add this directory (arg is path/to/dir) to the list of directories searched by #import. Can be used multiple times.

**Performance**:  
 `-release`          Build a release build, i.e., tell the default metaprogram to disable stack traces and enable optimizations. This compiles the program with LLVM backend -O2 optimization

 `-no_dce`     Turn off dead code elimination. This is a temporary option, provided because dead code elimination is a new and potentially unstable feature. This will eventually be removed; the preferred way to turn off dead code elimination is via Build_Options.

 `-no_check`         Do not import modules/Check and run it on the code. The result will be that you won't get augmented error checking for stuff like `print()` calls. Use this if you want to substitute your own error checking plugin, or for higher speeds in builds known to be good.

 `-no_check_bindings`  	Disable checking of module bindings when running modules/Check. If modules/Check is not run due to -no_check, this does nothing.

**Miscellaneous**:  
 `-no_cwd`           Turn off the compiler's initial change of working directory. This is a temporary option, provided because the policy around working directories is new and is still being worked out.

 `-plug name`        Import module 'name' into the metaprogram and use it as a plugin.  
 `-version`          Print the version of the compiler.  

There are also a few very _tweaky compiler-front-end options_ that are rarely used. To see these, do:  
           ` jai --- help`

which outputs:
_Developer options: import_dir name, meta metaprogram_name, no_jobs, randomize, seed some_number, extra, chaos._

These options are deliberately minimal compared to other programming languages. As we'll see later Jai provides a very sophisticated system to build your application and setting these options from Jai code itself (see ??). It favors _configuration from code_ which is the same and all platforms and lets you use the Jai programming language you know. This is in sharp contrast to many other programming language environments, where you have separate complicated build systems often using a separate language, that also often changes depending on which platform you are on.