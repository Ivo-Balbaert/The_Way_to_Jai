# 26 Meta-programming and macros

A 'meta-program' is a piece of code that alters (or 'programs') an existing program (another piece of code).
In Jai, this takes place solely at compile-time. The compiler gives you the source code in AST format (Abstract Syntax Tree) for you to modify.

> Jai offers arbitrary compile-time execution, with powerful meta-programming features to modify your code in whatever way you want, but all meta-programming is limited strictly to compile-time execution. This capability is one of the main pillars of the language.
> One could even argue that Jai introduces another programming paradigm: "Metaprogramming oriented programming" or "Compiler oriented programming".
> In short it's about maximizing code generation at compile time with a nice tool-set: macros, types as first class values, polymorphic procedures and data structures, built-in build system, understanding of AST and so on.

This functionality has been built into the language from the start. Meta-programs can modify the program in arbitrarily complex ways easily. 

In order to do meta-programming, full type-information is needed. Jai has that available at compile-time (see § 5.1.4, § 9, § 16),  but also retains static type information for every structure available at runtime (see § 26.1).
In § 13.6 and § 15.4 we discussed some useful reflection methods for enums. In § 15.5 we highlighted useful reflection methods for structs, useful for serialization (see § 15.6).

Using type info to meta-program is also called _reflection_ or _introspection_ in other languages.

We already talked about running code at compile time as early as § 3.2.4. Jai provides full compile-time code execution, meaning that all Jai code can also be executed while compiling.

> Remark: because all of this processing happens at compile-time, there is a natural overlap between this chapter and § 27.

## 26.1 The type table
See *26.1_type_table.jai*:
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
        print("  type: % ", it.type); 
        print("  size: %\n", it.runtime_size); 
    }
}

/*
The type table has 355 entries: 
0:   type: INTEGER   size: 8
1:   type: INTEGER   size: 2
2:   type: VARIANT   size: 2
3:   type: INTEGER   size: 1
...
381:   type: STRUCT   size: 16
382:   type: PROCEDURE   size: 8
383:   type: PROCEDURE   size: 8
384:   type: POINTER   size: 8
385:   type: ARRAY   size: 16
*/
```

Full introspection data is available for all structs, functions, and enums at runtime. A structure called **_type_table** contains all variables with their types; this is populated at compile-time. Then this data structure is stored in the data segment of the executable file, making it available at runtime.  
Requesting type info returns a pointer to an entry in the type table that is a `Type_Info` struct.
This structure is not directly accessible, you have to use the proc `get_type_table` from module _Compiler_,  as we did in line (1).  
`table` has as type [] *Type_Info.  

(See also build option: `runtime_storageless_type_info`  in § 30.4.7 )

## 26.2 Running code at compile time with #run
We first discovered that this was possible in §3.2.4. We talked about the bytecode interpreter in § 4.2, saw how constants can be calculated at compile time in §5.2.2, and how this can be used for debugging purposes in § 20.  
We already know that we need to use `#run main()` to run the whole program at compile-time.
In fact, any code (a code-line, a block of code or a procedure) can be run at compile time with **#run**. #run produces a constant as result.

See *26.2_run.jai*:
```c++
#import "Basic";
#import "Math";

proc1 :: () { print("This is proc1 :: ()\n"); }
proc2 :: () -> int { 
    print("This is proc2 :: ()\n");
    return 42;
}

#run proc1();             // (1) => This is proc1 :: ()
result := #run proc2();   // (2) => This is proc2 :: ()
PIA :: #run compute_pi();  // (3)

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

globvar := 0;
#run { globvar = 108; } // (7A)

main :: () {
    proc1();        // => This is proc1 :: () - proc1 is called at run-time

    print("result is %\n", result); // => result is 42   
    print("PIA is %\n", PI); // => PIA is 3.141699

    print("globvar at runtime is: %\n", globvar); 
    // (7B) => globvar at runtime is: 0

    f1 :: ()  => 1000;
    f2 :: (c) => c + 1;

    a :: #run f1();     // (4)
    b :: #run f2(a);    // (5)
    print("a=%, b=%\n", a, b); // => a=1000, b=1001

    #run {              // (6)
        print("I am running this block only at compile-time!");
        n := 108;
    }

    R22 :: 0.7071068; 
    v: Vector3;
    v = .{cast(float) #run sin(R22 * .5), 1, 0};
    TAU :: 6.0;
    // v2 = .{sin(TAU * .5), 1, 0}; // Error: All values provided in a struct literal must be constant, but argument 1 is not.
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

#run can access and modify globals and by default, global variables will be reset back to the original default values when outputting the executable (see lines 7A-B).  If you don't want that, use `#no_reset` (see § 26.2.2).

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
- Test conditions before compiling:  
  `#run assert(condition)` will not compile if condition is false.
-  Insert build-time data, for example results of calculations that can be done at compile-time instead of at runtime: 		`srgb_table: [] float = #run generate_linear_srgb();`
or sometimes called:	_"Bake the data into the program binary"_
- Run test cases;
- Do code style checks, run automated code review (house style);
- Dynamically generate code and insert it to be compiled: this is what meta-programming is all about;
- Contact a build server and retrieve/send build data
- Download the OpenGL spec and build the most recent gl.h header file
But: you can't run FFI (see § 29) during a #run.
…

The following program will make the difference between compile-time and run-time even clearer.
See *26.15_comprun.jai*:
```c++
#import "Basic";

comprun :: (x: $T) {  
    #run print("Compiling 'comprun' for T == %.\n", T);  // (1) 
    print("The value of x is %, of type %.\n", x, T);    // (2) 
}
 
main :: () {
    a: u8 = 5;
    b: u8 = 11;    
    comprun(a);   // (3)
    comprun(b);
    comprun(a * 3 + b);

    comprun(1.1);  // (4)
    comprun(3.33); // (5)
    comprun("Hello, Sailor!"); // (6)

    comprun(b - a);  // (7) 
}

/*
Compiling 'comprun' for T == u8.
Compiling 'comprun' for T == string.
Compiling 'comprun' for T == float32.
Linker ...
After compilation...
The value of x is 5, of type u8.
The value of x is 11, of type u8.
The value of x is 26, of type u8.
The value of x is 1.1, of type float32.
The value of x is 3.33, of type float32.
The value of x is Hello, Sailor!, of type string.
The value of x is 6, of type u8.
*/
```

