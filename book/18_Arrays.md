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
    // numbers2 := .[1, 3, 5, 7, 9]; // (1B) => Error: This declaration is bound to a struct or array literal that did not specify its type, so there is no way to know its type.
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
    for words   print(" %. %\n", it_index, it);
    /*
    0. The
    1. number
    2. is
    3. odd.
    */
}
```

In line (1) we define an int array literal, in general the syntax is: type.[item1, ..., itemn]
Line (1B) shows that indicating the type as prefix is necessary.
Every array has a `count` and `data` field (see § 18.4.2 and 18.5): the count gives the number of items in the array, and data is a pointer to the 1st item.  
As we see from line (3), it's type is `[5] s64`, [] is the typical array notation, 5 is the count (or size), and s64 is the items type, which is equivalent to int. This type shows that the array literal is in fact a **static array**. Line (4) shows that [4]int and [5]int have the same type Type. Empty array literals will have their count pointer not set to 0; their data pointer is guaranteed to be null.
In line (6) we see a typed declaration of a static array, which is then initialized to an array literal. The definition can include the complete type, but this can also be inferred. In line (7) we see that an array can simply be printed out as a whole.
Lines (8) and (9) tell us that we can read out the i-th item as `arr[i]`, and change its value with `arr[i] = new_val`.
In line (10) an array literal is created with the values of an enum.

**Typing of array literals**
When passed to or returned from a proc where the array type is indicated, array literals can be untyped like .[1, 2, 3, 4, 5], otherwise they have to be typed.

## 18.2. For loop over arrays
Looping over an array while processing each item is made extremely easy with a for-loop, which works for all kinds of arrays. From line (11) we see that we still have the `it` variable, which takes in the value of the item in each iteration. But now we have also the `ìt_index` variable, which gives for each item its index position in the array, starting from 0 like in all C-like languages. See § 18.3.1 and 18.6  for more examples.

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

  // filling an array:
  N :: 100;
  for 0..N-1  array_add(*arrdyn, it);  // (10)
  // for i: 0..N-1  array_add(*arrdyn, i); // alternative for (10)

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
#import "Basic";

main :: () {
  static_array := int.[0,1,2,3,4,5];
  arrv : []int = static_array;    // (1)
  print("%\n", arrv.count); // => 6
  print("%\n", arrv[3]);    // => 3
  arrv[3] = 42;
  print("%\n", static_array); // (1B) => [0, 1, 2, 42, 4, 5]
  arrv2: []int = int.[1,2,3,4,5]; // (2)
  print("arrv2 is %\n", arrv2); // => arrv2 is [1, 2, 3, 4, 5]
  a: [..] int;
  for 1..7 array_add(*a, it);  
  v: [] int = a;                  // (3)
  print("v is %\n", v); // => v is [1, 2, 3, 4, 5, 6, 7]

  // create a view on a part of an array, for example from index 2 to 4: [3, 4, 5]
  v.data += 2;
  v.count = 3;
  print("v is %\n", v);  // (4) => v is [3, 4, 5, 6, 7]
  // print("%\n", arrv[6]); // (5)
  // => Array bounds check failed. (The attempted index is 6, but the highest valid index is 5).
}
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
Array views are also bounds-checked, but at run-time: see line (5). The program crashes and a stack trace is printed.

### 18.5.1 Changing the view and the base array
In line (1B) we show that you can change the underlying array by manipulating the view with the normal index notation.
`data` is a pointer to the base data in memory. So by adding an offset to this pointer, and changing the count of the view, the view changes as we want (see line (4)). We can take a slice of the base array.  
This is the first example of pointer arithmetic we encounter in Jai. Needless to say you must be very careful to stay within the memory limits of the base array.

Why are array views important? Besides getting an alternative look on an array without consuming memory, they also allow us to write procedures in a more general way: both static and dynamic arrays are auto-casted to array views if the array view is a parameter, see § 18.8 


### 18.5.2 Misuse of array views with dynamic arrays
See _18.8_array_view_misuse.jai_:

```c++
#import "Basic";

