# Chapter 17 - Basics of procedures

Until now we've only used the `main :: ()` proc in our own code, but we already used a lot of procedures from the standard modules library. In this section, we'll start defining our own procedures and explore all functionality to do so.
We know that we can create local code blocks (see § 7.1.2), and that we can repeat a code block within a for loop. But it is also very useful to be able to call a code block by name, which is exactly what a **procedure** or **proc** (more often called **functions** in other languages) is.   
Another definition could be: a proc is a callable set of statements that together perform a task, with optional parameters and return value(s).

## 17.1 Declaring and calling a proc
A block of code that is called several times is a good candidate to be wrapped up inside a proc. This reduces code duplication and can enhance code readability.

See *17.1_proc_definitions.jai*:

```c++
#import "Basic";

square :: (x: float) -> float { return x * x; };          // (1)
mult :: (x: float, y: float) -> float { return x * y; };  // (2)

sum :: (x: int, y: int, z: int) -> int  {                 // (3)
    return x + y + z;
}

lam :: (a, b) => a + b;   //  (9)

main :: () {
    // calling the proc
    print("Sum: %\n", sum(1, 2, 3));  // => Sum: 6 
    // sum(1.0, 3.14, 5);                // (4)
    c := 3.0;
    a := square(c);   
    print("a is %\n", a); // => a is 9

    a2 := square(x = c);    // (5) using a named argument
    print("a2 is %\n", a2); // => a2 is 9
    
    print("b is %\n", mult(a, a2)); // (6) => 81
    print("% \n", lam(1, 2)); // => 3

    // The address in memory of the 'sum' proc is:
    print("%\n", sum); // (7) => procedure 0x7ff7_a9c3_e1b0
    print("0x%\n", cast(*void) sum);  // => 0x7ff7_a9c3_e1b0
    print("Its type is: %\n", type_of(sum));  // (8)
    // => Its type is: procedure (s64, s64, s64) -> s64

    p_ptr: (int, int, int) -> int = sum; // (10)
    // p_ptr := sum; // (10B)
    d := p_ptr(1, 2, 3);                 // (11)
    print("d is %\n", d); // => d is 6
}   

```

In lines (1) - (3) we define three proc's in global scope: square, mult and sum. These are one-liners, so you could write them as such. The procs need not be defined before `main`; the order doesn't matter.
   
But a proc call causes a change in the execution flow, so it's inherently slower. Unless for documentation/readability reasons, you should only use a proc for multiple lines. As often, Jai offers a solution for this redirection problem with the keyword **inline** (see § 17.7).

We see that the declaration of a procedure looks like this:

```c++
proc_name :: (arg1: type1, arg2: type2) -> return_type {
    // proc body code
    return …;
}
```

Line (9) also shows a typical functional language syntax for one-line procs or **lambdas**:  `lam :: (a, b) => a + b;` (note that types are absent here).  
Proc names are written the same way as variable names. They are followed by a **::**, which indicates they are constants.  
A proc can use global variables and also receive data from where it is called through its _argument_ list (arg1: type1, arg2: type2). Each argument has to be given a type separately.
There can be no arguments like with main :: (), or one or more arguments.

A proc can change global variables. It can also return values. This is indicated by `->` followed by the type(s) of the value(s) it returns. 
Inside the body, the data is returned by using the keyword **return**, like `return variable(s)`.
If a proc doesn't return anything (like main :: ()), it returns void. Then you can leave -> out, or you could write `-> void` if you wanted to.  
There can be no return values (returns void, like main), or one or several.  
Procs do not return tuple object values as in Rust or Go, but rather return the values in registers.

### 17.1.1 Exiting from a proc with return
`return` breaks out of all scopes to the call site of the proc, so statements after this won’t be executed.
`return` can pass back one or more values to the calling site, but it can also stand on its own to mean just the end of the proc. 

Then, enclosed in { } comes the proc's body.

The proc is called as  	 `proc_name(par1, par2)`;
Here par1 and par2 are the parameters that are substituted in order into the arguments arg1 and arg2, they have to be of the indicated type type1 and type2, otherwise you get an error such as:
_Error: Number mismatch. Type wanted: int; type given: float32._ (see line (4), compile this for yourself and see how clear the message is: indicating the parameter in the call and the argument in the args list where it went wrong).  
The number of parameters and arguments must be the same, except when there are default arguments, see § 17.4.

