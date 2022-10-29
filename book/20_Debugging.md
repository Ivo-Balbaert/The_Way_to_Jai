# Chapter 20 - Debugging

Sometimes it is not immediately obvious what causes your program to behave differently than expected. It (hopefully) is an error in the program's logic, which tends to be easy to detect. But it can also be due to poor memory management, or some unexpected but valid compiler behavior. In the worst case it could be a compiler bug.  
The quest for the bug's cause is even more urgent when a crash of a program occurs. In Jai's case this can be at run-time, but also in compile-time execution? 
In all these cases we need a good debugging tool that allows us to find the cause quickly. Let's see what Jai and its ecosystem have to offer on this front.  

First we focus on a very obvious case,  
see _20.1_crash.jai_:

```c++
// #run main(); // uncomment this for debugging at compile-time

main :: () {
    a := 0;
    b := 1 / a; // (1) Causes a crash
    
    write_string("Done!"); // (2) will never be reached!
}
```
In line (1), we divide by zero, which is always going to crash. The string "Done!" from line (2) will never be printed.
(Try out that b := 1/0 will result in a compiler error: Error: Division by zero.)
Simply running this gives the following output on Windows:
```
The program crashed. Printing the stack trace:
handle_exception                  c:\jai\modules\Runtime_Support_Crash_Handler.jai:211
... (skipping OS-internal procedures)
main                              d:\Jai\The_Way_to_Jai\examples\20\20.1_crash.jai:5   
```

From it we see that Jai has a crash handler module for runtime support, and that the crash occurred in line (5), which our editor tells us is indeed the line `b := 1/a;`

## 20.1 Some general strategies
Jai will nearly always show a message when a program crashes. To rule out the possibility of a crash with no output, there is this nice trick: have  
`defer print ("Program ended gracefully.\n");`  
as the very first line in `main()`. That way, if this output is not shown, you know the program ended with a silent crash.

### 20.1.1 Print debugging
Locate the bug to a certain procedure `proc1` by putting `print("Begin proc1");` and `defer print("End proc1");` statements in each procedure that is suspect. When you have found the faulty procedure, display the value of variables with print statements like `print("var v is %\n", v);`  
Or when it is a pointer use:  `print("pointer ptr points to %\n", <<ptr);`  
The obvious disadvantage is that you have this is a lot of work, and the extra lines litter your code.  
But you can also do this at compile-time! Quickly check the value or type of some variable `var1` in a very hot code path by just letting the compiler print it using 
`#run print("value: %, type: %", var1, type_of(var1));`  
This will not show when you run the program.

### 20.1.2 Assert debugging
A somewhat better solution is to use assert statements to test conditions (see § 6.1.3). When you know a variable var must have the value val, you can put  
`assert(var == val);`  
at appropriate places.
When an assert fails, you know something went wrong in the proc in which it executed.  
A big advantage compared to `print` is that you can leave the `assert` statements in your code by using `ENABLE_ASSERT=false`, as explained in § 6.1.3. That way the asserts will not be executed (so there will be no performance penalty), but you can suickly enable them in production code to hunt for a problem!  
We already showed you the use of assert to catch dereferencing null pointer errors (see § 10.3). Also have a look at the very close relative `#assert` in § 20.2.1

## 20.2 Debugging compile-time execution
In principal (although rarely) a program can crash at compile-time execution. But because we can run any normal program also at compile-time, we can examine the crash at compile-time and see if it is easier to find the bug then.
> A remark here: there are some subtle differences between compile-time and run-time execution of code. So it can occur that a run-time bug does not appear at compile-time, or example: string literals can be changed at compile-time, but not in run-time!

### 20.2.1 #assert debugging
You can also do compile-time asserts with the **#assert** directive.
These take the form:	`#assert condition message`  
This only runs at compile time.

