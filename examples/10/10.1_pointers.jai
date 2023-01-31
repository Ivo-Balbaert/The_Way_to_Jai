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
    // print("d is %\n", << d); // => program crashes!
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