As we see in line (5), it is always possible to pass the parameter value through its argument name: `square(x = c)`.  
This enables to call the arguments in a different order than declared, but also a more-documented style.    
Line (6) shows that a parameter can just be another proc call.

### 17.1.2 Getting the type and address of a proc
Line (7) shows that a proc is an address (often called a **function pointer**), it points to where the code starts in memory. § 22.4 and 22.6 show examples where this function pointer is used as a parameter to another procedure.  
Line (8) tells us the **type** of the `sum` proc:
`procedure (s64, s64, s64) -> s64`
So the **header** or **signature** of a proc (its arguments and return-values list) is its type.
In line (10) we declare a proc variable `p_ptr` with the same signature as sum, and we assign sum to it. (10B) shows that this also works with type inference. This allows us to call `sum` with this new name (line (11)).

**Exercises**  
(1) Write a proc with no arguments that prints "Hello, world!"   (see display.jai). Make the proc run at compile time.  
(2)	Write a proc that prints a new line (see newline.jai).  
(3) Rewrite ex 15.2_squares.jai from § 15 using a proc square  (see proc_square.jai) and test it.  
(4) Write a proc that tests whether a character is a digit (see is_digit.jai)  
(5) Jai has its own assert built-in, but let us write our own assert proc that takes a condition and does nothing if this is true, else it prints an error message “ASSERTION FAILED” (see assert.jai).   

## 17.2 Local procs
Procedures defined at the same top-level as main are called global procs. They can be called by main and can also call each other. Examples are `proc` and `proc2` in the following code:

See *17.2_local_procs.jai*:

```c++
#import "Basic";

main :: () {
    // calling a global proc:
    proc();
    proc2(); 

    // local procs:
    add :: (x: int, y: int) -> int { return x + y; };   // (1)

    display :: (arg1: string, arg2: string) {           // (2)
        print("arg1 is % and arg2 is %\n", arg1, arg2); 
    }

    // calling the procs:
    print("%\n", add(1, 2));        // (3) => 3
    display("Jonathan", "Blow");    // (4) => arg1 is Jonathan and arg2 is Blow
}

// global proc:
proc :: () {
    x := 1;
    inner_proc();
    print("x is now %\n", x); // => x is now 1

    inner_proc :: () {
            print("This is an inner proc\n"); // => This is an inner proc
            //  Error: Attempt to use a variable from an outer stack frame. (Closures are not supported.)
            // x = 42; // (5) this does not work! cannot access variable of inner_proc scope!
    }
}

proc2 :: () {
    print("Jonathan Blow\n");  // => Jonathan Blow
    // display("Jonathan", "Blow"); // (6) => Error: Undeclared identifier 'display'.
}

/*
This is an inner proc
x is now 1
Jonathan Blow
3
arg1 is Jonathan and arg2 is Blow
*/
```

Any proc, in particular main, can contain _local_ procs (also called _inner_ or _nested_ procs), like add and display in lines (1) and (2). They can be called from within the enclosing proc, as lines (3)-(4) show. The same goes for `inner_proc` inside procedure `proc`.  
There is one important limitation: an inner proc cannot access outer variables! If we uncomment line (5), we get the:  **Error: Attempt to use a variable from an outer stack frame. (Closures are not supported.)**  
Also a procedure doesn't even see the inner procs defined inside other procs (see line (6)).
> A local proc is only known in the procedure where it is defined, it lives inside the scope of that proc. If you call it from outside its scope (like in proc2) you get the error: Error: Undeclared identifier
### What is the purpose and advantage of local procs?
Using local procs for things like helper functions promotes code hygiene: there are less global procs to worry about. Only make procs global when they are really used in several places.

## 17.3 Difference between passing a copy and passing a pointer
See *17.3_passing.jai*:

```c++
#import "Basic";

passing_copy :: (m: int) {
  m = 108;
}

passing_pointer :: (m: *int) {
  << m = 108;
}

Person :: struct { name: string; }

change_name :: (pers: *Person) {
    pers.name = "Jon";
}

main :: () {
    n := 42;
    passing_copy(n);      // (1)
    print("n is % after passing by copy \n", n);  // => n is 42 after passing by copy 
    passing_pointer(*n);  // (2)
    print("n is % after passing by pointer \n", n); // => n is 108 after passing by pointer

    bob := Person.{name = "Robert"}; // (3)
    change_name(*bob);
    print("The person is now called %\n", bob.name); 
    // => The person is now called Jon
}
```

