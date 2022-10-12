# Chapter 17 - Basics of procedures

Until now we've only used the main :: () proc.
We know that we can create local code blocks (see 7.1.2), and that we can repeat a code block with in a or for loop. But it is also very useful to be able to call a code block by name, which is exactly what a **procedure** or **proc** (more often called **procs** in other languages) is.  

## 17.1 Declaring and calling a proc
A block of code that is used several times is a good candidate to be wrapped up inside a proc. This reduces code duplication and can enhance code readability.

See _17.1_proc_definitions.jai_:

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
}   

```

In lines (1) - (3) we define three proc's in global scope: square, mult and sum. These are one-liners, so you could write them as such. The procs need not be defined before main; the order doesn't matter.
   
But a proc call causes a change in the execution flow, so it's inherently slower. Unless for documentation/readability reasons, you should only use a proc for multiple lines. As often, Jai offers a solution for this redirection problem with the keyword **inline** (see § 17.7).

We see that the declaration of a procedure looks like this:

```c++
proc_name :: (arg1: type1, arg2: type2) -> return_type {
    // proc body code
    return …;
}
```

Line (9) also shows a typical functional language syntax for one-line procs:  `lam :: (a, b) => a + b;` (note that types are absent here).  
Proc names are written the same way as variable names. They are followed by a ::, which indicates they are constants.  
A proc can use global variables and also receive data from where it is called through its _argument_ list (arg1: type1, arg2: type2). Each argument has to be typed separately.
There can be no (like main :: ()), one or more arguments.

A proc can change global variables, and also return values. This is indicated by `->` followed by the type of the value it returns. 
Inside the body, the data is returned by using the keyword **return**, like `return variable(s)`.
If a proc doesn't return anything (like main :: (), it returns void), you can leave -> out, or you could write `-> void` if you wanted to.
There can be no (like main :: () {}), one or more return values.

### 17.1.1 Exiting from a proc with return
`return` breaks out of all scopes to the call site of the proc, so statements after this won’t be executed.
`return` can pass back one or more values to the calling site, but it can also stand on its own to mean just the end of the proc. 

Then, enclosed in { } comes the proc's body.

The proc is called as  	 `proc_name(par1, par2)`;
Here par1 and par2 are the parameters that are substituted in order into the arguments arg1 and arg2, they have to be of the indicated type type1 and type2, otherwise you get an error such as:
_Error: Number mismatch. Type wanted: int; type given: float32._ (see line (4), compile this for yourself and see how clear the message is: indicating the parameter in the call and the argument in the args list where it went wrong). The number of parameters and arguments must be the same (but see ?? default arguments).

As we see in line (5), it is always possible to pass the parameter value through its argument name: `square(x = c)`. This enables a more-documented style, but also to call the arguments in a different order than declared.  
Line (6) shows that a parameter can just be another proc call.

### 17.1.2 Getting the type and address of a proc
Line (7) shows that a proc is a pointer, it points to where the code starts in memory.
Line (8) tellus us the type of the sum proc:
`procedure (s64, s64, s64) -> s64`
So the header or signature of a proc (its arguments and return-values list) determine its type.

**Exercises**  
(1) Write a proc with no arguments that prints "Hello, world!"   (see display.jai). Make the proc run at compile time.  
(2)	Write a proc that prints a new line (see newline.jai).  
(3) Rewrite ex 15.2_squares.jai from § 15 using a proc square  (see proc_square.jai) and test it.  
(4) Write a proc that tests whether a character is a digit (see is_digit.jai)  
(5) Jai has its own assert built-in, but let us write our own assert proc that takes a condition and does nothing if this is true, else it prints an error message “ASSERTION FAILED” (see assert.jai).   

## 17.2 Local procs
Procedures defined at the same top-level as main are called global procs. They can be called by main and can also call each other. An example is `proc` and `proc2` in the following code:

See _17.2_local_procs.jai_:

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
Using local procs for things like helper procs promotes code hygiene: there are less global procs to worry about. Only make procs global when they are really used in several places.

## 17.3 Difference between passing a copy and passing a pointer
See _17.3_passing.jai_:

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
Passing a pointer to n in (2) allows the proc `passing_pointer` to change the value pointed to by dereferencing the pointer (m also points to the address of n, as does *n). In lines (3) and following, we see the same mechanism applied to a struct variable.

> To change a variable inside a proc, you need to pass a pointer to that variable as parameter to the proc.

## 17.4 Default values for arguments
See _17.4_default_args.jai_:

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
}
```

