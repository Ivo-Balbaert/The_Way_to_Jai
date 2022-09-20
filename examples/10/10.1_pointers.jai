#import "Basic";

main :: () {
    a : int = 42; 
    b : *int;     // (1A) declaration: b is a pointer to an integer.
    b = *a;       // (1B) initialize the pointer: point b at a.
    print("Value of a is %, address of a is %\n", a, *a);
    print("Value of b is %, but b points at address of a: %\n", <<b, b); // (2)
    print("Type of b is %\n", type_of(b)); // (3)

    c := *a; // (4)
    print("Value of c is %, but c points also at address of a: %\n", << c, c);
 
    // null pointer:
    d: *u32; // (5)
    print("Value of d is %\n", d); // => Value of d is null
    print("Type of null is %\n", type_of(null)); // (6) => Type of null is *void
   
    // void pointer:
    ptr: *void; // (7)
    print("Value of ptr is %\n", ptr); // => Value of ptr is null
   
    // (8) pointers to pointers:
    a2: int = 3;
    b2: *int = *a2;
    c2: **int = *b2;
    d2: ***int = *c2;
    print("%\n", << << << d2); // prints out the value of a2, which is 3
}

/*
Value of a is 42, address of a is 13_c38f_f908
Value of b is 42, but b points at address of a: 13_c38f_f908
Type of b is *s64
Value of c is 42, but c points also at address of a: 13_c38f_f908
Value of d is null
Type of null is *void
Value of ptr is null
3
*/
