# 26 - Meta-programming and macros

A 'meta-program' is a piece of code that alters (or 'programs') an existing program (another piece of code).
In Jai, this takes place solely at compile-time. The compiler gives you the source code in AST format (Abstract Syntax Tree) for you to modify.

> Jai offers arbitrary compile-time execution, with powerful meta-programming features to modify your code in whatever way you want, but all meta-programming is limited strictly to compile-time execution. This capability is one of the main pillars of the language.

This functionality has been built into the language from the start. Meta-programs can modify the program in arbitrarily complex ways easily. 

In order to do meta-programming, full type-information is needed. Jai has that available at compile-time (see§ 5.1.4, § 9, § 16),  but also retains static type information for every structure available at runtime (see § 26.1).
In § 13.6 and § 15.4 we discussed some useful reflection methods for enums. In § 15.5 we highlighted useful reflection methods for structs, useful for serialization (see § 15.6).

Using type info to meta-program is also called _reflection_ or _introspection_ in other languages.

We already talked about running code at compile time as early as § 3.2.4. Jai provides full compile-time code execution, meaning that all Jai code can also be executed while compiling.

> Remark: because all of this processing happens at compile-time, there is a natural overlap between this chapter and § 27.

## 26.1 The type table
See _26.1_type_table.jai_:
```c++
#import "Basic";
#import "Compiler";

main :: () {
    x1 := 3.14;

    table := get_type_table();         // (1) 

    print("The type table has % entries: \n", table.count); 
    // => The type table has 355 entries:
    for table {
        print("%: ", it_index);
        print("  type: %\n", it.type); 
    }
}

/*
The type table has 355 entries: 
0:   type: INTEGER
1:   type: INTEGER
2:   type: VARIANT
3:   type: INTEGER
...
350:   type: STRUCT
351:   type: PROCEDURE
352:   type: PROCEDURE
353:   type: POINTER
354:   type: ARRAY
*/
```

Full introspection data is available for all structs, functions, and enums at runtime. A structure called **_type_table** contains all variables with their types; this is populated at compile-time. Then this data structure is stored in the data segment of the executable file, making it available at runtime.
This structure is not directly accessible, you have to use the proc `get_type_table` from module _Compiler_,  as we did in line (1).  
`table` has as type [] *Type_Info.  

(See also build option: `runtime_storageless_type_info`  in § 27.?? )

## 26.2 Running code at compile time with #run
We first discovered that this was possible in §3.2.4. We talked about the bytecode interpreter in § 4.2, saw how constants can be calculated at compile time in §5.2.2, and how this can be used for debugging purposes in § 20.  
We already know that we need to use `#run main()` to run the whole program at compile-time.
In fact, any code (a code-line, a block of code or a procedure) can be run at compile time with ****#run**. 

See _26.2_run.jai_:
```c++
#import "Basic";

proc1 :: () { print("This is proc1 :: ()\n"); }
proc2 :: () -> int { 
    print("This is proc2 :: ()\n");
    return 42;
}

#run proc1();             // (1) => This is proc1 :: ()
result := #run proc2();   // (2) => This is proc2 :: ()
PI :: #run compute_pi();  // (3)

compute_pi :: () -> float {
  // calculate pi using the Leibniz formula.
  n := 1.0;
  s := 1.0;
  pi := 0.0;

  for 0..10000 {
    pi +=  1.0 / (s*n);
    n += 2.0;
    s = -s;
  }
  return pi*4.0;
}

main :: () {
    proc1();        // => This is proc1 :: () - proc1 is called at run-time

    print("result is %\n", result); // => result is 42   
    print("PI is %\n", PI); // => PI is 3.141699

    f1 :: ()  => 1000;
    f2 :: (c) => c + 1;

    a :: #run f1();     // (4)
    b :: #run f2(a);    // (5)
    print("a=%, b=%\n", a, b); // => a=1000, b=1001

    #run {              // (6)
        print("I am running this block only at compile-time!");
        n := 108;
    }
}

/* Output when compiling:
This is proc1 :: ()
This is proc2 :: ()
I am running this block only at compile-time!
*/

/* Output when running:
This is proc1 :: ()
result is 42
PI is 3.141699
a=1000, b=1001
*/
```