main :: () {
        a: [..] int;
        for 1..10 array_add(*a, it);  // Just fill a with some values.
        v: [] int = a;                // Make a view onto a.
        for 1..10 array_add(*a, it);  // (3) Add more items to a.

        for a print("% - ", it);
        // (4) => 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 
        print("\n");
        for v print("% / ", it);       // (5) 
        // => 2487748255840 / 2487748277696 / 3 / 4 / 5 / 6 / 7 / 8 / 9 / 10 /
}
```
Carefully look at the code above: we define and populate a dynamic array a, then take a view v on it, and then add more items to a. Now if we print out a in (4), everything is ok, but if we print out v in (5), we see the result is bad: it only sees 10 items, and the first two are even corrupt data!  
The reason for this is that any time you call `array_add` on a, it might move its memory. If you do this after assigning the view v, a problem will arise because since 'a' was possibly moved, v points to the wrong memory location!  
> So only take an array view on a dynamic array when this will no longer be resized.

## 18.6. For-loops over arrays: more examples
See _18.5_array_for.jai_:

```c++
#import "Basic";

main :: () {
    N :: 4;
    static_array: [N]int = .[0, 1, 2, 3]; 
    dynamic_array : [..]int;
    array_view : []int = static_array;

    for static_array   static_array[it_index] = it;
    // for 0..static_array.count-1  static_array[it_index] = it; // (1) => Error: Undeclared identifier 'it_index'.
    for static_array print("SA item[%] = % - ",  it_index, it);
    // => SA item[0] = 0 - SA item[1] = 1 - SA item[2] = 2 - SA item[3] = 3 - 
    print("\n");
   
    array_add(*dynamic_array, 4);
    array_add(*dynamic_array, 5);
    array_add(*dynamic_array, 6);
    array_add(*dynamic_array, 7);
    for dynamic_array   dynamic_array[it_index] = it;  // (2)
    for dynamic_array print("DA item[%] = % - ", it_index, it);  
    // => DA item[0] = 4 - DA item[1] = 5 - DA item[2] = 6 - DA item[3] = 7 -
    print("\n");

    for array_view   array_view[it_index] = it;   
    for array_view print("AV item[%] = % - ", it_index, it);
    // => AV item[0] = 0 - AV item[1] = 1 - AV item[2] = 2 - AV item[3] = 3 -
    print("\n");
    
    for n: static_array     print("% - ", n); // (2) => 0 - 1 - 2 - 3 
    // for n: static_array     print("% - ", it); // => Error: Undeclared identifier 'it'.
    print("\n");

    for value, index: dynamic_array {         // (3)
        print("DynArray[%] = % - ", index, value);
    }
    // => DynArray[0] = 4 - DynArray[1] = 5 - DynArray[2] = 6 - DynArray[3] = 7 -
    print("\n");

    // changing an array:
    arr := int.[1, 2, 3, 4, 5];
    // take all the values in an arr and square the items
    for *elem: arr {            // (4)
        val := <<elem;
        <<elem = val * val; 
    }
    print("arr is: %\n", arr); // => arr is: [1, 4, 9, 16, 25]

    // reversing the iteration:
    static_array := int.[1, 2, 3, 4, 5];
    for < static_array  print(" % ", it);  // (5)
    // => 5  4  3  2  1
} 
```

We saw in § 18.2 how easy it is to write a for loop over an array and that we now have `it_index` for the position and `it` for the item's value at our disposal.
In the above code we demonstrate that a for loop over the array works for all three array types. However as shown in line (1), `it_index` is NOT known when a for as a range on 0..arr.count-1 is used, contrary to `it` which is known.  
The for-loop in line (2) for the dynamic array wouldn't print out anything, if it where not for the `array_add` statements before, that create the dynamic array items.
You can replace the in-built iteration variable `it` with your own as in line (2):  
`for n: static_array`   
but then `it` is no longer available.

### 18.6.1 Named index and value
You can also replace both `it` and `it_index` with your own variables as in line (3):
`for value, index: array_view`      // in that order!

### 18.6.2 Changing an array by iterating with a pointer
The it variable is read-only, it cannot be used to change the items of an array (try it out!). Look at the code starting in line (4):  
- `for *elem: arr {}` we loop over the array with an iteration variable that is a pointer
- `<<elem = val * val` inside the loop, we dereference that pointer and assign a new value to it.
This can even be done more succinct as shown in line (4B). 

So iteration can be done by pointer or by value, and is built-in at a very low level: the compiler understands arrays in depth, and so does the debugger.

**Exercise**
Double the values of an array in a for loop. Then do the same in a while loop and see what is easiest.  
(see array_double.jai)

### 18.6.3 Reversing a for loop with <
In line (5) we see that simply writing a `for <` reverses the iteration order.


## 18.7. Multidimensional arrays
All the arrays we've encountered until now were 1-dimensional, with an index going from 0 to array.count-1
But for example when writing a game in 2D or 3D, we easily need objects with that number of dimensions. So how do we define these in Jai?

See _18.6_multidim.jai_:

```c++
#import "Basic";