Passing a copy (by value) of the variable n in (1) only changes the local variable m, which is a copy of n. The initial variable n is not changed when its copy changes in the proc.   
Passing a pointer to n in (2) allows the proc `passing_pointer` to change the value pointed to by dereferencing the pointer (m also has the address of n, as does *n). In lines (3) and following, we see the same mechanism applied to a struct variable.

> To change a variable inside a proc, you need to pass a pointer to that variable as parameter to the proc.

**What happens if you don't pass by pointer explicitly?**  
Arguments of size <= 8 bytes (basic types such as s64, u8, Type, any pointer, or any enum) are always passed by value (copy).  
Bigger sized values which is any type > 8 bytes, including Any, string, struct, and so on, are most probably passed by reference (pointer), but anyhow they cannot be changed. To change their data, make a local copy and change that.
(We say 'probably', because it is up to the compiler to decide pass by value or pass by reference, for better optimization.) 
To ensure you get a pointer for some reason (for example to modify the contents of the struct) you can explicitly pass a pointer.

## 17.4 Default values for arguments
See *17.4_default_args.jai*:

```c++
#import "Basic";

proc1 :: (a: int = 0) { // (1)
    print("a is %\n", a); 
}

// hello :: (a: int = 9, b: int = 9) { // (2)
hello :: (a := 9, b := 9) { // (2)
    print("a is %, b is %\n", a, b);
}

main :: () {
    proc1();     // => a is 0
    // (3)
    hello(1, 2); // => a is 1, b is 2
    hello(1);    // => a is 1, b is 9
    hello();     // => a is 9, b is 9
    hello(b = 42); // (3) => a is 9, b is 42 
}
```

This is simply done by assigning a value to one or more of the arguments of a procedure in the argument list itself. Now we can use type inference in the definition of the arguments.   

> When the procedure is called and no parameter is specified for an argument with a default value, then that value is taken as the parameters value.

In line (1) we see how the argument a in proc1 gets a default value of 0. In the hello proc both arguments a and b get a default value 9:   `hello :: (a := 9, b := 9)`. The lines after marker (3) show the effect of calling hello() with zero, one or two arguments.   
So you see that with default values, the number of parameters can be smaller than the number of arguments. 

A default value must not be a literal value, it can be any symbol, like a variable or even another procedure call.

## 17.5 Named arguments
We already saw an example of this in line (5) of *17.1_proc_definitions.jai*:  `a2 := square(x = c);`
the argument, which is named x, gets the parameter value c in an explicit assignment.  
Named arguments are useful to enhance readability when you have procs which take many arguments, often of the same type. The feature also exists in Python.  

When arguments are given default values, it can be even more complicated. In such a case it is possible that the compiler can’t distinguish between them if you pass parameters in the wrong order. Named arguments allow you to specify the parameter values in any order. If you want to pass parameters after the first argument with a default value, you have to pass them with the argument name, as in line (3).  

Here is another example to illustrate its usefulness:  
 `make_character(name = "Fred", catch_phrase = "Hot damn!", color = BLUE);`  
Partially naming arguments is allowed, then you have to be very cautious, but Jai carefully checks the parameters. After using named arguments you cannot switch to unnamed ones.

**Exercise**  
(See named_args.jai)
Check the proc `hello`. Predict the outcome of the following calls: 
    hello("fred", "booya"); 
    hello("booya", "fred"); 
    hello(phrase = "booya", name = "fred"); 
    hello("fred", phrase = "booya"); 
    hello(name = "fred", "booya");
    hello("fred", 3.14); 
Then test the program out to see if you were right.

## 17.6 Multiple return values and #must  
See *17.5_multiple_return.jai*:

```c++
#import "Basic";

proc1 :: () -> int, int {   // (1)
    return 3, 5;
}

proc2 :: () -> a: int, b: int {  // (1B)
  a := 100;
  b := 200;
  return a, b;
}

proc3 :: (var: bool) -> a: int = 100, b: int = 200 {  // (1C)
  if var == true then
    return; 
  else
    return 1_000_000;
}

mult :: (n1: float, n2: float) -> float #must {  // (2)
    return n1 * n2;
}

main :: () {
    a := proc1();         // (2B)
    print("a is %\n", a); // => a is 3

    b, c := proc3(true);   // (2C)
    print("%, %\n", b, c); // =>  100, 200

    d, e := proc3(false);  // (2D)
    print("%, %\n", d, e); // => 1000000, 200
    // x, y: int;
    // x, y = proc1();
    // shorter:
    x, y := proc1();        // (3)
    print("x is % and y is %\n", x, y); // => x is 3 and y is 5
    n := 3.14;
    m := 5.18;
    print("mult is %\n", mult(n, m)); // => mult is 16.2652
    // mult(n, m); // (4) with #must 
    // => Error: Return value 1 is being ignored, which is disallowed by #must.
    mm := mult(n, m); // (5)
}

```

As we see in line (1), a procedure can also have two or more return values (like in Go). They are listed after the -> and separated by a `,` If it enhances readability, they may be enclosed between (), like -> (int, int)  
(These are needed when a proc with multiple return values is used as an argument in another proc).  

The returned values are assigned to an equal number of variables in the left-hand side (see line (3)); if necessary these variables could have been declared earlier.  
It is not necessary to assign all return values, as in (2B) where we ignore the 2nd return value. 
It is better to return things by value; this avoids having extra stack copies like in C.

**The _ token**  
If you would like to discard one or more of the return values, use `_` instead of a variable as in Go, like this:
`result, ok, _ := to_integer(text);`  
Here we discard the 3rd return value, which is a `remainder` string in which we are not interested.

Unlike languages such as Rust or Go, procs do not return tuple object values, but rather return the values in registers.  

## 17.6.1 Named and default return values
You can name the return parameters:		
`proc1 :: () -> n: int, m: int { … }` 
You can also have default values for return parameters:
`proc1 :: () -> (n: int = 1, m: int = 2) { … }`
The n and m above are not declared variables, you need to declare them inside the proc and explicitly return them: `return n, m` .
The default values are returned if the proc does not provide a value for them.

`proc2` in line (1B) shows named return values. `proc3` in line (1C) shows return values with named default arguments (they have to be named). In the case of a simple return, all return values are automatically returned by default. Lines (2C-D) shows how this works when the proc is called.

### 17.6.2 The #must directive
Ignoring return values could be a mistake, so Jai provides the **#must** directive to enforce you to assign all return values (see § 17.6.1) 
When #must is written after the return values as in line (2),it is not allowed to ignore these: see line (4). The value(s) must be assigned, as in line (5). This prevents a common source of mistakes.

> When a return value is annotated with #must, this indicates that it must be received in a variable at the call site, it cannot be ignored.

