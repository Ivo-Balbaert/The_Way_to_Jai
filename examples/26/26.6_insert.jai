#import "Basic";

main :: () {
    a := 1;
    b := 2;
    #insert "c := a + b;";   // (1)
    print("c is %\n", c);    // => c is 3

    d :: "add(42, 8);";      // (2)
    x := 1 - #insert d;
    print("x = %\n", x);     // => x = -49

    add :: (n: int, m: int) -> int { return n + m; };
}
