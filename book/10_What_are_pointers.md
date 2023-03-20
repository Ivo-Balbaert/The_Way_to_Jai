# Chapter 10 – Working with pointers
**Don’t be afraid of pointers.**

Pointers are really needed to efficiently access memory, instead of having to move around big chunks of data in memory all the time.
To do low-level things and get the best performance, we need direct access to memory locations, just like C and other low-level languages. That's what pointers are for. Jai follows the C pointer model which allows pointers everywhere in code. Jai does not have smart pointers as in C++.

## 10.1 What is a pointer?
A pointer to a variable contains the memory address of that variable, it _points to_ the variable. So it is a  reference to a memory location, which can be on the stack or on the heap (see § 4D). If var is the variable,  then a pointer ptr to var is written with a * as follows: 

```c++
ptr = *var
```

* is sometimes called the **address-of** operator.  
You can visualize it as in the following image:  
![Pointer diagram](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/pointers.jpg)  
Here you see a pointer ptr in the blue box (left) which has a value 0x123. This is the memory address of the variable var in the green box (right). The variable has value 100. Notice that the pointer itself has an address, here 0x155.

> Often the name of a pointer starts with ptr for readability, but this is by no means mandatory.

The size of a pointer is always **8 bytes** (a u64 on a 64 bit machine), because it contains an address, which is 8 bytes on a 64 bit machine.

You can have pointers to any type of variable. Pointers can be used with primitive types like ints, floats or bools, but they will more often be used with composite types like strings, arrays and structs (see later for examples).

See *10.1_pointers.jai*:

```c++
#import "Basic";

main :: () {
    a : int = 42; 
    b : *int;     // (1A) declaration: b is a pointer to an integer.
    b = *a;       // (1B) initialize the pointer: point b at a.
    print("Value of a is %, address of a is %\n", a, *a);
    print("Value b points to is %, which is located at address of a: %\n", << b, b);
    // (2) => Value b points to is 42, which is located at address of a: 54_8d14_fb50
    print("Type of b is %\n", type_of(b)); // (3) => Type of b is *s64

    c := *a; // (4)
    print("Value c points to is %, which is located at address of a: %\n", << c, c);
    // => Value c points to is 42, which is located at address of a: 54_8d14_fb50
    << c = 108;
    print("Value c points to is now %\n", << c); // => Value c points to is now 108
 
    // null pointer:
    d: *u32; // (5)
    print("Value of d is %\n", d); // => Value of d is null
    // print("d is %\n", << d); // => program crashes at run-time!
    print("Type of null is %\n", type_of(null)); // (6) => Type of null is *void
   
    // void pointer:
    ptr: *void; // (7)
    print("ptr contains %\n", ptr); // => ptr contains null
    print("Value ptr is %\n", << ptr); // => Value ptr is void
   
    // (8) pointers to pointers:
    a2: int = 3;
    b2: *int = *a2;
    c2: **int = *b2;
    d2: ***int = *c2;
    print("%\n", << << << d2); // => 3 - prints out the value of a2, which is 3

    // New:
    n := New(int);      // (9)
    print("%\n", n);    // => 1d3_156b_0080
    print("%\n", type_of(n));    // (10) => *s64
    print("%\n", << n); // => 0
    free(n);            // (11)
}

/*
Value of a is 42, address of a is 54_8d14_fb50
Value b points to is 42, which is located at address of a: 54_8d14_fb50
Type of b is *s64
Value c points to is 42, which is located at address of a: 54_8d14_fb50
Value c points to is now 108
Value of d is null
Type of null is *void
ptr contains null
Value ptr is void
3
1d3_156b_0080
*s64
0
*/
```
In lines (1A-B) we first declare and then initialize a pointer to an int. b contains the memory address of a, in this example 9e_02cf_f898 (this varies with each execution!).

To obtain the value pointed to by a pointer (often called _dereferencing_ the pointer), use the **<<** notation on the pointer, like in C (see line (2)):

```c++
val = << ptr;   
```
In some cases dereferencing happens automatically when using the pointer itself, to simplify the syntax.  
From line (3) we see that the type of b is `*s64`.  
In line (4) we see how this type can be inferred with the shorter := notation. We also see that in line (4B) that you can change the value by using the dereference operator as left hand side:

```c++
<< ptr = new_val;   
```
The value at the address ptr points to is changed, but the address ptr contains stays the same.