Here we have a proc `comprun` in which line (1) will run at compile-time (because of #run), and where line (2) will work at run-time.  
The three lines following (3) only activate the #run 1 time, because all expressions with which it is called are of the same type u8. It only needs to build once. But at runtime the procedure is called and prints out 3 times.In line (4), comprun is called with a new type 'float', so it compiles again, which we can see because #run executes for the 2nd time. Line (5) doesn't trigger a re-compilation, because the parameter is also of type float. But line (6) recompiles, because now a string is passed. (7) doesn't recompile, because there is already a compiled form for comprun with T == u8.
Note that the order of the #run's can vary, because compilation works multi-threaded.

#run can also return basic struct values or multidimensional arrays. Complications can arise because of pointers inside structs, and values that are not retained between compile-time and run-time. In order to modify more complex data structures with #run,the #no_reset directive can be useful (see § 26.2.2).

### 26.2.1 The #compile_time directive
With all these meta-programming functionalities, it can be important to know when you are running in compile-time and when you are 'really' running. Luckily there is a **#compile_time** directive, that is true at compile-time, and false at run-time. However it cannot be used as a constant.

See *26.3_ct.jai*:
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
When variables get values at compile-time, these values are reset (initialized to zeros) before running the program. 
The `#no_reset` directive tells the compiler that the value of a variable can be retained from compile-time to run-time.
This is shown in the following program:

See *26.4_no_reset.jai*:
```c++
#import "Basic";

#no_reset globvar := 0;
#run { globvar = 108; } // (1A)

array: [4] int;
#no_reset arraynr: [4] int;  // (2)

#run {                       // (3)
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
    print("globvar at runtime is: %\n", globvar); // (1B) => globvar at runtime is: 108

    print("%\n", array);   // (4) => [0, 0, 0, 0] 
    print("%\n", arraynr); // (5) => [1, 2, 3, 4]
}
```
In contrast to what happened in program 26.2_run.jai, because `globvar` is preceded by #no_reset, it retains its value at runtime (see lines 1A-B).
As a 2nd example, although both arrays `array` and `arraynr` get values at compile-time in line (3), array has 0 values at runtime (see line (4)). To counter this behavior (see line (5)), prefix the array when defined with the **#no_reset** directive, as we did for `arraynr` in line (2).

### 26.2.3 Computing a struct at compile-time and retrieving at run-time
The following code shows how to compute a struct at compile-time, then stash its memory representation (into an []u8), and then retrieve it at runtime:
(example from Jai Community - Wiki)

See *26.30_stash_struct.jai*:
```c++
#import "Basic";
 
Stock :: struct {
    x : int;
}
 
st : Stock;
st_data :: #run store_as_u8(make_struct());   // (1) 
 
make_struct :: () -> Stock {
    // compute a struct
    return Stock.{12};
}

store_as_u8 :: (value : $T) -> [] u8 {
    array : [size_of(T)] u8;
    memcpy(*array, *value, size_of(T));
    return array;
}
 
restore_from_u8 :: (dest: *$T, data: [] u8) {
    value : T;
    memcpy(dest, data.data, size_of(T));
}
 
init :: () {
    restore_from_u8(*st, st_data);
}
 
main :: () {
    print("% % % - % % \n", st, st.x, type_of(st), st_data, type_of(st_data)); 
    // (2) => {0} 0 Stock - [12, 0, 0, 0, 0, 0, 0, 0] [8] u8
    init();  // (3) 
    print("% % %\n", st, st.x, type_of(st)); // => {12} 12 Stock
}
```

In line (1), the struct's data are computed and stored as a []u8 with #run at compile time. At run-time, we see in line (2) that the struct is zeroed. But we can restore its data from the []u8 st_data, as shown in line (3). This process is sometimes called "baking a struct".


## 26.3 Compiling conditionally with #if
if and all its run-time variants where discussed in § 14. The code following an if is always compiled into the executable, and that is what we want: in most cases the condition depends on a variable(s), so one time it is true, the other time it is false.
But it could be useful to compile a piece of code only when a certain condition is true. This is a bit similar to #assert (see 20.2.1).  
For example: 
- when we run in a development- or test-environment, some code could be different than in a production environment;
- other code could be needed, depending on the operating system on which we run;

This is exactly what **#if** does:

See *26.5_if.jai*:
```c++
#import "Basic";
#import "Math";

CONSTANT :: 3;

ENABLE_EXTRA_MODES :: true;

Log_Mode :: enum {
    NONE;           
    MINIMAL;        
    EVERYDAY;       
    VERBOSE;

    #if ENABLE_EXTRA_MODES {           // (5)
            VERY_VERBOSE;
            SECRET;
            TOP_SECRET;
    }       
}

IS_PATIENT :: true;

Person :: struct {
    name            : string;
    age             : int;
    location        : Vector2;

    #if IS_PATIENT  disease := "common cold"; // (6)
}

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

    name := #ifx OS == .WINDOWS then "Microsoft Windows"; else "Linux"; // (7)
    print("name is %\n", name); // => name is Microsoft Windows

}
```

At the start of a program compilation, the operating system on which it runs is stored in the global compiler constant OS (see line (1)). We check in line (2) whether this is ".WINDOWS". Only then line (3) is compiled into the executable. In other words: the 2nd #if-construct for .LINUX is not compiled into the executable when we compile on another OS!  
In line (4) and following, we use this to test on a CONSTANT defined by our program itself.
Line (5) shows that #if can also be used inside enums to conditionally define new enum values.  
The same is true for struct fields, see line (6).

Note that the condition after #if must be a compile-time constant (can be checked with `is_constant`, see § 5.2.2). This includes anything calculated with #run. Also all code after #if / else branches must be syntactically correct, and the code blocks after #if / else define no scope of their own (contrary to if / else blocks).  
#if's can also be nested.

> #if is tested at compile-time. When its condition returns true, that block of code is compiled, otherwise it is not compiled.

Summarized:  
If the condition that follows is false:
> if will not execute the block
> #if will not compile the block

Caution: there is no #else, just use else.  
For one-liners, there is #ifx (see line (7)).

Using this feature, code can be conditionally compiled and included in the resulting executable, depending on the target environment (development, test, release) or target platform (different OS's).

Here is a way to use it in debugging to print out info you want to inspect;in production this code will not be compiled, only the else branch:
```
// define a constant DEBUG :: TRUE; // change to false for production
#if DEBUG {
    print(debug_info);
} else {
    // do normal processing
}
```
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
There is a nice illustration of this in example § 29.8.
See also jai\examples\system_info for how to display info of your OS and the hardware on which it runs.

## 26.4 Inserting code with #insert
The **#insert** directive inserts a piece of compile-time generated code represented as a string (or code that has been represented as data in some other way) into a procedure or a struct.

See _26.6_insert.jai_:
```c++
#import "Basic";

my_code :: #string END_STRING
  a += 100;
  b += 100;
  c += 1000;
END_STRING;

main :: () {
    a := 1;
    b := 2;
    #insert "c := a + b;";   // (1)
    print("c is %\n", c);    // => c is 3

    d :: "add(42, 8);";      // (2)
    x := 1 - #insert d;
    print("x = %\n", x);     // => x = -49

    add :: (n: int, m: int) -> int { return n + m; };

    #insert my_code;         // (3) 
    print("a, b, c are % % % \n", a, b, c);    // => a, b, c are 101 102 1003
}
```

The 1st way #insert can be used is illustrated in line (1): there `#insert` takes a string containing a line of code, and inserts it as code at that location in the source. Line (2) shows that it also can be used at an expression level.  Line (3) shows how a multi-line string can be inserted as a piece of code.

Here is a more useful example, where #insert is used with multi-line strings:
See _26.24_insert_multi.jai_:
```c++
#import "Basic";

report :: ($header: string, $body: string, $footer: string, n: int) {
    #insert header;
    for 1..n {
        #insert body;
    }
    #insert footer;
}

header :: #string DONE
    count := 0;
    print("Start of the report:\n");
DONE

body :: #string DONE
    print("    ... one iteration! Incrementing!\n");
    count += 1;
DONE

footer :: #string DONE
    print("End of the report - count is: %.\n", count);
DONE

main :: () {
    report(header, body, footer, 5);
}

/*
Start of the report:
    ... one iteration! Incrementing!
    ... one iteration! Incrementing!
    ... one iteration! Incrementing!
    ... one iteration! Incrementing!
    ... one iteration! Incrementing!
End of the report - count is: 5.
*/
```

You can see that it is real code, because variable `count` is incremented. Header, body, and footer are known at compile-time because of the $'s, so we can #insert them. This gives you some flexibility for constructing code.

2nd way: Even the entire contents of a struct can be made through a `#insert -> string` construction. This takes the form:
```c++
A_Type :: struct( ... ) {
    #insert -> string { ... }
}
``` 
The `#insert -> string` is in fact a short (lambda) form for:  
`#insert #run () -> string {  ...  }();`
`() -> string` is the declaration of the lambda, { ... } is its code, and it is called with the last () pair like this: `{  ...  }()`
Instead of an anonymous proc, this form can also take a named procedure, like:  `#insert #run set_diagonals_to_1(N)`.  
Here is an example where this is used to make an identity matrix (example taken from how_to/600):

See _26.25_insert_ident_matrix.jai_:
```c++
#import "Basic";

Matrix :: struct (N: int) {
    items: [N*N] float;                  // (1)
    #insert #run set_diagonals_to_1(N);  // (2) 
}

set_diagonals_to_1 :: (N: int) -> string {
    builder: String_Builder;
    for 0..N-1 {
        print_to_builder(*builder, "items[%] = 1;\n", it*N + it);
    }
    return builder_to_string(*builder);
}

main :: () {
    m: Matrix(5);
    print("The matrix contains:\n");
    for j: 0..4 {
        for i: 0..4 {
            print("%  ", m.items[j*5 + i]);
        }
        print("\n");
    }
}

/*
The matrix contains:
1  0  0  0  0
0  1  0  0  0
0  0  1  0  0  
0  0  0  1  0
0  0  0  0  1
*/
```

`Matrix` is a struct with parameter N, which defines the size of the `items` array, which is initialized to all zeros (0) in line (1). In line (2) the matrix is transformed to an identity matrix, using `#insert #run proc()`, where the concrete proc here returns a string. Remember you can view the generated string in the .build/.added_strings_w2.jai file.

(This mechanism is also applied in the unroll for loop in § 26.5.2, and in the construction of an SOA struct, see § 26.10.2).

### 26.4.1 Type Code and #code
A variable of type Code can be constructed by using the **#code** directive:  
`#code { // a code block }`, like `#code { x += 7 }`. 
This can also be one line, like this:  
`code :: #code a := Vector3.{1,2,3};`  
or:  
`#code (a < b)`  
All these expressions have type Code.
See an example of use in § 26.5.2

You can convert a #code during compile-time execution back-and-forth to the syntax tree structures (AST) defined in Compiler. Also you can take a Code, convert it to the tree, manipulate around with the tree, and resubmit the changed tree.

Here are some use-cases :
See _26.26_insert_code.jai_:
```c++
#import "Basic";

what_type :: ($c: Code) {                   // (2)
    T :: c.type;
    print("T is %\n", T);
}

main :: () {
    x := 3;
    x *= x; 
    x *= x; 
    x *= x; 
    #insert -> Code {                       // (1)
        return #code x = (x * 10) + 3495;
    }
    print("x is %\n", x); // => x is 69105
    assert(x == 69105);

    what_type(2 + 3 + 4);           // (3A) => T is s64
    what_type("Hello, Sailor!");    // (3B) => T is string
}
```

In the same way as you can do a #insert -> string (see previous §), you can make a `#insert -> Code {  return #code  ...   }` (see line (1)).
`#insert` can also take a variable c of type Code, e.g.: `#insert(c: Code);`. It is also often used in the body of a macro like this:  
```c++ 
some_macro :: (body: Code) #expand {
    ...
    #insert body;
    ...
}
```

In lines (3A-B) we call a proc `what_type` (defined in line (1)) with a constant Code argument. The $c ensures that it is constant (see § 22.6)
Making `what_type` a macro would also ensure that c is constant. For non-constant code arguments, you can use the proc `get_root_type` from the _Compiler_ module (see examples/code_type.jai).

(See also § 26.5 Macros, specifically `macroi` in the first example.)



## 26.5 Basics of macros
A macro is also a way to insert code at compile-time at the call site, so it is similar to an inlined procedure. 
Unlike the C/C++ programming language in which a macro is completely arbitrary, Jai macros are more controlled, better supported by the compiler, and come with much better typechecking. Moreover, they can be debugged with the same techniques we saw in § 20.
They make some kinds of meta-programming easier. If they are well designed, they allow you to raise the level of code abstraction, by creating your own mini-language, specific to the problem space, and then you can solve your particular problem in that mini-language. Macros also allow you to cut down the repetition of not only specific actions (procedures are best for that), but of more abstract constructs. When they are not well designed, however, creating and using macros, results in unmaintainable messes (hard to read, to understand, to debug). So you should only resort to macros when it really makes sense in your program's context: they are a 'last-resort' thing to use.

Jai's macros are so called _hygienic_:
- they do not cause any accidental captures of identifiers from the environment;
- they modify variables only when explicitly allowed;

Syntactically, macros resemble a procedure: they are defined by adding the **#expand** directive to the end of the proc declaration before the curly brackets. 
Let's see this in *26.7A_macros_intro.jai*:
```c++
#import "Basic";

// proc1 :: ()         {      // (1)  procedure
proc1 :: () #expand {      // (2)  macro
    print("You are in proc1!");
}   

main :: () {
    proc1(); // => You are in proc1!
}
```

`proc1` in this code is originally a procedure (line (1)). If you add `#expand` before its body (or uncomment it), it becomes a macro (line (2)). The way of calling them is the same, their output is the same.

Expand in `#expand` means that the macro-code is processed, transformed to real code, that is then inserted at the call-site of the macro.

The following examples in this section are meant to show the basic syntax, they do not show a useful application of macros, where you would prefer them above procs.

The syntax is shown in `macro0` defined in line (1) below, which does nothing. A macro is called like any proc: `macro0()`.

See *26.7_macros_basics.jai*:
```c++
#import "Basic";
#import "Math";

macro0 :: () #expand { }   // (1)

macro1 :: () #expand {
    a := "No backtick";    // (1B) 
    print("a at macro1 start is: %\n", `a); //   (4A) => a at macro1 start is: 0
    `a += 10;              //  (2) 
}

maxm :: (a: int, b: int) -> int #expand {  // (5)
    if a > b then return a;
    return b;
}

macro2 :: () -> int #expand {   // (6)
    if `b < `c {
      return 0;
    }
    defer print("Defer inside macro2\n"); // (6B) // => Defer inside macro2
    // `defer print("`Defer inside macro2\n"); // (6C) // => `Defer inside macro2
    return 1;
}