See _20.2_assert.jai_:
```c++
#assert true "This will never be shown\n";
#assert false "I just wanted you to fail\n";

// => at compile-time:
// Error: Compile-time assertion failed. "I just wanted you to fail"

//     #assert true "This will never show\n";
//     #assert false "I just wanted you to fail\n";

// Info: In Workspace 2 ("Target Program"), building target 'assert'.
```

If the condition is false, the compilation stops and shows:
	Error: Compile time assertion failed
	message
This can be used to check that critical conditions are met before compiling and running.

### 20.2.2 The compile-time interactive Jai debugger
How can we debug when running at compile-time? Simply add `#run main();` at the start or end of the source code of program 20.1. When you now compile, you get the following output:
```
>jai 20.1_crash.jai
Error: Jai encountered an exception running the program and is terminating.

Command line arguments:
  jai  20.1_crash.jai

This crash happened during compile-time execution of Workspace #2, so it may be a bug
in the user-level program, not in the compiler.

Here's a stack trace of the user-level program:

                    main (D:/Jai/The_Way_to_Jai/examples/20/20.1_crash.jai:5,10)
            body of #run (D:/Jai/The_Way_to_Jai/examples/20/20.1_crash.jai:1,6)

If you want to interactively debug crashes in compile-time execution, run the compiler with the -debugger command-line option.
```

Again the output shows us that the problem occurred in line 5. The last line also tells us how to start Jai's built-in interactive debugger. Drop into the interactive debugger at the crash site, by starting the compilation with:  

`jai -debugger 20.1_crash.jai`

We now get the same output as before, followed by:
```
    b := 1 / a; // (1) Causes a crash

   3|        binop   v2, v3 / v1
v3 = 1, v1 = 0
>
```

showing the crash line, with the line of Jai byte code which went wrong, together with the values of the variables! This is enough to solve our trivial problem, but there is also an interactive **debugger prompt >**  
Typing **?** at the > prompt shows you the possible commands in this debugger:
```
------------------------- Command Help -------------------------
c, cont, continue: Continue running, without the debugger stopping for each instruction.

n, next: Execute the next instruction.

q, quit: Quit the compiler (closing all workspaces).

r, return, finish: Run until we return from the current procedure.

v(number): Print that value number. Example: v5.

w, where: Show the current call stack.

?, h, help: Print this help text.
----------------------------------------------------------------
>
```

You can see the current call stack with w, show all variable values with vn, and continue execution with n:
```
> v3
v3 = 1
> v1
v1 = 0
> w
                    main (D:/Jai/The_Way_to_Jai/examples/20/20.1_crash.jai:5,10)
            body of #run (D:/Jai/The_Way_to_Jai/examples/20/20.1_crash.jai:1,6)
>
```

With this tool you can debug every Jai program.