What is the value of an uninitialized pointer (in other words:a pointer that doesn't yet have a memory address assigned to it)? Let's find out.  
In line (5) we see that the value of the uninitialized pointer d with type *u32 is **null**.  null means: d has no address to point to.  
So the default (zero) value of a pointer is null: after line (1A) b has value null. After line (1B) however b is no longer null, it now contains the address of the variable a.  

null is a value, so what is the type of null? This is answered in line (6), it is `*void`, which indeed says it is a pointer to nothing (void).
_The only thing you can assign null to is a pointer type_; you can't assign null to ints, structs, arrays, strings, or any other type.
> Only a pointer can be null.

You can even declare a variable ptr as a void pointer, like in line (7). This means ptr doesn't even know at this point what will be the type of variable it points to! A void pointer has no associated data type. It can hold the address of any type and can be type-casted to any type. void pointer has the same functionality as in C.

In line (9), we make a New(int). `New` is a procedure defined in module _Basic_ that can take any type, construct an instance of it, and return a pointer to it (see line (10)).
New allocates memory on the heap, so you have to free it yourself, as done in line (11).

> A pointer to data of unknown type has type *void.  

*void can be casted to any type, and it has the same functionality as in C. 

Taking a pointer and then dereferencing cancels each other out:
```
a : int = 5;
b := <<*a; // b also has the value 5
```

Some languages (like Java) have _references_ instead of pointers. References are used to refer to an existing variable with another name whereas pointers are used to store the address of a variable. Jai has no references, only values and pointers.


## 10.2 Pointers to pointer
We saw that a pointer has also an address, so nothing prevents you from having a pointer to a pointer. This can even be several levels of _indirection_ deep, as lines (8) and following show. 
To get to the value of a three-level pointer, you have to dereference three times:  

```c++
    d2: ***int = *c2;
    print("%\n", << << << d2); // => 3, the value of a2
```

## 10.3 Dereferencing a null pointer
**Danger zone: attempting to dereference a null pointer makes the program crash at run-time.**  
When this happens in a program, there clearly is a bug, because the pointer didn't point to any value. So Jai's behavior is to stop the program and print out a stack trace where the problem occurred.

See *10.2_dereference_a_null_pointer.jai*:

```c++
#import "Basic";

main :: () {
    // the explicit null assignment is not needed because null is the zero-value for pointers  
    // c : *int = null;
    c : *int;
    // ... lots of code
    // print("%\n", c);    // (1) => null
    // assert(c != null);  // (2) => Assertion failed!

    print("%\n", << c);    // (3) program compiles but crashes at run-time with stack trace
}

// #run main();             // (4)
```

Executing the above program on Windows gives the following output:

```
The program crashed. Printing the stack trace:
handle_exception                  c:\jai\modules\Runtime_Support_Crash_Handler.jai:211
... (skipping OS-internal procedures)
get_s64_from_void_pointer         c:\jai\modules\Basic\Print.jai:152
print_integer                     c:\jai\modules\Basic\Print.jai:358
print_item_to_builder             c:\jai\modules\Basic\Print.jai:757
print_to_builder                  c:\jai\modules\Basic\Print.jai:1126
print                             c:\jai\modules\Basic\Print.jai:390
main                              d:\Jai\The_Way_to_Jai\examples\10\10.2_dereference_a_null_pointer.jai:7
```

The call to `get_s64_from_void_pointer` tells you enough on what went wrong.

On Linux you get the following output:
```
Segmentation fault. The faulty address is 0x0, from 0x234f01.
./10(get_s64_from_void_pointer_700001078+0xf1) [0x234f01]
./10(print_integer_700001391+0x271) [0x225d21]
./10(print_item_to_builder_70000199d+0x7e4) [0x221d64]
./10(print_to_builder_700001d9a+0xdc5) [0x22ee65]
./10(print_700001426+0x13b) [0x227e4b]
./10(__program_main+0xf7) [0x22c6c7]
./10(main+0xb2) [0x227232]
/lib/x86_64-linux-gnu/libc.so.6(+0x29d90) [0x7f2db7d13d90]
/lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0x80) [0x7f2db7d13e40]
./10(_start+0x25) [0x236155]
```
Again, the first two lines tell you enough.

A program that crashes at run-time when used by clients is a developer's nightmare. So, apart from extensive testing to find such bugs, what can we do else to avoid or trace them?

If you can track the bug to a certain part of the code, you can try to print out the pointer to see if it equals null, as in line (1):   
`print("%\n", c); // (1) => null`
Or better, use an `assert` as in line (2):
which gives the output:  

```
d:/Jai/The_Way_to_Jai/examples/10/10.2_dereference_a_null_pointer.jai:9,3: Assertion failed!

Stack trace:
c:/jai/modules/Preload.jai:333: default_assertion_failed    
c:/jai/modules/Basic/module.jai:74: assert
d:/Jai/The_Way_to_Jai/examples/10/10.2_dereference_a_null_pointer.jai:9: main
```

The program crashes in line (3).
An even smarter way is to run the program at compile-time with #run main(), as in line (4).
This gives you almost the same output as when it crashed at run-time, but now you're the only one to see it ;-), and you get the same info:

```
This crash happened during compile-time execution of Workspace #2, so it may be a bug
in the user-level program, not in the compiler.

Here's a stack trace of the user-level program:

get_s64_from_void_pointer (c:/jai/modules/Basic/Print.jai:152,23)
....
```

In a later chapter on Debugging (see § 20), we'll see how you can pinpoint the bug even closer.

## 10.4 Dangling pointers
See *10.4_dangling_pointers.jai*:

```c++
#import "Basic";

main :: () {
  a := New(int);
  print("%\n", a);    // => 14a_f407_6710
  print("%\n", << a); // => 0
  << a = 5;
  print("%\n", << a); // => 5

  free(a);            // (1)
  print("%\n", << a); // => 5
  print("%\n", a);    // => 14a_f407_6710
  a = null;           // (2)
  print("%\n", a);    // => null
}
```

The variable a in the code snippet above is of type *s64, default initialized to 0. Then we give it the value 5. In line (1) its memory is freed, at which point it is called a _dangling pointer_: it should no longer point to a value memory location. However in Jai it still knows its address and contained value. If you really want to be sure the value has been erased, you can assign the `null` value to the pointer, as in line (2). 

## 10.5 Casting to pointer types
Because a pointer type is like any other type, you can cast a pointer variable to a pointer type, like this:
```
ptr1 := cast(*int) ptr;
```

However when ptr does not point to an int variable, this will either give an unexpected result, or cause your program to crash.