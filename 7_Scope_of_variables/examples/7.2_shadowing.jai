#import "Basic";

main :: () {
    outer := 42;
    {
        outer := 99; // this is a new variable in the block
        print("outer in block: %\n", outer); // => outer in block: 99
    }
    print("outer from main: %\n", outer);    // => outer from main: 42
}