This is simply done by assigning a value to one or more of the arguments of a procedure. Now we can use type inference in the definition of the arguments; the hello proc can have this header:  
`hello :: (a := 9, b := 9)` 
In line (1) we see how the argument a in proc1 gets a default value of 0. In the hello proc both arguments a and b get a default value 9. The lines after marker (3) show the effect of calling hello() with zero, one or two arguments. So you  see that with default values, the number of parameters can be smaller than the number of arguments.

> When the procedure is called and no parameter is specified for an argument with a default value, then that value is taken as the parameters value.

A default value must not be a literal value, it can be any symbol, like a variable or even another procedure call.

## 17.5 Named arguments
We already saw an example of this in line (5) of _17.1_proc_definitions.jai_:  `a2 := square(x = c);`
the argument which is named x gets the parameter value c in an explicit assignment.  
Named arguments are useful when you have procs which take many arguments, often of the same type.   
When arguments are given default values, it can be even more complicated. In such a case it is possible that the compiler can’t distinguish between them if you pass parameters in the wrong order. Named arguments allow you to specify the parameter values in any order.  
Here is another example to illustrate its usefulness:  
 `make_character(name = "Fred", catch_phrase = "Hot damn!", color = BLUE);`  
Partially naming arguments is allowed, then you have to be very cautious, but Jai carefully checks the parameters. After using named arguments you cannot switch to unnamed ones.

## 17.6 #must and multiple return values
See _17.5_multiple_return.jai_:

```c++
#import "Basic";

proc1 :: () -> int, int {   // (1)
    return 3, 5;
}

mult :: (n1: float, n2: float) -> float #must {  // (2)
    return n1 * n2;
}

main :: () {
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

You can name the return parameters:		
`proc1 :: () -> n: int, m: int { … }` 
You can even have default values for return parameters:
`proc1 :: () -> (n: int = 1, m: int = 2) { … }`

Unlike languages such as Rust or Go, procs do not return tuple object values, but rather return the values in registers.  
When a proc returning multiple values is called, you must explicitly assign all values to new variables, calling only proc_mult() only returns the first value. 

### 17.6.1 The #must directive
When #must is written after the return values as in line (2),it is not allowed to ignore these: see line (4). The value(s) must be assigned, as in line (5). This prevents a common source of mistakes.

> When a return value is annotated with #must, this indicates that it must be received in a variable at the call site, it cannot be ignored.

### 17.6.2 Example proc: file_open
As example of a procedure with named arguments, default values and multiple return values, consider the `file_open` proc, which is defined in module _File_ (a different version exists in windows.jai and unix.jai for these OS's, for performance reasons).

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

## 17.7 Overloading procedures
Procedures are said to _overload_ each other when they have the same name, but different argument list. The only thing in which they differ is the types of their arguments. Here is an example with two procedures proc1:

See _17.6_overloading.jai_:

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
        proc2 :: (n: u64) { print("In proc2 - u64 line (6)\n"); }         // (6)  
        m: u8 = 8;
        proc2(m);                 // (7) 
        // => In proc2 - u8 line (3)
        proc2("Hello, JAI!");     // (8)
        // => In proc2 - string line (4)
    }
}
```

Overloading will try to find the smallest and closest fit for overloaded procs, so the first call to proc1 will call version (1), and the second one will call version (2), as proven by the printed output.