main :: () {
    a2 : [4][4] float;    // (1) - 2D static array
    print("a2 is: %\n", a2); // =>
//  a2 is: [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
    b2 : [4][4][4] float; // 3D - static array
    print("b2 is: %\n", b2); // =>
// b2 is: [[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
//         [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], 
//         [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], 
//         [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]]  
    array3: [2][2] int = .[int.[1,0], int.[0,3]];
    print("array3 is: %\n", array3); // => array3 is: [[1, 0], [0, 3]]
    array4 := [2] int.[int.[1,0], int.[0,3]];

    luminance_color_ramp := ([3] float).[.[0,0,0],  // black
                                         .[0,0,1],  // blue
                                         .[0,1,1],  // cyan
                                         .[0,1,0],  // green
                                         .[1,1,0],  // yellow
                                         .[1,0,0],  // red
                                         .[1,0,1],  // magenta
                                         .[1,1,1]]; // white
    print("type_of(luminance_color_ramp) is %\n", type_of(luminance_color_ramp));
    // => type_of(luminance_color_ramp) is [8] [3] float32

    for luminance_color_ramp    print("% % % / ", it[0], it[1], it[2]); // (2)
    // => 0 0 0 / 0 0 1 / 0 1 1 / 0 1 0 / 1 1 0 / 1 0 0 / 1 0 1 / 1 1 1 /

// do they need to be freed, probably they are in stack ?
    array_free(a2);
    array_free(b2);
    array_free(array3);
    array_free(luminance_color_ramp);
}
```
Lines (1) and following show some examples of declaration and initialization. Line (2) prints out a 2D-array within a for loop.

## 18.8. Passing an array to a procedure
See _18.7_array_proc.jai_:

```c++
#import "Basic";

print_int_array :: (arr: [] int) {
    print("Array has size % - ", arr.count);
    for arr print("arr[%] = % / ", it_index, it);
    // for i: 0..arr.count-1 {
    //     print("arr[%] = % / ", i, arr[i]);
    // }
    print("\n");
}

add_numbers :: (numbers: [] int) -> int {   
    sum := 0;
    for numbers sum += it;
    return sum;
}

