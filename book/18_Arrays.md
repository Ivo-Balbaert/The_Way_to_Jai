# Chapter 18 - Arrays

Whenever you need a series of items of the same type that are packed together in memory for maximum performance, use an **array**.
Arrays are the work horses of Jai.
Because in almost all cases all items of an array are of the same type, an array is called a _homogeneous_ type. But if you really would want to, you can make an array with item type Any.  
Jai supports both static (fixed) and dynamic arrays, and array views.
Module _Preload_ defines an array type as:  
```c++
Array_Type :: enum u32 {
        FIXED     :: 0;
        VIEW      :: 1;
        RESIZABLE :: 2;
    } 
```

## 18.1. Array literals
See _18.1_array_literals.jai_:

```c++
#import "Basic";

Good_Fruit :: enum {
    APPLE      :: 1;
    BANANA     :: 2;
    BANANANA   :: 3;
    KIWI       :: 4;
    GRAPE      :: 5;
    STRAWBERRY :: 6;
}

main :: () {
    numbers := int.[1, 3, 5, 7, 9]; // (1) array literal
    print("count is %, and data is %.\n", numbers.count, numbers.data); // (2)
    // => count is 5, and data is f8_01ba_f828.
    print("%\n", type_of(numbers)); // (3) => [5] s64
    print("%\n", type_of([4]int) == type_of([5]int)); // (4) => true because both are Type
    // empty array literal:
    emp := string.[]; // (5)
    print("% - %\n", emp.count, emp.data); // => 0 - null
    // arr1 : [4]float = float.[10.0, 20.0, 1.4, 10.0]; // (6)
    // shorter:
    arr1: = float.[10.0, 20.0, 1.4, 10.0];
    print("arr1 is % \n", arr1); // (7) => arr1 is [10, 20, 1.4, 10]
    print("The 3rd item is %\n", arr1[3]); // (8) => The 3rd item is 10
    arr1[3] = 2.71;              // (9)
    print("arr1 is % \n", arr1); // => arr1 is [10, 20, 1.4, 2.71]
    words := string.["The", "number", "is", "odd."];
    print("words is %\n", words); // => words is ["The", "number", "is", "odd."]
    what_i_want :: Good_Fruit.[.APPLE, .GRAPE, .KIWI, .BANANANA, .APPLE]; // (11)

    for numbers print("numbers[%] = %\n", it_index, it); // (11)
    /* =>
    numbers[0] = 1
    numbers[1] = 3
    numbers[2] = 5
    numbers[3] = 7
    numbers[4] = 9
    */
    print("\n");
}
```

In line (1) we define an int array literal, in general the syntax is: type.[item1, ..., itemn]
Every array has a `count` and `data` field (see ??): the count gives the number of items in the array, and data is a pointer to the 1st item.  
As we see from line (3), it's type is `[5] s64`, [] is the typical array notation, 5 is the count (or size), and s64 is the items type, which is equivalent to int. This type shows that the array literal is in fact a **static array**. Line (4) shows that [4]int and [5]int have the same type Type. Empty array literals will have their count pointer not set to 0; their data pointer is guaranteed to be null.
In line (6) we see a typed declaration of a static array, which is then initialized to an array literal. The definition can include the complete type, but this can also be inferred. In line (7) we see that an array can simply be printed out as a whole.
Lines (8) and (9) tell us that we can read out the i-th item as `arr[i]`, and change its value with `arr[i] = new_val`.
In line (10) an array literal is created with the values of an enum.

## 18.2. For loop over arrays
Looping over an array while processing each item is made extremely easy with a for-loop, which works for all kinds of arrays. From line (11) we see that we still have the `it` variable, which takes in the value of the item in each iteration. But now we have also the `ìt_index` variable, which gives for each item its index position in the array, starting from 0 like in all C-like languages. See § 18.3, ??  for more examples.

## 18.3. Static arrays
See _18.2_static_arrays.jai_:

```c++
#import "Basic";

Vector3 :: struct {
    x, y, z : float;
}

main :: () {
    a : [4]u32;      // (1) A static array of 4 u32 integers.
    b : [30]float64; // An array of 30 float64's.
    arr1 : [50]int;  // array of 50 integers
    i := 5;
    print("%-th item is: %\n", i, arr1[i]); // (2) => 5-th item is: 0
    print("The array a is by default initialized to %\n", a); // (3)
    // => The array a is by default initialized to [0, 0, 0, 0]

    arrf : [4]float;    // (4)
    arrf[0] = 10.0; 
    arrf[1] = 20.0;
    arrf[2] = 1.4;
    arrf[3] = 10.0;
    arrf2 := float.[10, 20, 1.4, 10]; // (4B)
 
    N :: 100;
    static_array : [N]int;      // (5) static array of size N
    print("static_array has the size: %\n", static_array.count);
    // => static_array has the size: 100
    // Filling an array:
    for 0..static_array.count-1 {  // (6)
        static_array[it] = it;
    }
    print("static_array has as data: %\n", static_array);
/* static_array has as data: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 
 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99] */   
    print("It's size is: % bytes\n", size_of(type_of(static_array))); 
    // => It's size is: 800 bytes

    // print("% \n", static_array[100]); // (6B)
    // => Error: Subscript is out of array bounds. 
    // (The attempted index is 100, but the highest valid index is 99.)
    N2 :: 100;
    // print("% \n", static_array[N2]); // (6C)
    // => Error: Subscript is out of array bounds. 
    n := 100;
    // print("% \n", static_array[n]); // (6D)
    // run-time => Array bounds check failed. ...

    M :: 4;
    arr2 : [M]Any;      // (7)
    arr2[0] = "Hello";
    arr2[1] = 42;
    arr2[2] = Vector3.{1, 2, 3};
    print("arr2 is %\n", arr2);
    // => arr2 is ["Hello", 42, {1, 2, 3}, (zero-initialized Any)]

    if arr2 {           // (8)
        print("arr2 is NOT empty\n"); // => arr2 is NOT empty
    }

     // Heap-allocated arrays:
    arr_heap := NewArray(4, float); // (9) will heap-allocate an array of 4 floats; from Basic
    print("%\n", arr_heap); // => [0, 0, 0, 0]
    // ...
    defer array_free(arr_heap);   // (10)

    // Allocation with New:
	arr_heap2 := New([3] int);    // (11)
    print("% \n", arr_heap2);     // => 202_bdf0_8d50
    defer free(arr_heap2);        // (12)
	for 0..arr_heap2.count-1 { (<<arr_heap2)[it] = it * it; }   // (13)
	print("arr_heap2: %\n", << arr_heap2);  // (14) => arr_heap2: [0, 1, 4]
}
```

Array literals are in fact static (or fixed-size) arrays. Static arrays are arrays where the size is known at compile time.  
They are declared like this:  `arr_name: [count]type`    
See some concrete examples in lines (1) and following. The items of an array are by default initialized to their zero-value (see line (3)). The example starting in line (4) shows that the items can be initialized one by one, but if the values are constant, we know that it can be done shorter with an array literal. The size (or count) can also be a constant, as indicated in line (5).  
The indices of an array arr range from 0 to `arr.count - 1`. 

