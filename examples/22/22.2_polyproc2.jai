#import "Basic";

add :: (p: $T, q: T) -> T {     // (1)
    return p + q;
}

main :: () {
    i1: int = 1;
    i2: int = 2;
    i3 := add(i1, i2);  // (2)
    print("i3 is %\n", i3); // => i3 is 3
    proc :: #procedure_of_call add(i1, i2);  // (6) 
    print("type_of(proc) is %\n", type_of(proc));
    // => type_of(proc) is procedure (s64, s64) -> s64

    f1: float = 1;
    f2: float = 2;
    f3 := add(f1, f2);  // (3)
    print("f3 is %\n", f3); // => f3 is 3
    proc2 :: #procedure_of_call add(f1, f2);  // (7)
    print("type_of(proc2) is %\n", type_of(proc2));
    // => type_of(proc2) is procedure (float32, float32) -> float32

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