### 17.6.3 Example proc: file_open
As an example of a procedure with named arguments, default values and multiple return values, consider the `file_open` proc, which is defined in module _File_ (a different version exists in windows.jai and unix.jai for these OS's, for performance reasons).

`file_open :: (name: string, for_writing := false, keep_existing_content := false, log_errors := false) -> File, bool { ... }`

 The argument for_writing, instead of being declared as for_writing: bool, directly receives a boolean value: for_writing := false.

 Here is an example code snippet for how this proc can be used:

 ```c++
file, success :=  file_open("temp_dir/file1.txt",  for_writing=true, keep_existing_content=true);
if !success {      // (1)
    print("Could not open file temp_dir/file1.txt for writing.\n");
    return;
}
```

By returning a bool which signals success of the file-opening action, we can test as in line (1) on success, and leave the current procedure when there was a problem.

**Exercise**  
(See return_values.jai)
Predict the outcome when the proc `fun` is respectively called with argument x equal to 0, 1, 2, 3 and 4. Then compile/run the program and check your answers.


## 17.7 Overloading procedures
Normally variables with the same name cannot exist, but procedures can if they have different arguments.
## 17.7.1 What are overloading procedures?
Procedures are said to _overload_ each other when they have the same name, but different argument list. The only things in which they differ are the types of their arguments. Here is an example with two procedures proc1:

See *17.6_overloading.jai*:

```c++
#import "Basic";

proc1 :: (n: u8) -> u8 {
    print("In proc1 - u8 line (1)\n");
    return n * 2; 
}       // (1)

proc1 :: (n: u16) -> u16 {
    print("In proc1 - u16 line (2)\n");
    return n * 2; 
}     // (2)

proc2 :: (n: u8) { print("In proc2 - u8 line (3)\n"); }            // (3)

proc2 :: (str: string) { print("In proc2 - string line (4)\n"); }  // (4)

main :: () {
    a := proc1(12);   // => In proc1 - u8 version (1)
    b := proc1(256);  // => In proc1 - u16 version (2)
    print("The results are % and %\n", a, b); 
    // => The results are 24 and 512

    {
        proc2 :: (n: u16) { print("In proc2 - u16 line (5)\n"); }         // (5)
        // proc2 :: (n: u8)  { print("In proc2 - u8 line (5B)\n"); }         // (5B)
        proc2 :: (n: u64) { print("In proc2 - u64 line (6)\n"); }         // (6)  
        m: u8 = 8;
        proc2(m);                 // (7) 
        // with (5B) commented out => In proc2 - u8 line (3)
        // with (5B) => In proc2 - u8 line (5B)
        proc2("Hello, JAI!");     // (8)
        // => In proc2 - string line (4)
        n: u16 = 12500;
        proc2(n);                 // (9) 
        // => In proc2 - u16 line (5))
    }
}
```

Overloading will try to find the smallest and closest fit for overloaded procs, so the first call to proc1 will call version (1), and the second one will call version (2), as proven by the printed output.
For another example, see § 22.1

The following error is given when there are two procs with same name and argument lists in the code on the same scope level:
**Error: Two overloaded definitions of the same procedure can't have identical argument lists.**

**Exercise**
In *overloading.jai*, predict what the program will display. Then run it to check you were right.

### 17.7.2 Overloading in global and local scope
Suppose we have overloading procs in global and local scope(s). How will the overloading mechanism then work? Look at the four versions of proc2 in the preceding code.  
The way the resolution mechanism works is:  
It looks through all overload versions regardless their scope, and will pick the overload where the argument(s) type fit best. When there is a local proc overload that fits, this well get chosen.

**Problem?**
You've probably spotted the problem: nearly every procedure will have possibly (many) overloads, differing only in the proc header, the code often stays the same. This promotes code bloat, and a change in logic means changing a number of procs. Lots of programming languages have a solution for this, called generics, templates or parametrization. Jai's solution is called **polymorphic procedures**, which we'll discuss in § 22.

## 17.8 Inlining procs
See *17.7_inlining.jai*:

```c++
test_local :: (x: int) { /*... */}
test_local_inline :: inline (x:int) { /*...*/ }

main :: () {
  test_local(1);        // (1) test_local called as function
  inline test_local(1); // (2) code of test_local is inlined

  test_local_inline(2); // (3) code of test_local_inline is inlined
  no_inline test_local_inline(2); // (4) not inlined
}
```

When you tell the compiler explicitly to **inline** a proc call, it means that the proc body code is inserted at the line where the proc is called (the call site). The proc call is replaced with the actual body of the function, and the parameter values inserted in the right places. So effectively, the proc call is eliminated, thereby saving the overhead of the call and enhancing the performance of the program.  
The compiler often does this implicitly, without the developer knowing that. But in Jai, the developer can explicitly indicate where to inline (or not line) a proc. This is done with:  
`:: inline` or `:: no_inline` at the proc declaration
or:  
`inline proc_call()` or `no_inline proc_call()` at the call site    
Inlining forces the compiler to attempt to inline a procedure, it is not a hint.

In the snippet above you find a concrete example of each of these cases. A proc declared as :: inline by will by default be inlined.  
(In certain cases it can be that inlining is impossible, for example inside a recursive proc).

> So there are 2 ways to specify inlining:	
>   1) at the proc definition: keyword inline before argument list;
>   2) at the call site: keyword inline before the proc call

**Exercise**
In *inlining_ex.jai*, at each of the lines (1) - (7), decide whether the call to the proc is inlined or not.

## 17.9 Recursive procs and #this
See *17.8_recursive.jai*:

```c++
# import "Basic";

factorial :: (n: int) -> int {
    if n <= 1 return 1;           // (1)
    return n * factorial(n - 1);  // (2)
}

factorial2 :: (n: int) -> int {
    if n <= 1 return 1;           
    return n * #this(n - 1);       // (3)
}

main :: () {
    for i: 1..20 {  // correct till i == 20
        print("The factorial of % is %\n", i, factorial(i));
    }

    for i: 1..10 {  // correct till i == 20
        print("The factorial of % is %\n", i, factorial2(i));
    }

    print("#this is %\n", #this); //(4) => #this is procedure 0x7ff7_3ce5_13c0
    print("#this is constant? %\n", is_constant(#this));
    // (5) => #this is constant? true
    THIS :: #this;    // (6) 
}

/*
The factorial of 1 is 1
The factorial of 2 is 2
The factorial of 3 is 6
The factorial of 4 is 24
The factorial of 5 is 120
The factorial of 6 is 720
The factorial of 7 is 5040
The factorial of 8 is 40320
The factorial of 9 is 362880
The factorial of 10 is 3628800
The factorial of 11 is 39916800
The factorial of 12 is 479001600
The factorial of 13 is 6227020800
The factorial of 14 is 87178291200
The factorial of 15 is 1307674368000
The factorial of 16 is 20922789888000
The factorial of 17 is 355687428096000
The factorial of 18 is 6402373705728000
The factorial of 19 is 121645100408832000
The factorial of 20 is 2432902008176640000
*/
```

A recursive procedure is a proc that calls itself in its body.
In the example above, we have a proc `factorial`, which prints out the factorial of the first 20 integers (for i > 20, the calculation results in overflow of the int type). It uses a for loop to call itself in line (2).  

Each recursive iteration is put on the stack, and also decrements n, so eventually we arrive at the base case of line (1). Then the stack is unwound in LIFO order, and all calls are calculated.  
This cannot go on infinitely, once stack memory is depleted (a condition called **stack overflow**), the program crashes: `The program crashed`. (Try this out by changed the end value in the for loop to 10_000, in our case the crash occurred at around recursion 9200). So there has to be a base-case (here n <= 1), where the recursive calling in stopped and the stack starts to unwound. The following code snippet recursive calls indefinitely because it has no base-case to stop:
```
fibonacci :: () {
  fibonacci();
}

fibonacci();
```
It ends with:  
`The program crashed because of a stack overflow.
Printing the stack trace (this may fail when a stack overflow occurred):`

A recursive solution may be logically the simplest, but it most probably is not the most performant solution, not withstanding its sometimes incorrect and always stack-limited behavior. 

### 17.9.1 The #this directive
**#this** refers to the current procedure, struct type or data scope that contains it, as a compile-time constant. A trivial use-case is to replace the proc name in the body of a recursive function by #this, as was done in `factorial2`.  
The #this in line (4) points to the address of `main`. Lines (5) and (6) show that #this effectively is a compile-time constant (is_constant returns true and :: only works for constants).

### 17.9.2 Recursive structs and #this
#this can also be used to declare recursive structs, see *17.16_recursive_this.jai*:

```c++

```
The highly-recursive struct Self_Referential from (1) can be rewritten as in (2) with #this. At the start, both pointers are null, see (3). When we point both fields to itself, we see in (4) that they have the same address.
## 17.10 Swapping values
See *17.9_swap.jai*:

```c++
#import "Basic";

swap :: (x: int, y: int) -> (int, int) {    // (1)
    return y, x;
}

swap_all :: (x: Any, y: Any) -> (Any, Any) {  // (2)
    return y, x;
}

main :: () {
    a, b := swap(1, 2); 
    print("% %\n",a, b); // => 2 1
    c, d := swap_all(1, 2);
    print("% %\n", c, d); // => 2 1
}
```

Swapping two values through a procedure means returning the values in reverse order. A version for ints is shown in line (1), a version for Any type in line (2).
In § 22.2.3 we'll discuss two built-in polymorphic versions of swap.

## 17.11 A println procedure
See *17.10_println.jai*:

```c++
#import "Basic";

main :: () {
    n := 7;
    m := 42;
    println("Hello, world!"); // => Hello, world!
    println(1);               // => 1
    println("% %", n, m);     // => 7 42
    println("The end.");      // => The end
}

println :: inline (arg: Any) {                 // (1)
    print("%\n", arg); // print knows the type of arg
}

println :: inline (msg: string, args: ..Any) {  // (2)
    print(msg, ..args);
    print("\n");
}
// =>
// Hello, world!
// 1
// 7 42
// The end.
```