In line (1) we see how to run a procedure: `#run proc1();`
Line (2) runs a proc and assigns its return value to a variable `result`, so that when the program really starts to run, `result` starts off with the assigned value. This way we can run an expensive proc at compile-time, so that its result can be used in run-time. A more concrete example of this is presented in line (3), where the value of the constant PI is being calculated at compile-time.  
In lines (4)-(5) two lambdas are called at compile-time. Line (6) shows the same for a simple code block. Make sure you understand the difference between the two outputs.

> Summary: difference between running at compile-time and at runtime:
```c++
proc1 :: () { ... }

#run proc1();   // (1) running byte-code at compile time

main :: () {
    proc1();    // (2) running native code at runtime
}
```

**How does it work?**  
The code pieces that should run at compile-time are first converted to byte-code, which is then run in an interpreter. It also loads dll's dynamically and looks up in them what is needed. That's why compile-time execution runs a little slower than normal run-time.

**These are some useful applications:**  
-  Insert build-time data, for example results of calculations that can be done at compile-time instead of at runtime: 		`srgb_table: [] float = #run generate_linear_srgb();`
or sometimes called:	_"Bake the data into the program binary"_
- Run test cases;
- Do code style checks, run automated code review (house style);
- Dynamically generate code and insert it to be compiled: this is what meta-programming is all about;
- Contact a build server and retrieve/send build data
- Download the OpenGL spec and build the most recent gl.h header file
…

### 26.2.1 The #compile_time directive
With all these meta-programming functionalities, it can be important to know when you are running in compile-time and when you are really running. Luckily there is a **#compile_time** directive, that is true at compile-time, and false at run-time. However it cannot be used as a constant.

See _26.3_ct.jai_:
```c++
#import "Basic";

main :: () {
    print("#compile_time is %\n", #compile_time); // => #compile_time is false

    if #compile_time {
        #run print("compile time.\n");
    } else {
        print("not compile time.\n"); // => not compile time
    }
}

#run main(); // => #compile_time is true
```

Use this for example when you want a procedure to do something different at compile_time, as opposed to run-time.

### 26.2.2 The #no_reset directive
Arrays are an exception to what we have seen in this section: when they get values at compile-time, these values are reset (initialized to zeros) before running the program.
This is shown in the following program:

See _26.4_no_reset.jai_:
```c++
#import "Basic";

array: [4] int;
#no_reset arraynr: [4] int;  // (1)

#run {                       // (2)
  array[0] = 1;
  array[1] = 2;
  array[2] = 3;
  array[3] = 4;
  arraynr[0] = 1;
  arraynr[1] = 2;
  arraynr[2] = 3;
  arraynr[3] = 4;
}

main :: () {
  print("%\n", array);   // (3) => [0, 0, 0, 0] 
  print("%\n", arraynr); // (4) => [1, 2, 3, 4]
}
```

Although both arrays `array` and `arraynr` get values at compile-time in line (2), array has 0 values at runtime (see line (3)). To counter this behavior (see line (4)), prefix the array when defined with the **#no_reset** directive, as we did for `arraynr` in line (1).

## 26.3 Compiling conditionally with #if
if and all its run-time variants where discussed in § 14. The code following an if is always compiled into the executable, and that is what we want: in most cases the condition depends on a variable(s), so one time it is true, the other time it is false.
But it could be useful to compile a piece of code only when a certain condition is true. This is a bit similar to #assert (see 20.2.1).  
For example: 
- when we run in a development- or test-environment, some code could be different than in a production environment;
- other code could be needed, depending on the operating system on which we run;

This is exactly what **#if** does:

See _26.5_if.jai_:
```c++
#import "Basic";

CONSTANT :: 3;

main :: () {
    print("The operating system is %\n", OS); // (1) => The operating system is WINDOWS
    #if OS == .WINDOWS {                      // (2)
        print("I'm on Windows!\n");           // (3) => I'm on Windows!
    }   

    #if OS == .LINUX {
        print("I'm on Linux!\n");
    }

    #if CONSTANT == 0 {                       // (4)
    }   else #if CONSTANT == 1 {
    }   else #if CONSTANT == 2 {
    }   else {  
        print("CONSTANT is %\n", CONSTANT); // => CONSTANT is 3
    }
}
```

At the start of a program compilation, the operating system on which it runs is stored in the variable (??) OS (see line (1)). We check in line (2) whether this is ".WINDOWS". Only then line (3) is compiled into the executable. In other words: the 2nd #if-construct for .LINUX is not compiled into the executable when we compile on another OS!  
In line (4) and following, we use this to test on a CONSTANT defined by our program itself.

> #if is tested at compile-time. When its condition returns true, that block of code is compiled, otherwise it is not compiled.