macro3 :: () #expand {
    print("This is macro3\n");
    `c = 108;
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
    print("In maxfunc just before calling macron\n"); 
    c := macron();
    print("In maxfunc just before returning\n");  // never printed!
    return "none";

  macron :: () -> int #expand {
      defer print("Defer inside macron\n");  // (7)
      if `a < `b {
          `return "Backtick return macron\n"; 
       }
       return 1;
  }
}

macroi :: (c: Code) #expand {   // (9)
    #insert c;
    #insert c;
    #insert c; 
}

main :: () {
    a := 0;
    macro1(); // (3)
    print("a is: %\n", a); // (4B) => a is: 10

    b := 7;
    c := 3;
    print("max is %\n", maxm(b, c)); // => max is 7

    print("macro2 returns %\n", macro2()); // => macro2 returns 1

    macro3();
    // => This is macro3
    // => This is a nested macro
    print("c is %\n", c); // => c is 108


    x := factorial(5);
    print("factorial of 5 = %\n", x); // => factorial of 5 = 120

    s := macfunc();  
    // => In maxfunc just before calling macron
    // => Defer inside macron
    print("%\n", s); // (8) => Backtick return macron 

    va := Vector3.{1,2,3};
    code :: #code print("% - ", va);
    macroi(code); // => {1, 2, 3} - {1, 2, 3} - {1, 2, 3} -
}

/* with defer in macro 2:
a at macro1 start is: 0
a is: 10
max is 7
Defer inside macro2
macro2 returns 1
This is macro3
This is a nested macro
c is 108
factorial of 5 = 120
In maxfunc just before calling macron
Defer inside macron
Backtick return macro
{1, 2, 3} - {1, 2, 3} - {1, 2, 3} -
*/
```

`macro1` does something new: it adds 10 to the variable `a` found in the outer scope in line (3): the backtick in front of a (`a) denotes that `a` must exist in the outer scope. When `macro1` is called in main(), this is indeed the case. We see in line (4B) that `a` has value 10, through the execution of `macro1`. The a in line (1B) is just a local (to the macro) variable, it does not pollute the outer scope.

> Macros can have context, namely if indicated with ` they can see variables in their outer scope.

If `a` does not exist, we get the following error in line (2): `Error: Undeclared identifier 'a'.`
while getting this message at line (3): `Info: While expanding macro 'macro1' here...`
The ` mechanism for looking up outer variables only works one level up.

Line (5) shows that a macro can have parameters, just like any proc. This is a way to avoid the backtick syntax.
`macro2` defined in line (6) refers to two outer variables b and c. In this case it returns 1, but just before leaving the macro, it prints something by using the `defer` keyword in line (6A). But notice what happens when we use `defer in line (6B): because of the backtick the defer now takes the scope of the caller (main() in this case) as its scope, and prints its message just before main() ending (see the attached complete output in both cases).
`macro3` shows _inner_ or _nested_ macros: a macro can contain and call macros defined inside itself. But there is a limit as to how many macro calls you can generate inside another macro.  
`factorial` is an example of a recursive macro; #if needs to be used here (instead of if), else you get the following `Error: Too many nested macro expansions. (The limit is 1000.)` 
`maxfunc` is a procedure which calls a nested macro `macron`; this returns "Backtick return macro" as return value from `maxfunc`.  

**Exercise** (see changer_macro.jai)  
Write a macro changer that takes 2 integer arguments and can access an outer variable x. x is multiplied with the 1st argument, and the 2nd argument is added to it.

### 26.5.1 Using a macro with #insert
`macroi` in line (9) illustrates that we can use #insert (see § 26.4) inside a macro: it takes a code argument and inserts it 3 times in the main code.

### 26.5.2 Using a macro with #insert to unroll a for loop
Sometimes you might want to unroll loops to optimize a program's execution speed so that the program does less branching. Loops can be unrolled through a mixture of #insert directives and macros. In the example below, we unroll a basic for loop that counts from 0 to 10.

See *26.14_insert_for_loop.jai*:
```c++
#import "Basic";

unroll_for_loop :: (a: int, b: int, body: Code) #expand {
  #insert -> string {
    builder: String_Builder;
    print_to_builder(*builder, "{\n");
    print_to_builder(*builder, "`it: int;\n");
    for i: a..b {
      print_to_builder(*builder, "it = %;\n", i);
      print_to_builder(*builder, "#insert body;\n");  // (1)
    }
    print_to_builder(*builder, "}\n");
    return builder_to_string(*builder);
  }
}

main ::() {
  unroll_for_loop(0, 10, #code {
    print("% - ", it); // => 0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 
  });

}
```

In this example `unroll_for_loop` is a macro that receives a Code parameter. It uses the `#insert -> string` shortcut (see § 26.4). In fact, it uses multiple inserts, #insert can be run recursively inside another #insert as seen in line (1).  
When compiling, you can see what is inserted in `.\build\.added_strings_w2`.

### 26.5.3 Using a macro for an inner proc
In § 17.2 we saw that an inner proc cannot access outer variables. A way to circumvent this is to define the inner proc as a macro and use `. The example below is inner_proc() from 17.2_local_procs.jai, which is now redefined as a macro to be able to change the outer variable x.

See *26.13_local_procs.jai*:
```c++
#import "Basic";

