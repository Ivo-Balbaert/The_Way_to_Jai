#import "Basic";

add :: (a, b) => a + b;                 // (1)
add10 :: #bake_arguments add(a=10);     // (2)

mult :: (a: float, b: float) -> float {
    return a * b;
}

mult1 :: #bake_arguments mult(b = -9);  // (3)

proc :: ($a: int) -> int  { return a + 100; } // (6)

proc2 :: ($$a: int) -> int {    // (7)
    #if is_constant(a) {
        print("a is constant / ");
        return a + 100;
    } else {
        print("a is not constant / ");
        return a * 2;
    }
}

main :: () {
    b := 20;
    c := add10(b);                      // (4)
    print("c is %\n", c);               // => c is 30
    print("mult1(2) is %\n", mult1(2));  // (5) => mult1(2) is -18
    print("proc(42) is %\n", proc(42));  // => proc(42) is 142
    print("proc2(42) is %\n", proc2(42));  
    // => a is constant / proc2(42) is 142
    // print("proc(b) is %\n", proc(b));  
    // => Error: The declaration of argument 1 requires a value bake 
    // (it is declared with a $ before the identifier), 
    // but this expression is not a bakeable literal (its type is s64).
    print("proc2(b) is %\n", proc2(b));
    // => a is not constant / proc2(b) is 40
}