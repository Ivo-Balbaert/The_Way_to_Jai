# 26 Metaprogramming

A 'meta-program' is a piece of code that alters (or 'programs') an existing program (another piece of code).
In Jai, this takes place solely at compile-time. The compiler gives you the source code in AST format (Abstract Syntax Tree) for you to modify.

> Jai offers arbitrary compile-time execution, with powerful meta-programming features to modify your code in whatever way you want, but all meta-programming is limited strictly to compile-time execution. This capability is one of the main pillars of the language.
> One could even argue that Jai introduces another programming paradigm: "Meta-programming oriented programming" or "Compiler oriented programming".
> In short it's about maximizing code generation at compile time with a nice tool-set: macros, types as first class values, polymorphic procedures and data structures, built-in build system, understanding of AST and so on.

This functionality has been built into the language from the start. Meta-programs can modify the program in arbitrarily complex ways easily. 

In order to do meta-programming, full type-information is needed. Jai has that available at compile-time (see § 5.1.4, § 9, § 16),  but also retains static type information for every structure available at runtime (see § 26.1).
In § 13.6 and § 15.4 we discussed some useful reflection methods for enums. In § 15.5 we highlighted useful reflection methods for structs, useful for serialization (see § 15.6).

Using type info to meta-program is also called _reflection_ or _introspection_ in other languages.

We already talked about running code at compile time as early as § 3.2.4. Jai provides full compile-time code execution, meaning that all Jai code can also be executed while compiling.

> Because all of this processing happens at compile-time, there is a natural overlap between this chapter and § 30.

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

    // PIA2 :: compute_pi(); // (3B) Error: Declaration claims to be 
    // constant, but uses an expression that is not constant.
    PIA2 := compute_pi();

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
    // v2 = .{sin(TAU * .5), 1, 0}; // Error: All values provided in a struct literal must 
    // be constant, but argument 1 is not.
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
Line (2) runs a proc and assigns its return value to a variable `result`, so that when the program really starts to run, `result` starts off with the assigned value.  
This way we can run an expensive proc at compile-time, so that its result can be used in run-time.  

A more concrete example of this is presented in line (3), where the value of the constant PI is being calculated at compile-time. Notice the error for line (3B): a constant cannot be calculated by a proc, but of course PIA2 := compute_pi(); is ok.   
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
The three lines following (3) only activate the #run 1 time, because all expressions with which it is called are of the same type u8. It only needs to build once. But at runtime the procedure is called and prints out 3 times.In line (4), comprun is called with a new type 'float', so it compiles again, which we can see because #run executes for the 2nd time.  
Line (5) doesn't trigger a re-compilation, because the parameter is also of type float. But line (6) re-compiles, because now a string is passed. (7) doesn't recompile, because there is already a compiled form for comprun with T == u8.
Note that the order of the #run's can vary, because compilation works multi-threaded.

#run can also return basic struct values or multidimensional arrays. Complications can arise because of pointers inside structs, and values that are not retained between compile-time and run-time. In order to modify more complex data structures with #run, the #no_reset directive can be useful (see § 26.2.2).

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

#compile_time is true when doing #run, comment this out to see it becoming false.
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
> If the condition that follows is false:
> if will not execute the block  
> #if will not compile the block

Caution: there is no #else, just use else.  
For one-liners, there is #ifx (see line (7)).