proc :: () {
    x := 1;
    inner_proc();
    print("x is now %\n", x); // => x is now 42

    inner_proc :: () #expand {
        `x = 42;
    }
}

main :: () {
    proc();
}
```

Jai does not support closures (also called captures of variables). The technique demonstrated here is a way to emulate a closure.

> Write a macro to get the functionality of closures in Jai.

In § 15.1.3 we showed code that iterated over a linked list with a while loop.
Wouldn't it be nice if we could do this with a for loop?

### 26.5.4 Using a macro with #insert,scope()
See *26.22_insert_scope.jai*:
```c++
#import "Basic";

bubble_sort :: (arr: [] $T, compare_code: Code) #expand { // (1)
  for 0..arr.count-1 {
    for i: 1..arr.count-1 {
      a := arr[i-1];
      b := arr[i];
      if !(#insert,scope() compare_code) { // (2) arr[i-1] > arr[i], so swap them
        t := arr[i];
        arr[i] = arr[i-1];
        arr[i-1] = t;
      }
    }
  }
}

main :: () {
    arr: [10] int;
    arr = .[23, -89, 54, 108, 42, 7, -2500, 1024, 666, 0];

    bubble_sort(arr, #code (a <= b));
    print("sorted array: %\n", arr);
    // => sorted array: [-2500, -89, 0, 7, 23, 42, 54, 108, 666, 1024]

    for i: 0..9  arr[i] = cast(int) random_get() % 100;
    bubble_sort(arr, #code (a < b));
    print("sorted array: %\n", arr);
    // => sorted array: [-58, -43, -33, -33, -25, 6, 26, 78, 89, 92]
}
```

The macro `bubble_sort` defined in line (1) takes an array and a piece of code to compare subsequent item-pairs of the array. The `#insert,scope()` in (2) (formerly #insert_internal) makes it possible to use the outer macro-variables a and b in compare_code, so it allows code to access variables in the local scope.  It lets you specify the scope into which to insert the target Code or string, by saying #insert,scope(target). 'target' is a Code that must be constant at compile-time. The scope where the Code lives is used as the enclosing scope for the #insert (which determines how identifiers inside the inserted code are resolved). If they are not in order, they are swapped.
`#insert,scope() compare_code` inserts a comparison code (a <= b) into a bubble sort. The inserted code acts like a comparison function, except without the drawbacks of function pointer callback performance cost.
This example also shows that a macro can be polymorphic.

### 26.5.5 Using a macro for swapping values
See *26.28_swap_macro.jai*:
```c++
#import "Basic";

swap :: (a: Code, b: Code) #expand {
  t := (#insert a);
  (#insert a) = (#insert b);
  (#insert b) = t;
}

main :: () {
    a, b := 3, 5;
    print("Pre-swap:  a is %, b is %\n", a, b);
    swap(a, b);    // (2)
    print("Post-swap: a is %, b is %\n", a, b);
}

/*
Pre-swap:  a is 3, b is 5
Post-swap: a is 5, b is 3
*/
```

This macro uses Code arguments and #insert to insert the values. It also provides type-checking: a and b must be of the same type. 

### 26.5.6 Measuring performance with a macro
Remember § 6B.2 where we used get_time() to measure performance of a procedure (see 6B.2_get_time.jai) ? We can also do this with a macro `perf_measure`:

See *26.33_measure_performance.jai*:
```c++
#import "Basic";

factorial :: (n: int) -> int {
    if n <= 1  return 1;
    return n * factorial(n-1);
}

perf_measure :: (code: Code) #expand {
    secs := get_time();
    #insert code;   // (1)
    secs = get_time() - secs;
    print("Piece of code took % seconds\n", secs);
}

main :: () {
    code :: #code print("Factorial 20 is %\n", factorial(20));
    perf_measure(code);
    // Factorial 20 is 2432902008176640000
    // Piece of code took 0.000151 seconds
}
```

Why use a macro? Because you want to #insert at compile-time the piece of code of which you want to measure the performance. This happens in line (1).


## 26.6 Using a for-expansion macro to define a for loop
As easy as it is to for-loop over an array, this is not defined for other composite data-structures, such as the linked list we discussed in § 12.6. But this can be done with a macro, by defining a so-called *for_expansion*:

See *26.8_linked_list_for_expansion.jai*:
```c++
#import "Basic";

LinkedList :: struct {
    data: s64; 
    next:  *LinkedList;
}

main :: () {
    lst := New(LinkedList); // lst is of type *LinkedList
    lst.data = 0;

    a :=  New(LinkedList); 
    a.data = 12;
    lst.next = a;
    
    b  := New(LinkedList);
    b.data = 24;
    a.next = b;
    
    c  := New(LinkedList);
    c.data = 36;
    b.next = c;

    c.next = null; 

    print("List printed in a for loop: \n");
    print("The list starts with a %\n", lst.data);
    // version (1)
    for_expansion :: (list: *LinkedList, body: Code, flags: For_Flags) #expand {  // (1)
        iter := list;   // (2)
        i := 0;
        while iter != null {    // (3)
            iter = iter.next;
            if !iter break;     // (4)
            `it := iter.data;   // (5)
            `it_index := i;     // (6)
            #insert body;       // (7)
            i += 1;             // (8)
        }
    }

    for lst {                   // (9)
        print("List item % is %\n", it_index, it);  // (10)
    }

    // Version (2):
    for_expansion :: (list: *LinkedList, body: Code, flags: For_Flags) #expand {  
        `it := list;        
        `it_index := 0;
        while it {            
            #insert body;       
            it = it.next;
            it_index += 1;   
        }
    }

    for lst {                   
        print("List item % is %\n", it_index, it.data);  // (11)
    }

// List printed in a for loop:
// The lists starts with a 0
// List item 0 is 12
// List item 1 is 24
// List item 2 is 36

    free(a); free(b); free(c); free(lst);
}
```

We take the linked-list example from § 12.6, the same struct ListNode and *ListNode variable lst.  
A for-expansion macro is a special kind of macro that uses `i` as counter and `iter` as iteration variable (defined in line (2)).
The macro is defined in line (1) with the signature:  
`for_expansion :: (list: *ListNode, body: Code, flags: For_Flags) #expand`   
`for_expansion` takes in three parameters: a pointer to the data structure one wants to use the for loop on, a `Code` datatype, and a `For_Flags` flags.
It uses the same while loop as in § 15.1.3. Line (4) assures we break out of the loop if iter gets the null value: break when iter is empty (if this would not be here, the program would crash, try it out!).     
Because we emulate a for-loop, we must give values for the variables  
`it_index`  : which is of course the counter `i` (line (6))
and `it`    : which is `iter.data` (line (5))
They both have to be prefixed with a back-tick, because they are outer variables to the macro.  

The `#insert body;` in line (7) is responsible for printing out the data. `body` is the 2nd argument, and is of type Code. `body` denotes the body of the for-loop, and it is substituted into the expanded code. Its content is the `print` statement in line (10). So `#insert` is used inside macros to insert code in the expansion.  
(There is also a variant directive **#insert,scope()**, which allows you to insert code in the macro itself. A macro often takes an argument suitably named `body: Code`, which is then used to insert in the expansion: `#insert body`.)

The `For_Flags` enum_flags is found in module *Preload_.jai* with the following definition:
```c++
For_Flags :: enum_flags u32 {
  POINTER :: 0x1; // this for-loop is done by pointer.
  REVERSE :: 0x2; // this for-loop is a reverse for loop.
}
```
Line (8) simply increments our counter variable `i`.  
Now we can print out the data from a linked list in a for-loop like any other array (see line (9))!

But we can do better! (see for_expansion macro Version 2). Just leave out the temporary variables `iter` and `i` and work only with it and it_index. Also note you only have to backtick the variables the first time you use these. Note that in our actual `for call, we have to print `it.data`.

> Remark: the `for_expansion` may have any other name like `looping`, so that you can define different for_expansions. It is called like this:
> `for :looping v, n: data_structure`
> Also it and it_index can be renamed, like this: 
> `for :looping v, n: data_structure  print("[%] %\n", n, v);`
> When you have several for_expansions looping1, looping2 and so on, you could have:
> `for :looping1 v, n: data_structure`
> `for :looping2 v, n: data_structure`
> Our code would then become:
See *26.8B_linked_list_for_expansion.jai*:
```c++
#import "Basic";

LinkedList :: struct {
    data: s64; 
    next:  *LinkedList;
}

main :: () {
    lst := New(LinkedList); // lst is of type *LinkedList
    lst.data = 0;

    a :=  New(LinkedList); 
    a.data = 12;
    lst.next = a;
    
    b  := New(LinkedList);
    b.data = 24;
    a.next = b;
    
    c  := New(LinkedList);
    c.data = 36;
    b.next = c;

    c.next = null; 

    print("List printed in a for loop: \n");
    print("The list starts with a %\n", lst.data);

    looping :: (list: *LinkedList, body: Code, flags: For_Flags) #expand {  
        `it := list;        
        `it_index := 0;
        while it {            
            #insert body;       
            it = it.next;
            it_index += 1;   
        }
    }

    for :looping lst {                   
        print("List item % is %\n", it_index, it.data);  
    }

    print("\n");

    for :looping v, n: lst {                   
        print("List item % is %\n", n, v.data);  
    }

// List printed in a for loop: 
// The list starts with a 0
// List item 0 is 0
// List item 1 is 12
// List item 2 is 24
// List item 3 is 36
//
// List item 0 is 0
// List item 1 is 12
// List item 2 is 24
// List item 3 is 36

    free(a); free(b); free(c); free(lst);
}
```
> Remark: iterating over data-structures with for was the primary reason for introducing macros in Jai.

Now let's make the same for-loop for a double linked-list:

## 26.7 A for-expansion macro for a double linked-list
Let's now define a more general linked list as having a first and a last Node (see line (1)), whereby Node is recursively defined(see line (2)) as having a value, a previous and a next Node. Another advantage is that the type of the value (and Node) is polymorph written as T.

See *26.9_doubly_linked_list.jai*:
```c++
#import "Basic";
// Debug :: #import "Debug";

LinkedList :: struct (T: Type) {  // (1)
    first: *Node(T); 
    last:  *Node(T);
}

Node :: struct (T: Type) {          // (2)
    value: T;
    prev: *Node(T);
    next: *Node(T);
}

// Version 1:
for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {  
    iter := list.first;     
    i := 0;
    // Debug.breakpoint();
    while iter {            
        `it := iter.value;   
        `it_index := i;      
        iter = iter.next;
        #insert body;        
        if !iter break;    
        i += 1;             
    }
}

// Version 2:
for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {  
    `it := list.first;     
    `it_index := 0;
    while it {            
        #insert body;        
        it = it.next;
        it_index += 1;             
    }
}

// Version 3A:
for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {
    `it := ifx flags == For_Flags.REVERSE   list.last   else    list.first;  // (6)
    `it_index := ifx flags == For_Flags.REVERSE  2  else    0; ;   
    while it {            
        #insert body;
        if flags == For_Flags.REVERSE  { 
            it = it.prev;
            it_index -= 1; 
        } else          {  
            it = it.next;
            it_index += 1;   
        }        
    }
}

main :: () {
    // Debug.init();
    // Debug.attach_to_debugger();
    a : Node(int);      // (3)
    b : Node(int);
    c : Node(int);
    a.value = 10;
    b.value = 20;
    c.value = 30;
    a.next = *b;
    b.prev = *a;
    b.next = *c;
    c.prev = *b;

    list: LinkedList(int);
    list.first = *a;
    list.last = *c;

    print("List printed in a for loop: \n");
   
    for list {                     // (4) 
        print("List item % is %\n", it_index, << it);      
    }
    print("\n");
    
    for < list {                   // (5) 
        print("List item % is %\n", it_index, << it);      
    }

    free(*a); free(*b); free(*c); free(*list);
}

/* Version 1:
List printed in a for loop: 
List item 0 is 10
List item 1 is 20
List item 2 is 30
*/

/* Version 2:
List printed in a for loop: 
List item 0 is {10, null, 9c_e92f_f990}
List item 1 is {20, 9c_e92f_f9a8, 9c_e92f_f978}
List item 2 is {30, 9c_e92f_f990, null}
*/

/* Version 3A:
List item 2 is {30, d5_6fd4_fcb0, null}
List item 1 is {20, d5_6fd4_fcc8, d5_6fd4_fc98}
List item 0 is {10, null, d5_6fd4_fcb0}
*/
```

In lines (3) and following we define three Nodes a, b and c, give them values, link them together, and then link a LinkedList lst to them. We don't use New, so these Nodes are stack-allocated. 
Now we want to be able to write a for-loop like the one in (9), printing out the node position and its value. If we compile this, we get the `Error: Undeclared identifier 'for_expansion'`. So Jai tells us we need to write a for_expansion macro to accomplish this.  
This can be done with almost exactly the same code as in example 26.8 (because of the different structure, we need to move our break statement). The loop starting in (4) iterates over all the nodes.  
This example also shows that the for_expansion macro can be outside of main(). In fact, you could make a module for it and import that!
If you want to experience how easy it is to debug a macro, just uncomment the lines that start with // Debug, and debug until you reach the break when `iter` has become a pointer with value null (here this is the case for c.next).  

But we can do better! (see for_expansion macro Version 2). Just leave out the temporary variables `iter` and `i` and work only with it and it_index. Also note you only have to backtick the variables the first time you use these. Version 2 also prints out the pointers, so we see that a has a prev which is null, and c has a next that is null.

Suppose we want to print out list backwards, like in line (5):  `for < list`
Then we need `For_flags`, this is an enum defined in module _Preload_ with 2 possible values, POINTER (1) and REVERSE(2). This is done in Version 3A:
We test on For_Flags.REVERSE to either start with list.first or list.last. Using ifx, we can assign the if or else value to \`it. (But we don't know the nodes count, so we hardcoded the last position as 2). We do the same in the while loop, going to next or prev and incrementing or decrementing `it_index`. With version 3A there is one compiled version for the normal for and the for <.

**Exercise**
Use #if instead of ifx  (see for_expansion_version3B.jai) so that you get 2 different compiled versions, one for the for, and one for the reversed for (<).
How many compiled versions do you have when using if instead of #ifx? 

See also [Named Custom for Expansion](https://jai.community/docs?topic=176) for an example of a for_expansion for a Tree structure.

## 26.8 A for-expansion macro for an array
This seems totally unnecessary, because a for-loop is built-in for arrays! But it could be useful in case the for-loop has to do something additional, in which case it is beneficial to define it in one place as a for_expansion macro, instead of writing the addition in every for loop on your array.

See *26.34_abstracting_loop.jai*:
```c++
#import "Basic";

Player :: struct {
    name: string;
    score: u8;
}

players: [..]Player;

for_expansion :: (_: *type_of(players), body: Code,   // (1)
                  flags: For_Flags) #expand {
    for `it, `it_index: players {
        print("inside macro! \n");
        if it_index >= players.count  break;
        #insert body;
    }
}

player_loop :: (_: *type_of(players), body: Code,      // (2)
                  flags: For_Flags) #expand {
    for `it, `it_index: players {
        print("inside macro player_loop! \n");
        if it_index >= players.count  break;
        #insert body;
    }
}