### 18.3.1 Setting up an array with a for loop
So you can make a for loop over this range:  `for 0..arr.count-1 { ... }` and initialize the array using the `it` variable as in line (6). (Try out if `for arr` works here).  
The size in bytes of the i-th item is given by `size_of(arr[i])`.
Line (7) indicates that you can use Any as the array type if you want to make an array that contains items of different types (The syntax `arr2 = Any.["Hello", 42, Vector3.{1, 2, 3}];` doesn't work here).

### 18.3.2 Compile-time and run-time bounds check.
If the size of the array and the index are known at compile time a compile-time bounds check will be performed: see line (6B), the error is:
** Error: Subscript is out of array bounds. (The attempted index is 100, but the highest valid index is 99.) **
This also works for a constant (6C), but not for a variable like in (6D). Then the code compiles, but we get a run-time panic:
_Array bounds check failed. (The attempted index is 100, but the highest valid index is 99). Site is d:/Jai/The_Way_to_Jai/examples/18/18.2_static_arrays.jai:46.        
Panic.
The program crashed. Printing the stack trace:
handle_exception                  c:\jai\modules\Runtime_Support_Crash_Handler.jai:211
... (skipping OS-internal procedures)
debug_break                       c:\jai\modules\Runtime_Support.jai:8
my_panic                          c:\jai\modules\Runtime_Support.jai:136
__array_bounds_check_fail         c:\jai\modules\Runtime_Support.jai:185
main                              d:\Jai\The_Way_to_Jai\examples\18\18.2_static_arrays.jai:46_

### 18.3.3 Using an array as a boolean
Line (8) shows that we can use an array as a bool (condition): an array that is not empty is true.

### 18.3.4 Allocating an array on the heap
We can force the compiler to allocate an array on the heap with the **NewArray** procedure from module _Basic_: `arr_heap := NewArray(4, float);` (see line (9))
Releasing the memory when the array is no longer in use must be done by the developer with defer **array_free** (see line (10)).  
A more familiar and consistent syntax using **New** and **free** is shown in line (11):  
`arr_heap2 := New([3] int);`
For releasing the memory, simply use `defer free(arr_heap2);`.
The difference with NewArray is that New returns a pointer. To print the array, you must now dereference the pointer, as in line (14).  
Also use << to change any item in the array, as iin line (13): `(<<arr_heap2)[it] = ...`

_Performance_:
Arrays are built into the compiler so that they are very fast. The array items can be very efficiently (contiguously) stored, packed together on the stack for small arrays.

## 18.4. Dynamic arrays
The static arrays we've seen until now were fixed in size: after the size is known to the compiler, they cannot be enlarged, so no items can be added.
Jai (unlike C) also has **dynamic** or **resizable arrays** , where the size is not known at compile-time and can grow (change) at runtime. Their items as well as the arrays size are stored in heap memory. 

See _18.3_dynamic_arrays.jai_:

```c++
#import "Basic";

main :: () {
  arrdyn : [..]int;          // (1) dynamic array of integers.
  another_array : [..]int;      
  b : [..]string;            // (2) dynamic array of strings.

  // clean up memory
  defer array_free(arrdyn);     // (3)
  defer free(*another_array);   // (4)
  defer free(*b);   // 
   
  array_add(*arrdyn, 5);  // (5) Add 5 to the end of arrdyn
  array_add(*arrdyn, 9);  // Add 9 to the end of arrdyn
  array_add(*arrdyn, 13); // Add 13 to the end of arrdyn
  print("arrdyn is: %\n", arrdyn); // => arrdyn is: [5, 9, 13]
 
  print("%\n", array_find(arrdyn, 5));  // (6) => true -  look for 5 in arrdyn

  for arrdyn {
    if it == 5 remove it;       // (7)
  }
  print("arrdyn is: %\n", arrdyn); // => arrdyn is: [13, 9]

  print("another_array is: %\n", another_array); // => another_array is: []
  array_copy(*another_array, arrdyn); // (8) copy arrdyn into another_array
  print("another_array is: %\n", another_array); // => another_array is: [13, 9]

  array_reset(*arrdyn);  // (9) Reset (empties) arrdyn
  print("arrdyn is: %\n", arrdyn); // => arrdyn is: []

  // Filling an array: // better version in array_for.jai
  N :: 100;
  for 0..N-1  array_add(*arrdyn, it);  // (10)

  M :: 50;
// more performant way:
  array_reserve(*arrdyn, M); // (11) - Reserve 50 items!
  for 1..M array_add(*arrdyn, it);  // 
}
```

In the code above lines (1)-(2) declare to dynamic arrays, with the typical syntax:  
`[..]type`  
To release memory, you can either use the **array_free** proc (line (3)), or the **free** proc which needs a pointer to the memory (line (4)).
To add one item at a time, use the **array_add** proc with a pointer to the array, and the item as arguments (see lines (5) and following).

### 18.4.1 Useful procs for dynamic arrays

We check if an item is present in the array in line (6), use **array_find**, which returns true if the item is found, false otherwise.
Removal of items within a dynamic array is done with the **remove** proc, as in line (7): we want to remove the item with value 5, so we loop over the array, if-test with it ==, and if true, remove it. This proc is used to safely remove elements while iterating through an array, which is often a problem in other languages. 
Notes:
- This proc does not work for fixed-size arrays!  
- This proc does an unordered remove, the removed item is replaced with the last item.  

To copy an array into another array, use **array_copy**, as in line (8).
To empty a dynamic array completely, use the **array_reset** proc, as in line (9).

Notice that whenever you need to change an array in a proc, you need to give it a pointer to the array. A proc like array_find doesn't need that, because it only reads through the array.  
In line (10) we fill up a dynamic array in a simple for loop, but not in an efficient way: at each array_add call, a memory location must be acquired for the new item. It is far better to use **array_reserve** as in line (11). Here you estimate how many items your array will need,giving this as a parameter to the proc, so that this initial memory can be pre-allocated in its entirety from the start.  

### 18.4.2 Internal definition of a dynamic array
This is found in module _Preload_; again it is a struct, which takes up 40 bytes:

```c++
Resizable_Array :: struct {
    count      : s64;  // Signed so that if we do for 0..count-1 it works...
    data       : *void;
    allocated  : s64;        // (1)
    allocator  : Allocator;  // (2)
}
```

`allocated` in (1) tells how many bytes are reserved at the moment.  
`allocator` in (2) is a pointer to the memory allocation mechanism we use for this particular array (see ??).


## 18.5. Array views
See _18.4_array_views.jai_:

```c++
```

An **array view** is like the name says, a view on an underlying array in memory; so it uses that memory, it allocates no memory of its own. In lines (1)-(3) above, we define array views arrv, arrv2 and v (a view on a dynamic array). They are all of type **[]int**  
_Preload_ defines an array view as:  
```c++
Array_View_64 :: struct {
    count     : s64;  // Signed so that if we do for 0..count-1 it works...   
    data      : *u8;
} // takes up 16 bytes
```
(There are also smaller array_views that use relative pointers.)

## 18.5.1 Changing the view
In line (1B) we show that you can change the underlying array by manipulating the view with the normal index notation.
`data` is a pointer to the base data in memory. So by adding an offset to this pointer, and changing the count of the view, the view changes as we want (see line (4)). We can take a slice of the base array.  
This is the first example of pointer arithmetic we encounter in Jai. Needless to say you must be very careful to stay within the memory limits of the base array.


## 18.6. For-loops over an array

## 18.7. Multidimensional

## 18.8. Passing an array to a function



----------------------------------------------------------
## 18. Variable number of arguments ..
See _18.5_var_args.jai_:

```c++
#import "Basic";

var_args :: (args: ..int) {  // (1)
  print("args = %\n", args); // (1B) => args = [1, 2, 3, 4, 5, 6, 7]
  print("The type of args is %\n", type_of(args));  // (1C) 
  // => The type of args is [] s64
  print("The number of variable arguments is %\n", args.count);  // (2)
  // => The number of variable arguments is 7
}

proc1 :: (s: string, args: ..Any) {  // (3)
    print(" s is %\n", s);           // => s is "Hello"
    for args {                       // (4)
        print("% - ", it);
    }
}

main :: () {
    var_args(1, 2, 3, 4, 5, 6, 7); // (5)
    proc1("Hello", "John", "Gertrude", "Olaf", 42);
    // => John - Gertrude - Olaf - 42 -

  	arr := int.[1, 2, 3, 4, 5, 6, 7]; // (6A) 
  	var_args(..arr);        // (6B) 
  	var_args(args = ..arr); // same as line above
}
```

A variable number of arguments for a procedure can be specified  in the proc header's parameter-list with `..` like in line (1).  
In general:  `(arg1 = type1, arg2 = type2, ..., args: ..type )`  
Use a normal parameter list to pass arguments to a variable arguments function, as in line (5).
Printing out the args argument in line (1B), we see that it is in fact an array: all variable arguments are stored in an array, here with type [] s64.  

The definition above seems to imply that all variable arguments have to be of the same type. You can specify this, but you can also use the Any type as in line (3):  `args: ..Any`  
so that in fact any type is allowed.  

In order to avoid ambiguity, the variable number argument must be the last in the argument list.

Because args is an array, the exact number of arguments is given by `args.count` (line(2)) and you can loop over them with `for args` (line(4)).

### 18.1 Passing an array as a variable argument
In line (6B) we pass the array arr defined in line (6A) to proc var_args like this:  
`var_args(..arr);` or `var_args(args = ..arr);`
This is in fact the same as calling `var_args(1,2,3,4,5,6,7);`; we say that the array items are _spread_ over args.

### 18.2 Named variable arguments proc
A named variable and (some) default arguments proc would be defined like:
`varargs_proc :: (s:= "Fred", f:= 2.5, v: ..string) { }`

called as for example in line (7A):
`varargs_proc(f = 3.14, s = "How", v = "are", "you", "tonight?");`

After the varargs name v is used, all parameters are going into the variable argument.
You can spread parameters with a name as well as in line (7B): 
`varargs_proc(f = 5, 3.14 = "How", v = ..array);`

### 18.3 The print procedure uses ..
See _18.6_print_proc.jai_:

```c++
#import "Basic";

main :: () {
    x, y, z, w := 1, 2, 3, 4;
    print("Hello!\n"); // (1) => Hello!
    print("x=%\n", x); // => x=1
    print("x=%, y=%, z=%, w=%\n", x, y, z, w); // => x=1, y=2, z=3, w=4
}
```

In the above example as well as in § 5.7, we see that `print` can accept a variable number of arguments.
This is because `print` is defined in module _Basic_ file _Print.jai_ as:  
`print :: (format_string: string, args: .. Any, to_standard_error := false) -> bytes_printed: s64 {...}` 

We see it has a variable number argument `args`, which makes this possible.


