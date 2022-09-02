#import "Basic";

main :: () {
    n := 7;
    m := 42;
    // print("m is", m); // =>  Warning: Incorrect number of arguments supplied to 'print': The format string requires 0 arguments, but 1 argument is given.
    print("n is % and m is %\n", n, m);   // (1) => n is 7 and m is 42
    print("n is %1 and m is %2\n", n, m); // (2) => n is 7 and m is 42
    print("m is %2 and n is %1\n", n, m); // (3) => m is 42 and n is 7
    print("%2 %1 %2\n", n, m); // => 42 7 42
    // print("% %", n, m, counter); // =>  Warning: Incorrect number of arguments supplied to 'print': The format string requires 2 arguments, but 3 arguments are given.

    // printing % with %%:
    value := 50;
    print("Everything is on sale for %1%% off!\n", value); // (4)
    // => Everything is on sale for 50% off!
}