main :: () {
    p1 := Player.{"Jane", 82};
    p2 := Player.{"John", 75};
    array_add(*players, p1);
    array_add(*players, p2);
    for players     print("Player no % is %\n", it_index, it);   // (3)
    /*
    Player no 0 is {"Jane", 82}
    Player no 1 is {"John", 75}
    */

    for player: players {                                        // (4)
        print("Player is %\n", player);
    }
    /*
    Player is {"Jane", 82}
    Player is {"John", 75}
    */

    // This uses the for_expansion macro
    for :for_expansion   player: players {                         // (5)
         print("Player is %\n", player);
    }
    /*
    inside macro!
    Player is {"Jane", 82}
    inside macro!
    Player is {"John", 75}
    */

     // This uses the player_loop macro
    for :player_loop   player, ix: players {                       // (6)
         print("Player % is %\n", ix, player);
    }
    /*
    inside macro player_loop!
    Player 0 is {"Jane", 82}
    inside macro player_loop!
    Player 1 is {"John", 75}
    */
}

```

In the code above we have an array `players` of type `Player`. In lines (3) and (4) we call familiar for-loops on this array. In line (1) we have defined a for_expansion macro, that does something additional (printing, logging, checking, and so on). To call it, we have to write:  
` for :for_expansion {}`  
as in line (5).  
We can of course give it another name like `player_loop`, and/or use the index besides the value, and/or make different for_expansion routines. This we can write like in line (6):  
` for :player_loop   player, ix: players {}`

## 26.9 The #modify directive
The **#modify** directive can be used to insert some code between the header and body of a procedure or struct, to change the values of the polymorph variables, or to reject the polymorph for some types or combination of variables. #modify allows to inspect generic parameter types. It is a block of code that is executed at compile-time each time a call to that procedure is resolved. 
1) the polymorph types (T, and so on) are resolved by matching.  
2) then the body of the #modify is run. In there, the value of T is not constant; it can be changed to whatever you want.   
3) then #modify returns a bool value:
> true: this signals that $T is a type that is accepted at compile-time: the proc will compile with that type, or the struct is defined.
> false: it generates a compile-time error: the proc will not compile, or the struct is not defined.

Here are a number of examples:
(Some are taken from howto/170_modify)

(1) Suppose we want to force a polymorph type to be a certain concrete type:
See *26.16_modify1.jai*:
```c++
#import "Basic";

proc1 :: (a : $T)    // (1)
#modify {
    T = s64;         // (3)
    return true;
}
{
    print("a is %, of type %\n", a, T);
}

