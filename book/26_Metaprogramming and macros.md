# 26 Meta-programming and macros

A 'meta-program' is a piece of code that alters (or 'programs') an existing program (another piece of code).
In Jai, this takes place solely at compile-time. The compiler gives you the source code in AST format (Abstract Syntax Tree) for you to modify.

> Jai offers arbitrary compile-time execution, with powerful meta-programming features to modify your code in whatever way you want, but all meta-programming is limited strictly to compile-time execution. This capability is one of the main pillars of the language.

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

(See also build option: `runtime_storageless_type_info`  in § 30.4.7 )

## 26.2 Running code at compile time with #run
We first discovered that this was possible in §3.2.4. We talked about the bytecode interpreter in § 4.2, saw how constants can be calculated at compile time in §5.2.2, and how this can be used for debugging purposes in § 20.  
We already know that we need to use `#run main()` to run the whole program at compile-time.
In fact, any code (a code-line, a block of code or a procedure) can be run at compile time with **#run**. 

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

main :: () {
    proc1();        // => This is proc1 :: () - proc1 is called at run-time

    print("result is %\n", result); // => result is 42   
    print("PIA is %\n", PI); // => PIA is 3.141699

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
Arrays are an exception to what we have seen in this section: when they get values at compile-time, these values are reset (initialized to zeros) before running the program.
This is shown in the following program:

See *26.4_no_reset.jai*:
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

See *26.5_if.jai*:
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

Caution: there is no #else, just use else.

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

See *26.6_insert.jai*:
```c++
#import "Basic";

main :: () {
    a := 1;
    b := 2;
    #insert "c := a + b;";   // (1)
    print("c is %\n", c); // => c is 3
}
```

The 1st way #insert can be used is illustrated in line (1): there `#insert` takes a string containing a line of code, and inserts it as code at that location in the source.  

2nd way: `#insert` can also take a variable c of type Code, e.g.: `#insert(c: Code);`. It is also often used in the body of a macro like this:  
```c++ 
some_macro :: (body: Code) #expand {
    ...
    #insert body;
    ...
}
```
(See § 26.5 Macros, specifically `macroi` in the first example.)

3rd way: Even the entire contents of a struct can be made through a `#insert -> string` construction. This takes the form:
```c++
A_Type :: struct( ... ) {
    #insert -> string { ... }
}
``` 
The `#insert -> string` is in fact a short (lambda) form for:  
`#insert #run () -> string {  ...  }();`
`() -> string` is the declaration of the lambda, { ... } is its code, and it is called with the last () pair like this: `{  ...  }()`
(This is applied in the unroll for loop in § 26.5.2, and in construction of a SOA struct, see § 26.9.2).
In the same way, you can make a `#insert -> Code {  return #code  ...   }`.

### 26.4.1 Type Code and #code
A variable of type Code can be constructed by using the **#code** directive:  
`#code { // a code block }`, like `#code { x += 7 }`. 
This can also be one line, like this:  
`code :: #code a := Vector3.{1,2,3};`
All these expressions have type Code.


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
`factorial` is an example of a recursive macro; #if needs to be used here, else you get the following `Error: Too many nested macro expansions. (The limit is 1000.)` 
`maxfunc` is a procedure which calls a nested macro `macron`; this returns "Backtick return macro" as return value from `maxfunc`.  

**Exercise** (see changer_macro.jai)  
Write a macro changer that takes 2 integer arguments and can access an outer variable x. x is multiplied with the 1st argument, and the 2nd argument is added to it.

### 26.5.1 Using a macro with #insert
`macroi` in line (9) illustrates that we can use #insert (see § 26.4) inside a macro: it takes a code argument and inserts it 3 times in the main code.

### 26.5.2 Using a macro with #insert to unroll a for loop
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

In the example above `unroll_for_loop` is a macro that receives a Code parameter. It uses the `#insert -> string` shortcut (see § 26.4). In fact, it uses multiple inserts, #insert can be run recursively inside another #insert as seen in line (1).  
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

Jai does not support closures. The technique demonstrated here is a way to emulate a closure.  
In § 15.1.3 we showed code that iterated over a linked list with a while loop.
Wouldn't it be nice if we could do this with a for loop?

## 26.6 Using a for-expansion macro to define a for loop
As easy as it is to for-loop over an array, this is not defined for other composite data-structures, such as the linked list we discussed in § 12.6. But this can be done with a macro, by defining a so-called _for_expansion_:

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

But we can do better! (see for_expansion macro Version 2). Just leave out the temporary variables `iter` and `i` and work only with it and it_index. Also note you only have to backtick the variables the first time you use these. Note that in our actual for call, we have to print `it.data`.

> Remark: iterating over data-structures with for seems to have been the primary reason for introducing macros in Jai.

Now let's make the same for-loop for a double linked-list:

## 26.7 A for-expansion macro for a double linked-list
Let's now define a more general linked list as having a first and a last Node (see line (1)), whereby Node is recursively defined(see line (2)) as having a value, a previous and a next Node. Another advantage is that the type of the value (and Node) is polymorf written as T.

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


## 26.8 The #modify directive
The **#modify** directive can be used to insert some code between the header and body of a procedure or struct, to change the values of the polymorph variables, or to reject the polymorph for some types or combination of variables. It is a block of code that is executed at compile-time each time a call to that procedure is resolved.  
#modify allows to inspect   parameter types at compile-time; when it returns a bool value:
> true: this signals that $T is a type that will be accepted at compile-time.
> false: it generates a compile-time error.


## 26.9 SOA (Struct of Arrays)

SOA is a special kind of data-design, which makes memory-use much faster, and so enhances performance.
It is done at compile-time using `#insert`. This mechanism automatically converts between SOA (Structure of Arrays) and AOS (Array of Structures), without breaking the supporting code. This means a completely different memory access pattern, and it allows for quickly changing data layouts with minor code edits.

### 26.9.1 Data-oriented design
Jai provides built-in support for data-oriented development: it’s a high-level language build for fast memory support. Good memory layout is important because if it is not well done, too many memory cache misses will occur, alongside too much allocator overhead. Moreover consoles and mobile devices tend to have more limited memory constraints. Jai helps you to set up things in memory the way you want, without loss of efficiency or high-level expressiveness.

### 26.9.2 Making a SOA struct using #insert
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


## 26.10 How to get the generated source files after the meta-program step?
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

## 26.11 How to get info on the nodes tree of a piece of code?
In § 26.4.1 we saw how #code can make something of type Code out of a piece of code. The procedure `compiler_get_nodes` can take something of type Code and get the AST nodes out of it:
```
compiler_get_nodes :: (code: Code) -> (root: *Code_Node, expressions: [] *Code_Node) #compiler;
```

(`Code_Node` is a struct defined in module _Compiler_)
In the program below we analyse the nodes of the statement: `code :: #code a := Vector3.{1,2,3};`

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

## 26.12 The #placeholder directive

See *26.12_placeholder.jai*:
```c++
#import "Basic";

#placeholder TRUTH;                     // (1)

#run {
   #import "Compiler";
   options := get_build_options();
   add_build_string("TRUTH :: true;");  // (2)
}

main :: () {
   print("TRUTH is %, is it a constant? %\n", TRUTH, is_constant(TRUTH));
   // => TRUTH is true, is a constant? true
}
```
The **#placeholder** directive specifies to the compiler that a particular symbol will be defined/generated by the compile-time meta-program.  
In the program code, the constant TRUTH is 'announced' in line (1), it only gets declared in the #run block with the proc `add_build_string` in line (2). Note how `#import "Compiler";` also can be done in the #run block.

## 26.13 The #type directive
This directive tells the compiler that the next following syntax is a new type.  
For example:
```c++
IL_LoggingLevel :: u16;
IL_Logger_Callback :: #type(level: IL_LoggingLevel, text: *u8, ctx: *void) -> void #c_call;
```
The code above defines the procedure `IL_Logger_Callback` as a proc with as type the given signature.

This is useful for resolving ambiguous type grammar.
