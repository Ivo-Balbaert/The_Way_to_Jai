#import "Basic";

proc :: () {
    inner_proc :: () #expand {
        `x = 42;
    }

    x := 1;
    inner_proc();
    print("x is now %\n", x); // => x is now 42
}

main :: () {
    proc();
}