Using this feature, code can be conditionally compiled and included in the resulting executable, depending on the target environment (development, test, release) or target platform (different OS's).

This technique is used in the _Basic_ module to load specific code depending on the OS:
```c++
#if OS == .WINDOWS {
    #load "windows.jai";
}

#if OS == .LINUX {
    #load "linux.jai";
}

#if OS == .MACOS {
    #load "osx.jai";
}
```

## 26.4 Inserting code with #insert
The **#insert** directive inserts a piece of compile-time generated code into a procedure or a struct.

See _26.5_if.jai_:
```c++
```

In line (1) #insert takes a string containing a line of code, and inserts it as code at that location in the source.


## 26.5 Basics of macros
A macro is also a way to insert code at compile-time. 
Unlike the C programming language in which a macro is completely arbitrary, Jai macros are more controlled, better supported by the compiler, and come with much better typechecking.
They make some kinds of meta-programming easier. If they are well designed, they allow you to raise the level of code abstraction, by creating your own mini-language, specific to the problem space, and then you can solve your particular problem in that mini-language. Macros also allow you to cut down the repetition of not only specific actions (procedures are best for that), but of more abstract constructs. When they are not well designed, however, creating and using macros, results in unmaintainable messes (hard to read, to understand, to debug). So you should only resort to macros when it really makes sense in your program's context.  
Jai's macros are so called _hygienic_:
- they do not cause any accidental captures of identifiers from the environment;
- they modify variables only when explicitly allowed;
  
The examples in this section are meant to show the basic syntax, they do not show a useful application of macros, where you would prefer them above procs.

Syntactically, macros resemble a procedure: they are defined by adding the **#expand** directive to the end of the proc declaration before the curly brackets. See `macro0` defined in line (1) below, which does nothing. They are called like any proc: `macro_name()`.

See _26.7_macros_basics.jai_:
```c++
#import "Basic";

macro0 :: () #expand { }   // (1)

macro1 :: () #expand {
  `a += 10;                //  (2) 
}

maxm :: (a: int, b: int) -> int #expand {  // (4)
  if a > b then return a;
  return b;
}

macro2 :: () -> int #expand {   // (5)
  if `b < `c {
    return 0;
  }
  defer print("Defer inside macro\n"); // => Defer inside macro
  return 1;
}

macro3 :: () #expand {
  print("This is macro3\n");
  nested_macro();

  nested_macro :: () #expand {
    print("This is a nested macro\n");
  }
}

factorial :: (n: int) -> int #expand {
  #if n <= 1 return 1;
  else {
    return n * factorial(n-1);
  }
}

macfunc :: () -> string {
  a := 0;
  b := 100;
  c := macron();
  return "none";

  macron :: () -> int #expand {
    `defer print("Defer inside macro\n");
    if `a < `b {
      `return "Backtick return macro"; 
    }
    return 1;
  }
}

main :: () {
  a := 0;
  macro1(); // (3)
  print("a is: %\n", a); // (4) => a is: 10

  b := 7;
  c := 3;
  print("max is %\n", maxm(b, c)); // => max is 7

  print("macro2 returns %\n", macro2()); // => macro2 returns 1

  macro3();
  // => This is macro3
  // => This is a nested macro

  x := factorial(5);
  print("factorial of 5 = %\n", x); // => factorial of 5 = 120

  s := macfunc();  // => Defer inside macro
  print("%\n", s); // (6) => Backtick return macro
}
```

`macro1` does something new: it adds 10 to the variable `a` found in the outer scope in line (3): the backtick in front of a (`a) denotes that `a` must exist in the outer scope. When `macro1` is called in main(), this is indeed the case. We see in line () that `a` has value 10, through the execution of `macro1`.
If `a` does not exist, we get the following error in line (2): `Error: Undeclared identifier 'a'.`
while getting this message at line (3): `Info: While expanding macro 'macro1' here...`

Line (4) shows that a macro can have parameters, just like any proc. This is a way to avoid the ` syntax.
`macro2` defined in line (5) refers to two outer variables b and c. In this case it returns 1, but just before that prints something by using the `defer` keyword.
`macro3` shows nested macros: a macro can contain and call macros defined inside itself.  
`factorial` is an example of a recursive macro; #if needs to be used here, else you get the following `Error: Too many nested macro expansions. (The limit is 1000.)`
`maxfunc` is a procedure which calls a nested macro `macron`; this returns "Backtick return macro" as return value from `maxfunc`.