The following error is given when there are two procs with same name and argument lists in the code on the same scope level:
**Error: Two overloaded definitions of the same procedure can't have identical argument lists.**


### 17.7.1 Overloading in global and local scope
Suppose we have overloading procs in global and local scope(s). How will the overloading mechanism then work? Look at the four versions of proc2 in the preceding code.  
The way the resolution mechanism works is: it looks through all overload versions regardless their scope, and will pick the overload where the argument(s) type fit best.

**Problem?**
You've probably spotted the problem: nearly every procedure will have possibly (many) overloads, differing only in the proc header, the code often stays the same. This promotes code bloat, and a change in logic means changing a number of procs. Lots of programming languages have a solution for this, called generics, templates or parametrization. Jai's solution is called **polymorphic procedures**, which we'll discuss in § ??.

## 17.8 Inlining procs
See _17.7_inlining.jai_:

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

When you tell the compiler explicitly to **inline** a proc call, it means that the proc code is inserted at the line where the proc is called (the call site), with the parameter values inserted in the right places. So effectively, the proc call is eliminated, thereby saving the overhead of the proc call and enhancing the performance of the program.  
The compiler often does this implicitly, without the developer knowing that. But in Jai, the developer can explicitly indicate where to inline (or not line) a proc. This is done with:  
`:: inline` or `:: no_inline` at the proc declaration
or:  
`inline proc_call()` or `no_inline proc_call()` at the call site    
Inlining is a command to the compiler which must be obeyed, it is not a hint.

In the snippet above you find a concrete example of each of these cases. A proc declared as :: inline by will by default be inlined.  
(In certain cases it can be that inlining is impossible, for example inside a recursive proc).

> So there are 2 ways to specify inlining:	
>   1) at the proc definition: keyword inline before argument list;
>   2) at the call site: keyword inline before the proc call

**Exercise**
In _inlining_ex.jai_, at each of the lines (1) - (7), decide whether the call to the proc is inlined or not.

## 17.9 Recursive procs
See _17.8_recursive.jai_:

```c++
# import "Basic";

factorial :: (n: int) -> int {
    if n <= 1 return 1;           // (1)
    return n * factorial(n - 1);  // (2)
}

main :: () {
    for i: 1..20 {  // correct till i == 20
        print("The factorial of % is %\n", i, factorial(i));
    }
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
This cannot go on infinitely, once stack memory is depleted (a condition called **stack overflow**), the program crashes: `The program crashed`. (Try this out by changed the end value in the for loop to 10_000, in our case the crash occurred at around recursion 9200).
A recursive solution may be logically the simplest, but it most probably is not the most performant solution, not withstanding its sometimes incorrect and always stack-limited behavior. 

## 17.10 Swapping values
See _17.9_swap.jai_:

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
In ?? we'll discuss two built-in polymorphic versions of swap.

## 17.11 A println procedure
See _17.10_println.jai_:

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
The code shows two overloading versions. Both have the keyword **inline**, to avoid a procedure call to `println`, increasing performance.
- (1) just takes 1 argument of the Any type, and calls the standard print procedure from _Basic_, adding a new-line character, so `println` can also print out variables of any type, in contrast to `print`!  
- (2) takes a format string msg, and takes a variable (..) number of Any type, it calls `print` with the same arguments, and then prints a \n.

## 17.12 Autocasting a parameter with xx
See _17.11_autocast.jai_:

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
(see _make_vector2.jai_) 


## 17.13 Structs and procs

## 17.13.1 Using the namespace of a struct in procs
See _17.11_using_structs_procs.jai_:

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
See _17.13_using_as_structs.jai_:

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

**Exercise**
Use struct Person from § 17.3. Add fields name and location, which is a Vector2 used from module _Math_. Define a proc `move_person`, which can change a person's location. Test it out!
(see structs_and_procs.jai)