To avoid having to type \n for a new line, you can have your own customized procedure `println`. 
The code shows two overloaded versions. Both have the keyword **inline**, to avoid a procedure call to `println`, increasing performance.
- (1) just takes 1 argument of the Any type, and calls the standard print procedure from _Basic_, adding a new-line character, so `println` can also print out variables of any type, in contrast to `print`!  
- (2) takes a format string msg, and takes a variable (..) number of Any type, it calls `print` with the same arguments, and then prints a \n.

## 17.12 Autocasting a parameter with xx
See *17.11_autocast.jai*:

```c++
#import "Basic";

test_xx :: (f: float) {
  print("f is %\n", f); 
}

main :: () {
    n: int = 5;
    // (1) test_xx(n);  // Error: Number mismatch. Type wanted: float; type given: int. 
    test_xx(xx n);   // (2) => f is 5
}
```

In the call in line (1) a Type mismatch error occurs. This can be solved by prefixing the parameter with xx as in line (2): then the parameter is casted to the argument type.

**Exercise**
Define your own version of a 2D vector, and write a function make_vec2D that receives 2 floats and returns a 2D Vector.
The struct literal notation is much shorter than the 'constructor'-like proc, but it has a limitation:   
Why doesn't this work?      `v := Vec2D.{x, y};`
(See *make_vector2.jai*) 


## 17.13 Structs and procs
Just like with any other types, we can pass struct variables or pointers to them to a procedure.

## 17.13.1 Using the namespace of a struct in procedures
See *17.11_using_structs_procs.jai*:

```c++
#import "Basic";

Vector2 :: struct {
    x: float = 1;
    y: float = 4;
}

Entity :: struct {
  position: Vector2;
}

print_position_a :: (entity: *Entity) {
  print("print_position_a: (%, %)\n", entity.position.x, entity.position.y);
}

print_position_b :: (entity: *Entity) {
  using entity;
  print("print_position_b: (%, %)\n", position.x, position.y);
}

print_position_c :: (using entity: *Entity) {
  print("print_position_c: (%, %)\n", position.x, position.y);
}

print_position_d :: (entity: *Entity) {
  using entity.position;
  print("print_position_d: (%, %)\n", x, y);
}

main :: () {
    e: Entity;

    print_position_a(*e); // => print_position_a: (1, 4)
    print_position_b(*e); // => print_position_b: (1, 4)
    print_position_c(*e); // => print_position_c: (1, 4)
    print_position_d(*e); // => print_position_d: (1, 4)
}
```

In the code above we have 4 versions of a `print_position_` proc, which take an argument of type *Entity:  
- version a: here the complete path to print the positions is used: `entity.position.x`    
- version b: because of the `using entity`, which is effectively using the namespace of the struct, we can now call the position with `position.x`  
- version c: same as b, but we can call the using directly on the argument
- version d: if we do `using entity.position;` x and y can be reached without any qualification.

## 17.13.2 The #as directive in proc arguments
See *17.13_using_as_structs.jai*:

```c++
#import "Basic";

A :: struct {
  data: int = 108;
}

B :: struct {
  using #as a: A;  // (1) 
}

proc1 :: (a: A) {
  print("Calling proc :: (a: A)\n");
}

proc2 :: (using a: A) {
  print("a.data = %\n", data);
}

main :: () {
  a: A;
  b: B;
 
  proc1(b);   // (2) => Calling proc :: (a: A)
  proc2(a);   // => a.data = 108
  proc2(b);   // (3) => a.data = 108
}
```

In § 12.8 we discussed the usage of the #as directive to implicitly cast a subtype to a supertype. In the above example in line (1) this is declared for B as a subtype of A.  
Line (2) shows how an instance of B can pass seamlessly for an instance of A. In line (3) we see that the same is true when using the namespace.  

**Exercises**  
(1) Use struct Person from § 17.3. Add fields name and location, which is a Vector2 used from module _Math_. Define a proc `move_person`, which can change a person's location. Test it out!
(see structs_and_procs.jai)

In the solution in line (1) you see that a simple . notation is enough to access the fields (unlike in C/C++), even when the variable is actually a pointer to the struct.

(2) Wrap the code from which decides whether a variable is of type Complex into a is_complex_number procedure (see is_complex_number.jai)

