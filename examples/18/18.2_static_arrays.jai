#import "Basic";

Vector3 :: struct {
    x, y, z : float;
}

Object :: struct { member: int #align 64; }

main :: () {
    a : [4] u32;      // (1) A static array of 4 u32 integers.
    b : [30] float64; // An array of 30 float64's.
    arr1 : [50] int;  // array of 50 integers
    i := 5;
    print("%-th item is: %\n", i, arr1[i]); // (2) => 5-th item is: 0
    print("The array a is by default initialized to %\n", a); // (3)
    // => The array a is by default initialized to [0, 0, 0, 0]

    arrf : [4] float;    // (4)
    arrf[0] = 10.0; 
    arrf[1] = 20.0;
    arrf[2] = 1.4;
    arrf[3] = 10.0;
    arrf2 := float.[10, 20, 1.4, 10]; // (4B)
    print("arrf\n");
    for arrf    print("% - ", it);  // (4C) => 10 - 20 - 1.4 - 10 -
    print("\n");
    for arrf    print("% / % - ", it_index, it);  // => 0 / 10 - 1 / 20 - 2 / 1.4 - 3 / 10 -
    print("\n");
    for f: arrf print("% - ", f);   // => 10 - 20 - 1.4 - 10 -
    print("\n");
    for f, ix: arrf  print("% / % - ", ix, f);   // => 0 / 10 - 1 / 20 - 2 / 1.4 - 3 / 10 -
    print("\n");
    for ix: 0..arrf.count-1  print("% / % - ", ix, arrf[ix]); 
    // => 0 / 10 - 1 / 20 - 2 / 1.4 - 3 / 10 -
    print("\n");
    for 0..arrf.count-1  print("% / % - ", it, arrf[it]); 
    // => 0 / 10 - 1 / 20 - 2 / 1.4 - 3 / 10 -
    print("\n");
    
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
    print("% \n", static_array[n]); // (6D)
    // run-time crash => Array bounds check failed. ...

    M :: 4;
    arr2 : [M]Any;      // (7)
    arr2[0] = "Hello";
    arr2[1] = 42;
    arr2[2] = Vector3.{1, 2, 3};
    print("arr2 is %\n", arr2);
    // => arr2 is ["Hello", 42, {1, 2, 3}, (zero-initialized Any)]

    x := *[10] int; // x is a pointer to an array of int of size 10
    print("x is %\n", x); // => x is *[10] s64

    if arr2 {           // (8)
        print("arr2 is NOT empty\n"); // => arr2 is NOT empty
    }

    // Heap-allocated static arrays:
    arr_heap := NewArray(4, float); // (9) will heap-allocate an array of 4 floats; from Basic
    print("%\n", arr_heap); // => [0, 0, 0, 0]
    // ...
    defer array_free(arr_heap);   // (10)
    arr_align := NewArray(500, int, alignment=64);  // (10B)
    A :: 100;
    object_array := NewArray(A, Object, alignment=64);  // (10C)
    assert(cast(int)(*object_array[0]) % 64 == 0);      // (10D)
    assert(cast(int)(*object_array[1]) % 64 == 0);
    assert(cast(int)(*object_array[10]) % 64 == 0);

    // Allocation with New:
	arr_heap2 := New([3] int);    // (11)
    print("% \n", arr_heap2);     // => 202_bdf0_8d50
    defer free(arr_heap2);        // (12)
	for 0..arr_heap2.count-1 { (<<arr_heap2)[it] = it * it; }   // (13)
	print("arr_heap2: %\n", << arr_heap2);  // (14) => arr_heap2: [0, 1, 4]
}