## 20.3 Debugging run-time crash with an external debugger
On Windows, we'll want to connect with the external debugger from **Visual Studio**, (VS) which is Windows' flagship IDE (To follow along you'll have to install at least Microsoft Visual Studio Community Edition 2019).   
To do this, we need the _Debug_ module. Program 20.3_crash.jai is the same as 20.1, only the code for using Debug was added:

See _20.3_crash.jai_:
```c++
Debug :: #import "Debug";   // (1)
#import "Basic";

main :: () {
    Debug.init();           // (2)

    a := 0;
    b := 1 / a;         // Causes a crash

    print("Done!");     // will never be reached!
}
```
This includes line (1) for importing the Debug module, and giving it the `Debug` name, so we can must its proc's with this name. In line (2) at the start of the program, this module is initialized.
Now compile the Jai program so that a .exe and a .pdb file (called 20.exe and 20.pdb) are generated:  `jai 20.3_crash.jai`
Then when you run this program, a debugger window will pop up (Choose Just-In-Time debugger on Windows) with the text: "Select a debugger to attach to 20.exe".
Click OK: this will start up the VS 2019 Debugger.  
Then Visual Studio starts loading a lot of symbol files for dll’s, this can take a few minutes (this only occurs the first time). Then you'll see a window:
`Exception thrown: 20.exe has triggered a breakpoint.`
Close this window, a breakpoint is then hit in Runtime_Support.jai, and the Disassembly screen is shown.
Enter F10 (or F11) a number of times, and then the following window is shown:
`Unhandled exception at 0x00007FF654CE074B in 20.exe: 0xC0000094: Integer division by zero.`
In the Disassembly window, the statement `b := 1 / a;` is shown, and in the Locals window on the left you see the values of a and b.
Stop the Debugging session (SHIFT+F5) 
On closing click OK when VS asks you to save the 20.sln solution file.

Now open the sln file again (double-click) with VS. Choose "Start with debugging" (F5) from the menu and VS shows the .jai source file on the line where the crash occurs: `Unhandled exception at 0x00007FF6A973BFBB in 20.exe: 0xC0000094: Integer division by zero`. Stop the debugging session.
Now you can put breakpoints in the .jai file (click in the grey margin beside a code line). Start with Debugging and the VS debugger will stop there. The values of variables are shown in the Debug / Windows / Locals screen. Move forward in the execution with F11 or F10, or with the Debug menu items.

![VS Debugging](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/VSdebug1.png)

## 20.4 Debugging general code
If you have located the neighborhood where the error occurs, it is possible to attach to the debugger somewhere inside the Jai code.

See _20.4_debugging.jai_:
```c++
#import "Basic";
Debug :: #import "Debug";

ac := "Budapest";

main :: () {
    print("ac: %\n", ac);
    ac = "Tokyo";
    print("ac: %\n", ac);
    n := 3;
    m := 7;
    Debug.attach_to_debugger();     // (1)
    Debug.breakpoint();             // (2)
    for 1..4 {
        n += 1;
        m += n * 2;
        if m == 37      Debug.breakpoint();             // (3)
        print("\n% after % times", m, it);
    }
    print("\n\n");
    print("%\n", n);  // => 7
    print("%\n", m);  // => 51
}

/* 
ac: Budapest
ac: Tokyo
15 after 1 times
25 after 2 times
37 after 3 times
51 after 4 times

7
51
*/
```

Insert this code at the line in your program where you want to start the debug session:
```
Debug.attach_to_debugger();
Debug.breakpoint();
```

Now compile and then execute the program. When the breakpoint is reached, a dialog window asks to attach the VS debugger to the running program. Then you enter the session, where you can move with F11 and F10, and so on. Possibly you see assembler, and code from Runtime_support.jai. Eventually, you’ll end up in the Jai program. You can also set new breakpoints in the Jai code.

![VS Debugging general code](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/VSdebug2.png)

**Exercise**
Debug the code of _debugging2.jai_ when inside the nested loop i gets the value 3.


## 20.5 Debugging with natvis
Debugging can be made a bit nicer (especially for compound data structures like arrays, structs, Type_Infos and some Math module types) with a natvis file for Microsoft Visual Studio.

The natvis support files can be found in the distribution in editor_support\msvc\jai.natvis and jai.natstepfilter.
Install them as follows:

1. Copy jai.natvis and jai.natstepfilter to "%USERPROFILE%\Documents\Visual Studio 2022\Visualizers" or "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Packages\Debugger\Visualizers" for Visual Studio 19.
2. When compiling your project, pass -natvis as a parameter to the jai compiler.  For example, "jai first.jai -natvis"

`jai 20.5_array_of_structs.jai -natvis`

Then run the executable with the Debug instructions as specified in the previous §.
(Better example ??)

Instructions for how to install or customize a natvis file are available [here](https://docs.microsoft.com/en-us/visualstudio/debugger/create-custom-views-of-native-objects).

For more info see [this article](https://simoncoenen.com/blog/programming/Natvis).

## 20.7 Some general info
For Linux and macOS a debugger written in Jai called **Smash** is being built: [Smash](https://github.com/rluba/smash).

Jonathan Blow uses Visual Studio for debugging the compiler (C++) (for Jai??), and uses [RemedyBG](https://remedybg.itch.io/remedybg) for debugging the Sokoban game.    
