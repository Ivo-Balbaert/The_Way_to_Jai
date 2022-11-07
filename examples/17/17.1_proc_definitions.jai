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

/*
Sum: 6
a is 9
a2 is 9
b is 81
procedure 0x7ff7_a9c3_e1b0.
0x7ff7_a9c3_e1b0.
Its type is: procedure (s64, s64, s64) -> s64
*/