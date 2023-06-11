#import "Basic";

main :: () {
    // calling a global proc:
    proc();
    proc2(); 

    // local procs:
    add :: (x: int, y: int) -> int { return x + y; };   // (1)

    display :: (arg1: string, arg2: string) {           // (2)
        print("arg1 is % and arg2 is %\n", arg1, arg2); 
    }

    // calling the procs:
    print("%\n", add(1, 2));        // (3) => 3
    display("Jonathan", "Blow");    // (4) => arg1 is Jonathan and arg2 is Blow
}

// global proc:
proc :: () {
    inner_proc :: () {
            print("This is an inner proc\n"); // => This is an inner proc
            //  Error: Attempt to use a variable from an outer stack frame. (Closures are not supported.)
            // x = 42; // (5) this does not work! cannot access variable of inner_proc scope!
    }

    x := 1;
    inner_proc();
    print("x is now %\n", x); // => x is now 1
}

proc2 :: () {
    print("Jonathan Blow\n");  // => Jonathan Blow
    // display("Jonathan", "Blow"); // (6) => Error: Undeclared identifier 'display'.
}

/*
This is an inner proc
x is now 1
Jonathan Blow
3
arg1 is Jonathan and arg2 is Blow
*/