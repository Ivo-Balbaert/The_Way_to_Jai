#import "Basic";

proc1 :: () -> int, int {   // (1)
    return 3, 5;
}

mult :: (n1: float, n2: float) -> float #must {  // (2)
    return n1 * n2;
}

main :: () {
    // x, y: int;
    // x, y = proc1();
    // shorter:
    x, y := proc1();        // (3)
    print("x is % and y is %\n", x, y); // => x is 3 and y is 5
    n := 3.14;
    m := 5.18;
    print("mult is %\n", mult(n, m)); // => mult is 16.2652
    // mult(n, m); // (4) with #must 
    // => Error: Return value 1 is being ignored, which is disallowed by #must.
    mm := mult(n, m); // (5)
}
