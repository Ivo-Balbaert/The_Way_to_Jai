#import "Basic";

Thread_Index :: s64;  // (0)

main :: () {
    // type Type
    a: Type = float64;  // (1)
    b := int;           // (2)
    print("b is %\n", b); // => s64  (int is an alias for s64)
    c := type_of(42);   // (3)
    print("c is of type %, value %\n", type_of(c), c); // => c is of type Type, value s64
    d := type_of(b);    // (4)
    print("d is of type %, value %\n", type_of(d), d); // => d is of type Type, value Type
    var := Type;
    print("Type of Type is: %\n", type_of(var)); // => Type of Type is: Type
 
    // (5) size_of:
    print("the size of c is %\n", size_of(type_of(c))); // => 8
    t1 := 3.14; 
    print("the type of t1 is %\n", type_of(t1)); // => float32
    print("the size of t1 is %\n", size_of(type_of(t1))); // => 4
    print("the size of u16 is: % bytes\n", size_of(u16)); // => The size of u16 is: 2 bytes
    t2 := "Hello!";
    print("the type of t2 is %\n", type_of(t2)); // => string
    print("the size of t2 is %\n", size_of(type_of(t2))); // (6) => 16
    t3 := "世界!"; // (7) Chinese Hello World!
    print("the size of t3 is %\n", size_of(type_of(t3))); // => 16
    print("the size of Type is % bytes\n", size_of(Type)); // => 8 bytes
    
    // Type alias:
    t_index : Thread_Index = 100;
    TI :: s32; // (8) TI is now a constant, of type Type, of value s32.
    s: TI = 7;
    t: TI = 9;
    print("s * t = %\n", s * t); // => 63
    print("size_of(TI) is %\n", size_of(TI)); // 4 (bytes)

    // Any:
    x: Any = 3.0;  // (9)
    x = 3;         // (10)
    x = "Hello";
    x = 2.345;
    x = main;      // (11)
    print("the type of x is %\n", type_of(x)); // => the type of x is Any
    a5 : s32 = 5;
    x2: Any = a5;
    print("the size of Any is %\n", size_of(Any));       // => 16

    // (12) Type comparisons:
    y : float64 = 0.1;
    assert(type_of(y) == float64);
    n := 42;
    assert(type_of(n) == int);
    assert(type_of(n) != string);
    print("is b a float? %\n", b == float); // => false
}