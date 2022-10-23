# 22 Polymorphic Procedures

In § 17.7 we discussed overloading procedures, which is a solution for using the same logic for several different types. But this gives rise to duplication of code (as we'll see in the next example), increasing code size and a source for bugs. But Jai offers a solution, many overloading procedures can be reduced to one **polymorphic procedure**, thereby solving the code duplication problem, while retaining the same advantages.  
Polymorphic procedures are similar to C++ templates, Java generics or parameterized functions in other languages.

## 22.1 First example
We want a procedure `convert` to convert a given argument to a bool.
Our first solution is overloading procedures: 

See _22.1A_manyproc.jai_:
```c++
#import "Basic";

convert :: (arg: s32) {
    print("% of type %, cast to bool is %\n", arg, type_of(arg), cast(bool) arg);
}

convert :: (arg: float) {
    print("% of type %, cast to bool is %\n", arg, type_of(arg), cast(bool) arg);
}

convert :: (arg: string) {
    print("% of type %, cast to bool is %\n", arg, type_of(arg), cast(bool) arg);
}

convert :: (arg: []int) {
    print("% of type %, cast to bool is %\n", arg, type_of(arg), cast(bool) arg);
}

convert :: (arg: []bool) {
    print("% of type %, cast to bool is %\n", arg, type_of(arg), cast(bool) arg);
}

main :: () {
    convert(0);             // => 0 of type s32, cast to bool is false
    convert(1);             // => 1 of type s32, cast to bool is true
    convert(cast(s8) -37);  // => -37 of type s32, cast to bool is true

    convert(69105.33);          // (1)
    // => 69105.328125 of type float32, cast to bool is true
    convert("Hello, Sailor!");  // (2)
    // => Hello, Sailor! of type string, cast to bool is true
    arr := int.[1, 2, 3, 4, 5];
    convert(arr);               // (3)
    // => [1, 2, 3, 4, 5] of type [] s64, cast to bool is true
    arr2 := bool.[true, false, true, false];
    convert(arr2);              // (4)
    // => [true, false, true, false] of type [] bool, cast to bool is true
}

```

The first three convert statements work with the proc `convert :: (arg: s32)`. However the convert in line (1) does not: Error: Number mismatch. Type wanted: s32; type given: float32.  
To accommodate this case, we have to make an overloading version `convert :: (arg: float)` with the same logic. But then again the convert in line (2) does not work: Error: Procedure call did not match any of the possible overloads. (Note how the elaborate error message clarifies the problem.)
On again to make a `convert :: (arg: string)` version.
The same goes for the conversions in lines (3) and (4). Each time we have to make another overload. 

Now we have five versions, which all do the same thing.
Wouldn't it be nice if we could reduce this to just one version?

Jai's polymorphic procedures allow you to do just that:  

See _22.1B_polyproc.jai_:
```c++
#import "Basic";

convert :: (arg: $T) {
    print("% of type %, cast to bool is %\n", arg, type_of(arg), cast(bool) arg);
}

main :: () {
    convert(0);             // => 0 of type s32, cast to bool is false
    convert(1);             // => 1 of type s32, cast to bool is true
    convert(cast(s8) -37);  // => -37 of type s32, cast to bool is true

    convert(69105.33);          // (1)
    // => 69105.328125 of type float32, cast to bool is true
    convert("Hello, Sailor!");  // (2)
    // => Hello, Sailor! of type string, cast to bool is true
    arr := int.[1, 2, 3, 4, 5];
    convert(arr);               // (3)
    // => [1, 2, 3, 4, 5] of type [] s64, cast to bool is true
    arr2 := bool.[true, false, true, false];
    convert(arr2);              // (4)
    // => [true, false, true, false] of type [] bool, cast to bool is true
}
```
We only need one version of `convert`, and arg is now said to be **polymorphic**, of a **generic** type **$T**
This procedure can compile to different versions. Each time the compiler sees that the procedure is called with a different concrete type for T (like s32, float32, string or array in the example), it is compiled to a machine-code version for that type. In Jai parlance this is called: **baking out** a copy of the procedure with the polymorphic type(s) fully known. For example, when called as `convert(0)`, a version will be compiled for type s32, in line (1) a new version will be compiled for type float32, in line (2) a new version will be compiled for type string, and so on.
This will happen only once for each type: when the procedure is called again with the same type, the already compiled version for that type will be re-used.

> Polymorphic functions are generated at compile-time, not at runtime by an interpreter or a JIT compiler, like for example in Julia. Because Jai is a strongly typed language, every call to a polymorphic function is also type-checked at compile-time.

Polymorphic procedures are used all over in the Jai library modules, look for example at:
- the `array_add` method for dynamic arrays (§ 18.4), which has as signature:
  `array_add :: (array: *[..] $T, item: T) #no_abc` from _Basic_ module (Array.jai)
- the `bubble_sort` and `quick_sort` code in the _Sort_ module Sort.jai

### 22.1.1 What is $T ?
In the `convert` proc of program 22.1B, the type itself is a variable, that we call T.
T is just a name for a generic type, it could also be S, R, U, V, or Targ and so on, or any name that starts with a capital letter.
The $ before the T indicates that this is a compile-time type variable: it _defines_ T to be whatever type you called it with. T can also be used without the $ (see example 22.2_polyproc2.jai), but there must be one defining instance $T.  
There can be several different polymorphic types in a procedure (like S, T, R, and so on), in the argument list as well as return type(s) list. They can also be mixed with other types (?? see for example repeat in 100_)<;  >  
However, a definition like $T can only appear once in a polymorphic function, otherwise you get the Error: "is already defined as polymorphic variable".

> This behavior can be shown with the info_flags POLYMORPH_MATCH and POLYMORPH_DEDUPLICATE defined in the _Compiler_ module.

## 22.2 Some other examples
### 22.2.1 T used more than once, and also used as a return type
See _22.2_polyproc2.jai_:
```c++
#import "Basic";

add :: (p: $T, q: T) -> T {     // (1)
    return p + q;
}

main :: () {
    i1: int = 1;
    i2: int = 2;
    i3 := add(i1, i2);  // (2)
    print("i3 is %\n", i3); // => i3 is 3

    f1: float = 1;
    f2: float = 2;
    f3 := add(f1, f2);  // (3)
    print("f3 is %\n", f3); // => f3 is 3

    i4: int = 5;
    f4: float = 7.3;
    // x := add(i4, f4);  // (4) 
/*
    Error: Number mismatch. Type wanted: int; type given: float.

    i4: int = 5;
    f4: float = 7.3;
    x := add(i4, f4);  // (4)

d:/Jai/The_Way_to_Jai/examples/22/22.2_polyproc2.jai:3,8: Info: ... in checking argument 2 of call to add.

    add :: (p: $T, q: T) -> T {     // (1)
*/
    
    f5: float = 7.3;
    i5: int = 5;
    // x := add(f5, i5); // (5) 
    // Error: Number mismatch. Type wanted: float; type given: int.
}
```

Here we have a procedure `add` defined in line (1), which specifies that p and q must be of the same type (represented as T), and that p defines that type. The proc also returns a value of that same type:
`add :: (p: $T, q: T) -> T`

In the call in line (2), i1 specifies that the type T is int. The signature of `add` implies that i2 must also be of type int. The same reasoning applies to line (3).
`add` returns the sum, which is of the same type (int or float) as the arguments.  

If q differs in type from p as in line (4), we get an error (again note the very clear message). i4 is an int, so at the call add(i4, f4), the compiler decides that T is int, so f4 must also be of type int, hence the error.
Line (5) shows the same error when the types are reversed.
If the same generic type is used multiple times like here, the '$' indicates what value (here the value for p) is decisive for error messages.

### 22.2.2 T as the type of an arrays items
See _22.3_polyproc3.jai_:
```c++
#import "Basic";

arr_sum :: (a: [] $T) -> T {   // (1)
    result: T;
    for a result += it;
    return result;
}

main :: () {
    arr: [4] int;
    arr[0] = 45;
    arr[1] = 42;
    arr[2] = 43;
    arr[3] = 100;
    print("The sum over the array of ints is: %\n", arr_sum(arr)); // (2) 
    // => The sum over the array of ints is: 230

    arr2: [4] float32;
    arr2[0] = 4.5;
    arr2[1] = 4.2;
    arr2[2] = 4.3;
    arr2[3] = 10.0;
    print("The sum over the array of floats is: %\n", arr_sum(arr2)); // (3) 
    // => The sum over the array of floats is: 23
}

```
This example shows in line (1) a procedure arr_sum which takes an array with item type T, and returns the sum of all items, which is also of type T:  
`arr_sum :: (a: [] $T) -> T`  
T is also used in the body of the proc.
At the call in line (2), a version of the proc is compiled for T == int, at line (3), a version of the proc is compiled for T == float32.

### 22.2.3 Example with pointers
See _22.4_polyproc4.jai_:
```c++
#import "Basic";

my_swap :: (a: *$T, b: *T) {  // (1)
    tmp := <<a;   
    <<a = <<b;
    <<b = tmp;
}

main :: () {
    a, b := 3, 5;
    print("Pre-swap: a is %, b is %\n", a, b);
    my_swap(*a, *b);    // (2)
    print("Post-swap: a is %, b is %\n", a, b);

    a2, b2 := "Hello ", "Sailor!";
    print("Pre-swap: a2 is %, b2 is %\n", a2, b2);
    my_swap(*a2, *b2);  // (3)
    print("Post-swap: a2 is %, b2 is %\n", a2, b2);

    // using the swapping procedures from Basic:
    n, m := 2, 3;
    Swap(*n, *m);       // (4)
    print("n is % and m is %\n", n, m); 

    n2 := 2; m2 := 3;
    n2, m2 = swap(n2, m2);  // (5)
    print("n2 is % and m2 is %\n", n2, m2);   
}

/*
Pre-swap: a is 3, b is 5
Post-swap: a is 5, b is 3
Pre-swap: a2 is Hello , b2 is Sailor!
Post-swap: a2 is Sailor!, b2 is Hello
n is 3 and m is 2
n2 is 3 and m2 is 2     
*/
```

This example shows in line (1) a procedure my_swap which takes two pointers each to a variable of type T, and swaps their values (a gets the value of b, and b gets the value of a):  
`my_swap :: (a: *$T, b: *T)`  
At the call in line (2), a version of the proc is compiled for T == *int, at line (3), a version of the proc is compiled for T == *string.

A swap is a common thing, that's why module _Basic_ has two versions of it, both polymorphic:  
(1)  This version called Swap is identical to our my_swap; it is called in line (4):
```
Swap :: (a: *$T, b: *T) {   
    tmp := << a;
    << a = << b;
    << b = tmp;
}
```
It uses pointers and << to a temporary value tmp; it is called in line (5).

(2)  A version called swap:
```
swap :: inline (a: $T, b: T) -> T #must, T #must {
    return b, a;
}
```
It uses a multiple return to swap the values, so it is called like `n2, m2 = swap(n2, m2);`. The #must after the return type T ensures that you use this form. Moreover, this is an inlined procedure for performance.

### 22.2.4 Example with several polymorphic types
See § 22.4.

**Exercises**
(1) Use the first Swap version from module _Basic_ to reverse a string (see reverse_string.jai).  
(2) Use swap from module _Basic_ to swap two person instances (see swap_persons.jai).  
(3) Write a polymorphic `find` routine that searches for a value in an array and reports its position, and -1 if the value is not found.  
(4) Write a global procedure `mult_and_add_with_constants` that takes two float64 a and b, and returns as result (1.5 * a + 4.6 * b). Then call this proc from a nested procedure `do_math_things` in main (see do_math_things1.jai).  
Now write a polymorphic version that has types $Ta for a and $Tb for b, returning a value of type Ta. Observe that it works like the previous version. Now change the type of a to float32. Explain what happens when you compile (see do_math_things2.jai)  
(5) Write a polymorphic proc display_xy that shows the x and y coordinates of a Vector2, Vector3 and Vector4 instances; take the Vector definitions from module _Math_ (see display_xy.jai).  
(6) Try to understand the error you get when compiling polymorph_err.jai  

## 22.4 The lambda notation =>
See _22.5_lambdas.jai_:
```c++
#import "Basic";

add100 :: (a: []int, proc: (int) -> int) -> []int {  // (1)
    result: [..]int;
    for a   array_add(*result, proc(a[it_index]));   // (2)
    return result;
}

main :: () {
  array_a := int.[1, 2, 3, 4, 5, 6, 7, 8];
  array_b := add100(array_a, (x) => x + 100);        // (3)
  // lam :: (x) => x + 100;                          // (4)
  // array_b := add100(array_a, lam);                // (5)
  print("%\n", array_b); // => [101, 102, 103, 104, 105, 106, 107, 108]
  defer array_free(array_b);
}
```

All procedures that we have encountered until now had a name, they were named procs. But in certain cases it can be useful to work with unnamed procs, so-called **anonymous functions** or **lambdas**. 

In line (3) we see that the proc add100 is called with the following expression as 2nd parameter:  
`(x) => x + 100`  
This is a lambda: for each x it works on, it returns x + 100.  
The proc `add100` has this signature (see line (1)):
`add100 :: (a: []int, proc: (int) -> int) -> []int`  
It defines its 2nd argument as a procedure with this signature:
`proc: (int) -> int`  
This is a proc that takes an int as argument and returns an int.
Our lambda above conforms to that signature.
In line (2), we loop over a (here array_a), apply our lambda as proc to each of its items, and adding these to the dynamic array result, which is returned after the loop.

To make the code more readable, we could have defined out lambda as a constant:  
`lam :: (x) => x + 100;`    (see line (4))
and call add100 like this:
`add100(array_a, lam)`      (see line (5))

Anonymous functions are useful for passing as arguments to other procedures, or return them from a procedure (example ??). Such procs, like `add100` above, are sometimes called **higher-order functions**.

> Unlike C++ or Rust, closures and capture blocks are not supported.

> Remark: `add100` constructs and returns a dynamic array.

**Exercise**
(1) Write a polymorphic proc that returns the count field of an input parameter. Then rewrite this proc as a lambda. Check it for static and dynamic arrays, and strings   (see poly_count.jai).


## 22.5 Baked arguments
The directive **#bake_arguments** lets us specify value(s) for argument(s) of a procedure, but leaving some arguments unspecified. The result is a proc with fewer arguments. Lets see an example:

See _22.6_baked_args.jai_:
```c++
#import "Basic";

add :: (a, b) => a + b;                 // (1)
add10 :: #bake_arguments add(a=10);     // (2)

mult :: (a: float, b: float) -> float {
    return a * b;
}

mult1 :: #bake_arguments mult(b = -9);  // (3)

main :: () {
  b := 20;
  c := add10(b);                      // (4)
  print("c is %\n", c);               // => c is 30
  print("mult1(2) is %\n",mult1(2));  //(5) => mult1(2) is -18
}
```

In line (1) we have a lambda `add`, in line (2) we 'bake in' the value 10 for argument a, so that we get a new proc called `add10`, which only needs one parameter for b.
This function is called in line (4); it effectively adds 10 to a given number, so it has specialized the original proc by baking in some arguments.
Similarly, in line (3) a new proc `mult1` is constructed by supplying a value for argument b in proc `mult`, and `mult1` is called in line (5).
#bake_arguments procedures are pre-compiled functions, they are not closures.
This is different from default values (see § 17.4), because a proc made with #bake_arguments is a different proc than the original one, whereas with default values there is only one procedure.

> So Jai has function currying through #bake_arguments, except function curry only happens at compile time. There is no runtime function currying in Jai. 

## 22.6 A map function
Using polymorphic arguments, we can construct functional-programming like map functions, that take for example an array and a function as arguments.

See _22.7_map.jai_:
```c++
#import "Basic";

map :: (array: [] $T, f: (T) -> $R) -> [] R {   // (1)
    result: [] R;
    result.count = array.count;
    result.data = alloc(result.count * size_of(R)); 
    for array result[it_index] = f(it);
    return result;
}

square :: (n: int) -> int { return n*n; }       // (2)

main :: () {
    N :: 5;
    a: [N] int;
    for 0..N-1 a[it] = it+1;
    print("a is %\n", a); // => a is [1, 2, 3, 4, 5]

    b := map(a, square);                        // (3)
    print("b is %\n", b); // => b is [1, 4, 9, 16, 25]
}
```

The code above presents an example of a polymorphic procedure `map` with several polymorphic types (called T and R): `map :: (array: [] $T, f: (T) -> $R) -> [] R`
It is also an example of a **higher-order function**, because the 2nd argument of map is itself a proc: `f: (T) -> $R`.  
The proc `square` in line (2) fulfills that signature. `map` is called in line (3) with `square` as a 2nd parameter. That proc is applied to each element of the array, returning a new array as result. 

> Remark: `map` constructs and returns a static array.
> In § 23.?? we'll see another version of map.