Using this feature, code can be conditionally compiled and included in the resulting executable, depending on the target environment (development, test, release) or target platform (different OS's).

Here is a way to use it in debugging to print out info you want to inspect; in production this code will not be compiled, only the else branch:
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

The same idea works for importing modules, for example:  
```c++
#import "Basic";
#import "Compiler";
#import "String";
#import "Process";
#import "File_Utilities";
#import "File";

#if OS == .WINDOWS {
    Windows_Resources :: #import "Windows_Resources";
    Ico_File :: #import "Ico_File";
}

#if OS == .MACOS {
    Bundler :: #import "MacOS_Bundler";
}
```

See also jai\examples\system_info for how to display info of your OS and the hardware on which it runs.

## 26.4 Inserting code with #insert
The **#insert** directive lets you insert code. It inserts a piece of compile-time generated code represented as a string (or code that has been represented as data in some other way) into a procedure or a struct.

### 26.4.1 Inserting code strings with #insert
See *26.6_insert.jai*:
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

This is illustrated in line (1): there `#insert` takes a string containing a line of code, and inserts it as code at that location in the source. Line (2) shows that it also can be used at an expression level.  Line (3) shows how a multi-line string can be inserted as a piece of code.  
And of course the string that you #insert is checked that it is valid Jai code while compiling.

### 26.4.2 Inserting compile-time generated strings with #insert
Now we are going to combine #insert with #run:

See *26.35_insert_string_from_proc.jai*:
```c++
#import "Basic";

// helper proc to generate a string that represents code
gen_code :: (v: int) -> string {
  // compile-time string alloc and format!
  return tprint("x *= %;", v);
}

factorial :: (x: int) -> int {
  if x <= 1 return 1;
  return x * factorial(x-1);
}

main :: () {
    x := 3;
    #insert "x *= 3;";          // (1)
    print("%\n", x); // => 9

    // generate and insert x *= 3;
    #insert #run gen_code(3);   // (2)
    print("%\n", x); // prints 27

    // compile-time run factorial(3) to produce 6
    // insert code x *= 6
    #insert #run gen_code(factorial(3));
    print("%\n", x); // print 54
}
```

In line (1) we just insert the statement `x *= 3;`.
In line (2) we do the same, but now the string used by #insert is generated by the helper procedure `gen_code`.    
Then we let a call to factorial(3) supply the argument for `gen_code`.  
So at compile-time we can execute arbitrary Jai code that generates and inserts strings!

### 26.4.3 Using #insert with multi-line strings
Here is a more useful example, where #insert is used with multi-line strings:  
See *26.24_insert_multi.jai*:
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

### 26.4.4 Using #insert -> string
Even the entire contents of a struct can be made through a `#insert -> string` construction. This takes the form:
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

See *26.25_insert_ident_matrix.jai*:
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

The code we write in the string might not be valid

### 26.4.5 Type Code and #code
Instead of using #insert with strings, we can also let it work directly with Code, which is better for type safety.  
A variable of type Code can be constructed by using the **#code** directive:  
`#code { // a code block }`, like `#code { x += 7 }`   
This can also be one line, as follows:  
`code :: #code a := Vector3.{1,2,3};`  
or:  
`#code (a < b)`  
All these expressions have type Code.
See an example of use in § 26.5.2

You can convert a #code during compile-time execution back-and-forth to the syntax tree structures (AST) defined in Compiler. Also you can take a Code, convert it to the tree, manipulate around with the tree, and resubmit the changed tree.

Here are some use-cases :
See *26.26_insert_code.jai*:
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
In line (0) we make a variable c of type Code with the same code. 
In the same way as you can do a #insert -> string (see previous §), you can make a `#insert -> Code {  return #code  ...   }` (see line (1)).
`#insert` can also take a variable c of type Code, e.g.: `#insert(c: Code);`.  

It is also often used in the body of a macro like this:  
```c++ 
some_macro :: (body: Code) #expand {
    ...
    #insert body;
    ...
}
```

In lines (3A-B) we call a proc `what_type` (defined in line (1)) with a constant Code argument. The $c ensures that it is constant (see § 22.6)
Making `what_type` a macro would also ensure that c is constant.  
For non-constant code arguments, you can use the proc `get_root_type` from the _Compiler_ module (see examples/code_type.jai).

(See also § 26.5 Macros, specifically `macroi` in the first example.)

## 26.5 The #modify directive
The **#modify** directive can be used to insert some code between the header and body of a procedure or struct, to change the values of the polymorph variables, or to reject the polymorph for some types or combination of variables. #modify allows to inspect generic parameter types. It is a block of code that is executed at compile-time each time a call to that procedure is resolved. 

It is executed following these steps:   
1) the polymorph types (T, and so on) are resolved by matching.  
2) then the body of the #modify is run. In there, the value of T is not constant; it can be changed to whatever you want.   
3) then #modify returns a bool value:
> true: this signals that $T is a type that is accepted at compile-time: the proc will compile with that type, or the struct is defined.  
> false: it generates a compile-time error: the proc will not compile, or the struct is not defined.

Here are a number of examples:
(Some are taken from how_to/170_modify)

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

(3B) The next example shows how to require a polymorphic procedure (which is also a macro) to take parameters of a specific type. 

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
#modify { if N < 8    N = 8;    return true; }
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
The problem can be solved by we using #modify to generate a return type that is reasonably big if our input type is small, otherwise it leaves the return type the same as the input type.  

This is done in `sum2`:    
The return type is now R, by default returning T (line (5)), but it can be different. To examine T, we do a cast(*Type_Info) in (6). Then in (7) we get its type and see if it is an integer. If so, we do a `cast(*Type_Info_Integer)` in (8) to get more info, here the runtime_size in (9).   
If this is smaller than 4 bytes (for example for u8 here), we set R to a 4 byte type s32 or u32 in line (10), depending on whether it is signed or not.  
Now we get the correct result: see line (11). We needed #modify here to give R a value.

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
(4) We have two overloads of a proc ``submit_data`:  
submit_data :: (data: $T)   
submit_data :: (data: [] $T)  
However because these are polymorphic, the compiler cannot decide when you have an array argument that it must take the 2nd version.  
You get the error (verify this):
Error: Procedure call matches multiple possible overloads:  
Write a #modify on the 1st version so that the compiler can  make the difference between the version of submit_data that accepts a T, and the one that accepts an [] T.
(see choose_array_overload.jai)


**Some wise words**
Excessive compile-time code is more complex and harder to understand. With great power comes great responsibility.