main :: () {
    N :: 4;
    static_array: [N]int = .[0, 1, 2, 3]; 
    // Printing an array:
    print_int_array(static_array); // (1)
    // => Array has size 4 - arr[0] = 0 / arr[1] = 1 / arr[2] = 2 / arr[3] = 3 / 

    dynamic_array : [..]int;
    defer free(*dynamic_array);
    array_add(*dynamic_array, 4);
    array_add(*dynamic_array, 5);
    array_add(*dynamic_array, 6);
    print_int_array(dynamic_array); // (2)
    // => Array has size 3 - arr[0] = 4 / arr[1] = 5 / arr[2] = 6 /

    sum := add_numbers(.[1, 2, 3, 4, 5]); // (3)
    print("sum is %\n", sum); // => sum is 15
    sum = add_numbers(static_array);
    print("sum is %\n", sum); // => sum is 6
    sum = add_numbers(dynamic_array);
    print("sum is %\n", sum); // => sum is 15
}
```

A function can take an array (or many) as argument. 
The argument array is typed like an array view: `arr: []int` 
A pointer to the array as well as its size are passed to the function.  
See as first example the proc _print_int_array_ . In line (1) it is called with a static array as parameter, and in line (2) with a dynamic array. _Static and dynamic arrays are automatically converted to an array view when passed to a proc with such an argument_.  
This is extremely useful: array views let us do stuff like calling the same proc for different-sized arrays, like in the previous example.  
Another example is the _add_numbers_ proc (called in line (3) and following), which takes an array view as an argument and returns the sum of its items.

### 18.8.1 C's biggest mistake
C's biggest mistake is: treating arrays as pointers. When passing an array to a function in C, only the pointer is passed, so that the size information is lost. This results in many bugs, see Walter Bright's article: ["C’s biggest mistake" (dec 2009)](www.drdobbs.com/architecture-and-design/cs-biggest-mistake/228701625).  
In Jai, arrays do not automatically cast to pointers as in C. Rather, they are like fat or wide pointers that contain a pointer to the start of the array, and the size of the array. Internally, they are a struct (pointer + size). 
This prevents the many possible bugs resulting from the way C handles this. In Jai the procedure can test that it doesn’t change the array out of bounds, because it knows its size through arr.count. 

## 18.9. An array of pointers
See _18.9_array_pointers.jai_:

```c++
#import "Basic";

Dragon :: struct {
    serial_no: int;
    name: string;
    strength: u8;
}

NR_DRAGONS :: 10;

main :: () {
    e1 := New(Dragon);
    e1.serial_no = 123;
    e1.name =  "Dragon1";
    e1.strength =  42;
    e2 := New(Dragon);
    e2.serial_no = 124;
    e2.name =  "Dragon2";
    e2.strength =  78;
    
    arr_dragons: [NR_DRAGONS] *Dragon; 
    defer { for arr_dragons  free(it); };
    arr_dragons[1] = e1;
    arr_dragons[2] = e2;
    arr_dragons[3] = New(Dragon);
    arr_dragons[3].serial_no = 666;
    print("the dragon array is: %\n", arr_dragons);
    // => the dragon array is: [null, 22a_1f40_4b20, 22a_1f40_4be0, 
    // 22a_1f40_4cd0, null, null, null, null, null, null]
}
```

Game entities (objects) are most often defined as structs. Each type of entity can have many instances at any time. Because we probably will have thousands of objects, we need to allocate them on the heap with New.  
A handy way to work with them is to make an array, where each item is a pointer to an entity instance. In our example, arr_dragons is an array of size NR_DRAGONS of pointers to Dragons, the array contains the addresses of the Dragon instances.

## 18.10 Variable number of arguments ..
See _18.10_var_args.jai_:

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

### 18.10.1 Passing an array as a variable argument
In line (6B) we pass the array arr defined in line (6A) to proc var_args like this:  
`var_args(..arr);` or `var_args(args = ..arr);`
This is in fact the same as calling `var_args(1,2,3,4,5,6,7);`; we say that the array items are _spread_ over args.

### 18.10.2 Named variable arguments proc
A named variable and (some) default arguments proc would be defined like:
`varargs_proc :: (s:= "Fred", f:= 2.5, v: ..string) { }`

called as for example in line (7A):
`varargs_proc(f = 3.14, s = "How", v = "are", "you", "tonight?");`

After the varargs name v is used, all parameters are going into the variable argument.
You can spread parameters with a name as well as in line (7B): 
`varargs_proc(f = 5, 3.14 = "How", v = ..array);`

## 18.11 The print procedure uses variable number of arguments
See _18.11_print_proc.jai_:

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


