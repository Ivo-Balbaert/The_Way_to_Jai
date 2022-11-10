#import "Basic";

proc :: () {
    x := 1;
    inner_proc();
    print("x is now %\n", x); // => x is now 42

    inner_proc :: () #expand {
        `x = 42;
    }
}

main :: () {
    proc();
}