## 17.14 Reflection on procedures
As we did in § 16 with structs and enums, we can also get reflection info on a procedure, mainly its argument types and return types:

## 17.14.1 Getting the argument and return types

See *17.14_reflection_procedure.jai*:

```c++
#import "Basic";

add :: (x: int, y: int) -> int {
    return x + y;
}

main :: () {
    info_procedure := cast(*Type_Info_Procedure) type_info(type_of(add)); // (1)
    print("% (", info_procedure.info.type); // => PROCEDURE  // (2)
    for info_procedure.argument_types { // (3)
        print("% - ", << it); 
        if it_index != info_procedure.argument_types.count-1 then print(", ");
    } // => ({INTEGER, 8} - , {INTEGER, 8} -
    print(") -> ");
    for info_procedure.return_types { // (4)
        print("% - ", << it); 
        if it_index != info_procedure.return_types.count-1 then print(", ");
    } // => ) -> {INTEGER, 8}
}
```

In line (1) we take the `type_of` the `add` procedure. From that type we get the `type_info` and cast it to a *Type_Info_Procedure. From that, we see that the `info.type` is a PROCEDURE (line (2)). We can loop over the arrays of argument types and return types in lines (3) and (4). Because these are pointers, we must dereference them.
The complete output shows the signature of the `add` procedure, obtained by reflection:
`PROCEDURE ({INTEGER, 8} - , {INTEGER, 8} - ) -> {INTEGER, 8} - `

## 17.14.2 The #procedure_name directive
This directive returns the statically-known at-compile-time name of a procedure, See *17.15_procedure_name.jai*:

```c++
#import "Basic";

add :: (x: int, y: int) -> int {
    print("The proc name is: %", #procedure_name());
    return x + y;
}
main :: () {
    print("The main name is: %\n", #procedure_name());
    // => The main name is: main
    add(2, 3); // => The proc name is: add
}
```

## 17.15 The #deprecated directive
You can mark a function as deprecated with the **#deprecated** directive. Calling a deprecated function leads to a compiler warning.  
You can add string messages after deprecated procedures as warnings to tell someone to use a different procedure or different set of instructions to accomplish what you want.

See *17.18_deprecated.jai*:
```c++
#import "Basic";

old_function :: () #deprecated "please use new_function :: () instead" {}

new_function :: () {}


main :: ()  {
    old_function(); 
    // => Warning: This procedure is deprecated. Note: "please use new_function :: () instead"
}

```

The purpose is to indicate to a developer using your code(or yourself):  
Look, this is an older version of this function, and in a short time this function will no longer exist. You can continue to use this function for now, but you should replace it with this new_function.

## 17.16 Anonymous procs
All procedures that we have encountered until now had a name, they were named procs. But in certain cases it can be useful to work with unnamed procs, so-called **anonymous functions** or **lambdas**. 

See *17.17_anonymous_procs.jai*:
```c++
#import "Basic";

main :: () {
    () {                            // (1)
      if 2 == {
         case 2;    print("one\n");
         case 3;    print("two");
         case 4;    print("four");
      }
    }();                            // (1B) => one

    anproc := () {                  // (1C)
      if 2 == {
         case 2;    print("one in anproc\n");
         case 3;    print("two");
         case 4;    print("four");
      }
    };  
    anproc();                       // (1D) => one in anproc

    a := () -> int {                // (2)
      if 2 == {
         case 2; return 1;
         case 3; return 2;
         case 4; {
            // do some stuff
         }
      }
    }();                            // (2B)
    print("a is %\n", a);  // => a is 1

    s := 3; 
    b := (s : int) -> int {         // (3)
       if s == {
            case 2; return 1;
            case 3; return 2;
            case 4; {
                // do some stuff
            }
        }
   }(s);                            // (3B)
   print("b is %\n", b);  // => b is 2
}
```

In line (1) an anonymous proc is defined that takes no parameters and has no return value. Because it has no name, it can be called like in (1B), with () immediately after the definition. Alternatively, we can sort of give it a name like in (1C), and call it with that 'name' as in (1D).  
We can also assign the return value to a variable, like in (2) which is an anonymous proc with a return value, again called as in (2B). Line (3) works the same way, but takes in an int parameter s.

The lambda notation ( => ) discussed in § 22.3 is especially elegant for writing anonymous functions.
