#import "Basic";

proc1 :: (a: int = 0) { // (1)
    print("a is %\n", a); 
}

// hello :: (a: int = 9, b: int = 9) { // (2)
hello :: (a := 9, b := 9) { // (2)
    print("a is %, b is %\n", a, b);
}

main :: () {
    proc1();     // => a is 0
    // (3)
    hello(1, 2); // => a is 1, b is 2
    hello(1);    // => a is 1, b is 9
    hello();     // => a is 9, b is 9
}