main :: () {
    var_s8  : s8  = 1;
    var_s16 : s16 = 2;
    var_u32 : u32 = 3;
    var_s64 : s64 = 4;

    proc1(var_s8);   // (2) => a is 1, of type s64
    proc1(var_s16);  // => a is 2, of type s64
    proc1(var_u32);  // => a is 3, of type s64
    proc1(var_s64);  // => a is 4, of type s64

    var_bool: bool = true;
    // proc1(var_bool);  // (4) Error: Type mismatch. Type wanted: int; type given: bool.
    proc1(xx var_bool);  // (5) => a is 1, of type s64
}
```

`proc1` defined in line (1) has a generic type T. When it is called, for example in lines (2) and following, T is resolved respectively to s8, s16, u32 and s64. But before proc1's body is compiled, the body of #modify runs. In it (line (3)), we see that T is set to s64, and true is returned, so proc1 can be compiled for T == s64. When it runs, we see that the type is s64.  
Converting these types to s64 works implicitly. But what if it does not convert, like for a bool in line (4)? We get a compile error. However, you can put an auto-cast xx on the argument to make it work (see (5)).

(2) Here is an example with multiple generic types, showing how they can be compared and changed:
```c++
proc2 :: (a: $A, b: $B, c: $C) 
#modify {
    if B == A then B = C;
    return true;
}
{ proc body }
```

(3) The following example shows how #modify can call a procedure, that has to have this signature: take the polymorph type(s) as parameters and return a bool. It checks whether the resolved type T is an integer, enum or pointer. Only then can `proc` be completely compiled.  

See *26.17_modify2.jai*:
```c++
#import "Basic";

do_something :: (T: Type) -> bool {
    t := cast(*Type_Info) T;  
    if t.type == .INTEGER  return true;
    if t.type == .ENUM     return true;
    if t.type == .POINTER  return true;
    return false;
}

proc :: (dest: *$T, value: T)
#modify { return do_something(T); }
{     
    dest := value;
    print("dest is %", dest); // => dest is 42
}

main :: () {
    a : *int;
    proc(a, 42);   
}
```

(3B) The next example shows how to require a polymorphic function to take parameters of a specific type. 

See *26.32_modify_require.jai*:
```c++
#import "Basic";

ModifyRequire :: (t: Type, kind: Type_Info_Tag) #expand {   // (1)
    `return (cast(*Type_Info)t).type == kind, tprint("T must be %", kind);
}

poly_proc :: (t: $T) #modify ModifyRequire(T, .ENUM) {}     // (2)

SomeEnum :: enum {
    ASD;
    DEF;
}

main :: () {
    poly_proc(SomeEnum.ASD);  // (3)
    // poly_proc(123); // (4)  Compile `Error: #modify returned false: T must be ENUM`
}
```

`poly_proc` defined in line (2) calls in #modify the routine `ModifyRequire`. This is a macro, defined in line (1). The 1st parameter returned is the boolean condition, the 2nd is a message to be displayed when #modify returns false, as is the case in line (4). Line (3) passes an enum, which is ok.

(4) In this example we define a struct `Holder` with parameters that holds an array of size N of items of type T. But we don't want the size N to be smaller than 8, we can control this in the #modify:

See *26.18_modify3.jai*:
```c++
#import "Basic";

Holder :: struct (N: int, T: Type)
#modify { if N < 8 N = 8;  return true; }
{
    values: [N] T;
}

main :: () {
    a: Holder(9, float);
    b: Holder(3, float);
    print("b is %\n", b); // => b is {[0, 0, 0, 0, 0, 0, 0, 0]}
    assert(b.N >= 8); 
}
```

(5) In this example we are going to add all items of numeric type arrays (see line (2) and following) with the `sum` proc, defined in line (1).

See *26.19_modify4.jai*:
```c++
#import "Basic";

sum :: (array: [] $T) -> T {        // (1)
    result: T;
    for array  result += it;
    return result;
}

sum2 :: (a : [] $T) -> $R           // (4)
#modify {
    R = T;                          // (5)
    ti := cast(*Type_Info) T;       // (6)
    if ti.type == .INTEGER {        // (7)
        info := cast(*Type_Info_Integer) T; // (8)
        if info.runtime_size < 4 {  // (9)
            if info.signed R = s32; // (10) 
            else           R = u32;
        }
    }
    return true;
}
{ 
    result : R = 0;
    for a result += it;
    return result;
}

main :: () {
    floats := float.[1, 4, 9, 16, 25, 36, 49, 64, 81];  // (2)
    ints   := int  .[1, 4, 9, 16, 25, 36, 49, 64, 81];
    u8s    := u8   .[1, 4, 9, 16, 25, 36, 49, 64, 81];

    print("sum of floats is %\n", sum(floats)); // => sum of floats is 285
    print("sum of ints   is %\n", sum(ints));   // => sum of ints is 285
    print("sum of u8s    is %\n", sum(u8s));       // (3) => sum of u8s is 29

    print("sum2 of u8s %\n", sum2(u8s));    // (11) => sum2 of u8s 285
}
```

We see in line (3) that there is an overflow problem with the u8 array (285 doesn't fit into a u8).  
The problem can be solved by we using #modify to generate a return type that is reasonably big if our input type is small, otherwise it leaves the return type the same as the input type. This is done in `sum2`:  
- The return type is now R, by default returning T (line (5)), but it can be different. To examine T, we do a cast(*Type_Info) in (6). Then in (7) we get its type and see if it is an integer. If so, we do a `cast(*Type_Info_Integer)` in (8) to get more info, here the runtime_size in (9). If this is smaller than 4 bytes (for example for u8 here), we set R to a 4 byte type s32 or u32 in line (10), depending on whether it is signed or not. Now we get the correct result: see line (11).  We needed #modify here to give R a value.

(6) Here is a #modify within which every numeric type is converted to a 64 bit type:

```c++
#modify {
if T == {
    case s8;  T = s64;
    case s16; T = s64;
    case s32; T = s64;
    case s64; // No change!
    
    case u8;  T = u64;
    case u16; T = u64;
    case u32; T = u64;
    case u64; // No change!
    
    case float32; T = float64;
    case float64; // No change!
    
    case; return false, "Unsupported argument type to multiply_add.";
    }
return true;
}
```
Note how you can append an error message string to the return false case. It will appear like this: `Error: #modify returned false: Unsupported argument type to multiply_add.`

(7) Here is an example where a polymorph struct is rejected based on a constraint between multiple variables:

See *26.20_modify5.jai*:
```c++
#import "Basic";

Bitmap :: struct (Width: s16, Height: s16)
#modify { return Width >= Height, "Width of a Bitmap must be >= Height."; }
{
    pixels: [Width*Height] u32;
}

main :: () {
    monster: Bitmap(128, 64); // valid Bitmap
    // gateway: Bitmap(512, 1024); // Error: #modify returned false: Width of a Bitmap must be >= Height.
}
```

A Bitmap struct instance is only valid when Width >= Height.

**Exercises using #modify**
(1) Make the call to random() work in Example 2 of _23.7_bake_constants.jai_, by specifying that T is s32 (see random_return_type.jai)
(2) Write a proc `square` that squares a variable of a numeric type, but rejects any other type (see square_modify.jai)
(3) Write a proc `struct_work` which only accepts a struct as type T when its name starts with "XYZ" (see struct_work.jai)

## 26.10 SOA (Struct of Arrays)

SOA is a special kind of data-design, which makes memory-use much faster, and so enhances performance.
It is done at compile-time using `#insert`. This mechanism automatically converts between SOA (Structure of Arrays) and AOS (Array of Structures), without breaking the supporting code. This means a completely different memory access pattern, and it allows for quickly changing data layouts with minor code edits.

### 26.10.1 Data-oriented design
Jai provides built-in support for data-oriented development: it’s a high-level language build for fast memory support. Good memory layout is important because if it is not well done, too many memory cache misses will occur, alongside too much allocator overhead. Moreover consoles and mobile devices tend to have more limited memory constraints. Jai helps you to set up things in memory the way you want, without loss of efficiency or high-level expressiveness.

### 26.10.2 Making a SOA struct using #insert
For some arrays we can get much better cache performance by changing the order of data. C++ encourages the use of arrays of structures (AOS), but most CPUs work faster when data is laid oud as structures of arrays (SOA). Object-oriented languages prefer AOS, but a data-oriented language should make it easy to lay out your data in SOA format.
With SOA, arrays are contiguous in memory, and even their member values are contiguous, instead of being scattered on the heap.  
For example: updating a set of arrays usually happens coordinate by coordinate, first all x coordinates, and so on. Because in the SOA structure all the vector coordinates are adjacent to each other in memory, updates on them are very fast. This is in contrast with an AOS structure, where updates will have to jump over memory all the time.  
> There are two different ways of storing data here:
> Array of Structs:(AOS)  A list of objects (like marines) where objects are stored one after another.
> Struct of Arrays: (SOA) An object that contains lists of fields, so similar fields are stored together.  
> 
This is marvelously explained in the following article [SOA vs AOS](https://www.shamusyoung.com/twentysidedtale/?p=48683), which is part of a brilliant series of articles about game programming.

Suppose our program works with `Vec3 :: { x: float, y: float, z: float }` (defined in module _Math_).
An AOS with Vec3's would be like `[vec31, vec32, vec33, vec34, vec35]`, where vec31: Vec3, and so on, so basically: `[{x1, y1, z1}, {x2, y2, z2}, {x3, y3, z3}, {x4, y4, z4}, {x5, y5, z5}]`  
An SOA Vec3 struct would be like:  
```c++
    SOA_Vec3 :: struct {
       x: [5] float;
       y: [5] float;
       z: [5] float;
     }
```
Accessing all x's and so on will be much faster in the SOA configuration.

Now we discuss an example of how SOA is implemented in Jai as a polymorphic struct with #insert.

See *26.10_soa.jai*:
```c++
#import "Basic";

Person :: struct {                      // (1)
  name: string;
  age: int;
  is_cool: bool;
}

SOA :: struct(T: Type, count: int) {    // (2)
  #insert -> string {                   // (3)
    builder: String_Builder;            // (4)
    defer free_buffers(*builder);
    t_info := type_info(T);             // (5)
    for fields: t_info.members {        // (6)
      print_to_builder(*builder, "  %1: [%2] type_of(T.%1);\n", fields.name, count);  // (7)
    }
    result := builder_to_string(*builder);  // (8)
    return result;
  }
}

main :: () {
  soa_person: SOA(Person, 5);       // (9)
  print("soa_person is: %\n", soa_person);
  for i: 0..soa_person.count-1 {    // (10)
    print("Person[%]: name= %, age= %, is_cool= %\n", i, soa_person.name[i], soa_person.age[i], soa_person.is_cool[i]);
  } // => see in /* */ after program
  print("soa_person is: %\n", soa_person);
  // => soa_person is: {["", "", "", "", ""], [0, 0, 0, 0, 0], [false, false, false, false, false]}

  // an aos example:
  // if you do: arrp := Person.[p1, p2, p3, p4, p5] , with for example: p1 := Person.{"Ivo", 66, true};
  // => Error: Attempt to use a non-literal element inside an array literal! (At index 4.)
  arrp := Person.[Person.{"Ivo", 66, true}, Person.{"Dolf", 42, false}, Person.{"Laura", 28, true}, 
                Person.{"Gabriel", 30, true}, Person.{"Denise", 63, false}];   // (11)
  // how to transform aos to soa: arrp --> soa_person
  for arrp {       // (12)
    soa_person.name[it_index] = it.name;
    soa_person.age[it_index] = it.age;
    soa_person.is_cool[it_index] = it.is_cool;
  }
  print("soa_person is: %", soa_person);  
  // => soa_person is: {["Ivo", "Dolf", "Laura", "Gabriel", "Denise"], [66, 42, 28, 30, 63], 
  //                    [true, false, true, true, false]}
}

/*
Person[0]: name= , age= 0, is_cool= false
Person[1]: name= , age= 0, is_cool= false
Person[2]: name= , age= 0, is_cool= false
Person[3]: name= , age= 0, is_cool= false
Person[4]: name= , age= 0, is_cool= false
*/
```

In line (1) we have a Person struct definition, and in line (2) we have the definition of the **SOA struct**. This takes a polymorphic type T, and an integer count, which is the number of objects.  
The #insert starts building  a string in line (3):  `#insert -> string { // building string }`  
In line (4) we define a string builder in which we'll construct our string (we immediately take care of its memory release). In line (5) we extract the type_info from our type T (see § 15.5). Then we loop over all its member fields (line (6)), and use print_to_builder (see § 19.5) to serialize the info into a struct definition. We get a string from the builder in (8) and return that as the SOA struct.

This gets called in line (9):  `soa_person: SOA(Person, 5);`
where the new SOA type is constructed with T equal to type Person and count equal to 5 and zero-initialized data as shown by printing it out in a for-loop ().
`soa_person` looks internally like this:
```
    soa_person {
        name[5];
        age[5];
        is_cool[5];
    }
```
**How to transform an AOS to an SOA?**
In line (11) we define an array of Person objects. Line (12) shows that only a simple for loop over the AOS is needed to transfer the data to an SOA.

> Remark: Other references (videos on youtube):
    • Noel Llopis: Data-oriented design
    • Chandler Carruth: Efficiency with Algorithms, Performance with Data Structures
    • Mike Acton: Data-oriented design in C++


## 26.11 How to get the generated source files after the meta-program step?
The piece of source code that gets generated from a #insert can be retrieved from the hidden _.build_ folder. For example: program 26.10_soa.jai generates an additional source file called `.added_strings_w2.jai` in .build with this content:
```c++
// Workspace: Target Program
//
// #insert text. Generated from d:/Jai/The_Way_to_Jai/examples/26/26.10_soa.jai:10.
//
  name: [5] type_of(T.name);
  age: [5] type_of(T.age);
  is_cool: [5] type_of(T.is_cool);
```

Line (10) mentioned here is this line: #insert -> string.

## 26.12 How to get info on the nodes tree of a piece of code?
In § 26.4.1 we saw how #code can make something of type Code out of a piece of code. Another way is to call the proc `code_of` on a piece of code. For some examples of code_of, see jai/examples/here_string_detector.jai and self_inspect.jai  
The helper procedure `compiler_get_nodes` can take the result of `#code` or `code_of` and get the AST nodes out of it:
```
compiler_get_nodes :: (code: Code) -> (root: *Code_Node, expressions: [] *Code_Node) #compiler;
```

(`Code_Node` is a struct defined in module _Compiler_)
In the program below we analyze the nodes of the statement: `code :: #code a := Vector3.{1,2,3};`

See *26.11_code_nodes.jai*:
```c++
# import "Basic";
# import "Compiler";
# import "Program_Print";                   // (1)

code :: #code a := Vector3.{1,2,3};

#run {
    builder: String_Builder;
    root, exprs := compiler_get_nodes(code);  // (2)
    print_expression(*builder, root);         // (3)
    s := builder_to_string(*builder);
    print("The code is: %\n", s);
    print("Here are the types of all expressions in this syntax tree:\n");
    for expr, i: exprs {                      // (4)
        print("[%] % %\n", i, expr.kind, expr.node_flags);
    }
}

main :: () {}

/* => during compile-time
The code is: a := Vector3.{1, 2, 3}
Here are the types of all expressions in this syntax tree:
[0] IDENT 0
[1] TYPE_INSTANTIATION 0
[2] LITERAL 0
[3] LITERAL 0
[4] LITERAL 0
[5] LITERAL 0
[6] DECLARATION ALLOWED_BY_CONTEXT
*/
```

To print out the nodes, we need to import the module _Program_Print_ (line (1)). We call `compiler_get_nodes` on our code statement in line (2), to get the root node and the exprs. `print_expression` 'prints' the code to a String Builder (line (3)). In line (4) we can now iterate over `exprs` to show the `kind` of each sub-expression and their `node_flags` if any.

`compiler_get_nodes` converts the Code to a syntax tree. As we see in line (2), it returns two values:  
- the first is the root expression of the Code, which you can navigate recursively.   
- the second is a flattened array of all expressions at all levels, just like you would get in a metaprogram inside a Code_Typechecked message. This makes it easy to iterate over all the expressions looking for what you want, without having to do some kind of recursive tree navigation.  
- Here is a snippet of code that searches for string literals in code, (possibly) changing them, and writing the changes back with the proc `compiler_get_code`:
```c++
root, expressions := compiler_get_nodes(code);
for expressions {
    if it.kind != .LITERAL continue;  
    literal := cast(*Code_Literal) it;
    if literal.value_type != .STRING continue;  
    // do something with literal._string
    // literal._string = ...
}
modified := compiler_get_code(root);
```
(for a complete working example, see how_to/630, 2nd example)

## 26.13 The #type directive and type variants
This directive tells the compiler that the next following syntax is a type literal, useful for defining procedure types and variant types. Variant types are like alias types (see § 9.1), but differ in the casting behavior.

For example:
```c++
IL_LoggingLevel :: u16;
IL_Logger_Callback :: #type(level: IL_LoggingLevel, text: *u8, ctx: *void) -> void #c_call;
```
The code above defines the procedure `IL_Logger_Callback` as a proc with as type the given signature.

#type is useful for resolving ambiguous type grammar, for example the following declaration does not compile: `proctest: Type : (s32) -> s32;`
but adding #type it does:     `proctest: Type : #type (s32) -> s32;`
  
It can also be used to define **type variants**, as in the following example, with syntax #type,distinct or #type,isa:

See *26.21_type_variants.jai*:
```c++
#import "Basic";
#import "Math";

Handle       :: #type,distinct u32;     // (1)
Filename     :: #type,isa string;       // (2A)
Velocity3    :: #type,isa Vector3;      // (2B)

main :: () {
    a: Handle = 5;      // (3)
    print("Math on a yields: %\n", 3 * a + 2);  // => Math on a yields: 17
    b: u32 = 42;
    // a = b;           // (3B) Error: Type mismatch. Type wanted: Handle; type given: u32.
    a = cast(Handle) b; // (3C) 
    a = xx (b + 1);     // (3D) 

    hi := type_info(Handle);
    print("%\n", hi);                    // (4) => Type
    ti := cast(*Type_Info) Handle;
    print("%\n", ti.type);               // (5) => VARIANT
    print("hi is %\n", <<hi.variant_of); // (5B) => hi is {INTEGER, 4}

    fn: Filename = "/home/var/usr/etc/dev/cake";
    f := type_info(Filename);
    print("f is %\n", <<f.variant_of); // (6) => f is {STRING, 16}

    va: Velocity3 = .{1,2,3};
    print("va has type %\n", type_of(va));  // => va has type Velocity3
    g := type_info(Velocity3);
    print("g is %\n", <<g.variant_of); // (7) => g is {STRUCT, 12}
}
```

Line (1) defines a distinct variant type Handle, which is a u32, but distinct from it. You can do numerical operations on variables of type Handle. Trying to assign (implicitly cast) a u32 variable to a Handle variable fails (see line 3B): this is type safety and that's why it is a distinct type. However, an explicit cast or an auto-cast as in lines (3C-D) works.  
The type of Handle is Type (see (4)), but if we dig deeper in line (5) we see that it is a VARIANT type, the item with value 18 from the Type_Info_Tag enum (see § 16.2).  
Another variant of the isa type is shown in lines (2A-B). These types will implicitly cast to their isa type, but variants with the same isa type will not implicitly cast to each other.
Taking type_info(), and dereferencing the `variant_of` field shows the underlying type and size (lines 5B, 6 and 7).

## 26.14 Getting the name of a variable at compile time
See *26.23_get_variable_name.jai*:
```c++
#import "Compiler";
#import "Program_Print";
#import "Basic";

get_variable_name :: (thing: int, call := #caller_code) -> string #expand {
    node := cast(*Code_Procedure_Call) compiler_get_nodes(call);
    builder: String_Builder;
    print_expression(*builder, node.arguments_unsorted[0].expression);
    return builder_to_string(*builder);
}

main :: () {
    a_constant :: 10;
    #run print("%", get_variable_name(a_constant)); // => a_constant
}
```

The directive **#caller_code** when used as the default
value of a macro argument, will be set to the Code of the procedure call
that invoked the macro.  
`compiler_get_nodes()` from module _Compiler_ can then be called on this code to inspect and manipulate it. `print_expression` from module _Program_Print_ `prints` the 2nd argument in a string-format to the string builder.
With these kinds of techniques you manipulate code from a macro within the program itself (see howto/497).
There is also a `print_type_to_builder` proc for printing type info to a string builder (see how_to/935).

## 26.15 Converting code to string
See _26.23_get_variable_name.jai_:
```c++
#import "Basic";

code_to_string :: (code: Code) -> string #expand {
  PP       :: #import "Program_Print";
  Compiler :: #import "Compiler";
  code_node := Compiler.compiler_get_nodes(code);
  builder: String_Builder;
  PP.print_expression(*builder, code_node);
  return builder_to_string(*builder, allocator=temp);
}

#run {
    code1 := #code a_constant :: 10;
    str := code_to_string(code1);
    print("This is the code: % of type: %\n", str, type_of(str) );
    // => This is the code:  a_constant :: 10 of type: string
}

main ::() {}
```

We again use compiler_get_nodes to get the AST, which is then `printed` to a string builder, and then converted to a string.

## 26.16 Creating code for each member in a structure
The following example is a quick (non recursive) helper to create some code for each member in a structure (it is derived and slightly changed from a Snippets example in the Jai Community Wiki): 

See *26.29_code_struct_member.jai*:
```c++
#import "Basic";

for_each_member :: ($T: Type, format: string) -> string
{
    builder: String_Builder;
    defer free_buffers(*builder);

    struct_info := cast(*Type_Info_Struct) T;
    assert(struct_info.type == Type_Info_Tag.STRUCT);

    for struct_info.members 
    {
        if it.flags & .CONSTANT continue;
        print_to_builder(*builder, format, it.name);
    }

    return builder_to_string(*builder);
}

serialize_structure :: (s: $T, builder: *String_Builder) -> success: bool
{
    #insert #run for_each_member(T, "if !serialize(s.%1, builder) return false;\n" );  // (1)
    // %1          = member name;  type_of(%1) = member type
    // The following code will be inserted before compiling (see .build/.added_strings_w2.jai)
    // if !serialize(s.status, builder) return false;
    // if !serialize(s.health, builder) return false;
    return true;
}

serialize  :: (to_serialize: $T, builder: *String_Builder) -> success: bool { 
    print_to_builder(builder, "%-", to_serialize);
    return true; 
} 

main :: ()
{
    Player :: struct
    {
        status: u16;
        health: int;
    }
    p := Player.{7, 75};
    
    builder: String_Builder;
    defer free_buffers(*builder);

    success := serialize_structure(p, *builder);
    if !success { 
        print("Serializing error");
        exit(-1);
    }
    str := builder_to_string(*builder);
    print("The result of serializing is: '%'.\n", str);
    // => The result of serializing is: '7-75-'.
}

// .build/.added_strings_w2.jai contains:
// Workspace: Target Program
//
// #insert text. Generated from d:/Jai/testing/test2.jai:25.
//
/*
if !serialize(s.status, builder) return false;
if !serialize(s.health, builder) return false;
*/
```

We want to store the field values of a (Player) struct in a string, possibly writing them to a file later on. 
All procedures in this example are polymorphic. In `serialize_structure` T becomes Player. In line (1) `for_each_member` is called before compiling and this inserts 2 lines of code (shown in .build/.added_strings_w2.jai):
```
if !serialize(s.status, builder) return false;
if !serialize(s.health, builder) return false;
```

`for_each_member` checks whether we have a struct, and then substitutes the field name into our format string, which goes into the string builder.
To compile this, a proc `serialize` has to exist, which is also polymorphic in our example and which writes the field's values in the string builder.

## 26.17 A type-tagged union
We discussed unions in § 13.2, where we saw that a union has only one field, but can take values of different types. It could be useful to know at any time which type the union value has. This could be done by enclosing the union within a struct, with a field containing the type.

See *26.31_tagged_union.jai*:
```c++
#import "Basic";

Tag_Union :: struct(fields: [] string, types: []Type) {
  tag: Type;
  #insert -> string {
    builder: String_Builder;
    defer free_buffers(*builder);
    count := fields.count - 1;
    print_to_builder(*builder, "union {\n");
    for i: 0..count {
      print_to_builder(*builder, "  %1: %2;\n", fields[i], types[i]);
 
    }
    print_to_builder(*builder, "}\n");
    result := builder_to_string(*builder);
    return result;
  }
}

set :: (u: *$Tag/Tag_Union, value: $T) {        
  #insert -> string {
    count := u.fields.count - 1;
    for i: 0..count {
      if T == Tag.types[i] {
        code :: #string END
           u.tag = type_of(value);
           u.% = value;
        END
        return sprint(code, Tag.fields[i]);
      }
    }
    assert(false, "Invalid value: %\n", T);
  }
}

main :: () {
    fields :: string.["int_a", "float_b", "string_c"];
    types  :: Type.[int, float, string];

    tag_union: Tag_Union(fields, types); // (1)
    print("tag_union = %\n", tag_union); // => tag_union = {(null), (union)}
    set(*tag_union, 10);                 // (2A)
    print("tag_union = %\n", tag_union); // => tag_union = {s64, (union)}
    print("tag_union.int_a = % tag_union.tag = %\n", tag_union.int_a, tag_union.tag);

    set(*tag_union, 3.14);               // (2B)
    print("tag_union = %\n", tag_union); // => tag_union = {float32, (union)}
    print("tag_union.float_b = % tag_union.tag = %\n", tag_union.float_b, tag_union.tag);

    set(*tag_union, "James Bond");       // (2C)
    print("tag_union = %\n", tag_union); // => tag_union = {string, (union)}
    print("tag_union.string_c = % tag_union.tag = %\n", tag_union.string_c, tag_union.tag);

    // set(*tag_union, true);               // (2D)
    // => Assertion failed: Invalid value: bool
}

/*
tag_union = {s64, (union)}
tag_union.int_a = 10 tag_union.tag = s64
tag_union = {float32, (union)}
tag_union.float_b = 3.14 tag_union.tag = float32
tag_union = {string, (union)}
tag_union.string_c = James Bond tag_union.tag = string
*/
```

In the above code a struct `Tag_Union` has a field `tag` that contains the current type, and struct parameters fields of type [] string and types of type []Type. The `fields` are the names of the possible union fields, and `types` are their corresponding types.  
The structs code is dynamically build with a `#insert -> string` using the structs parameters. You can find the code in .build/.added_strings_w2.jai:  
```
union {
  int_a: s64;
  float_b: float32;
  string_c: string;
}
```
`tag_union` is an instance of the struct. At its declaration in line (1), the parameters are passed and the structs definition is built. The `set :: (u: *$Tag/Tag_Union, value: $T)` proc changes the instance by supplying a value for the union. Its code also uses a `#insert -> string` which loops over the fields of the union. If the type of the supplied value matches one of the union types, that type is written to the `tag` field and the value is written to the union's field. The `/Tag_Union` in set's declaration checks that $Tag has the fields of Tag_Union (see § 23.6).
In line (2A), the `set` function is called with value 10, so tag becomes s64 and the int_a field becomes 10; the same goes for lines (2B-C).
If the type of the supplied value is not present in the types array, we get a compile-time error like: `Assertion failed: Invalid value: bool` (see line (2D)).