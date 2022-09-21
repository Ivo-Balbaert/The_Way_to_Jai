#import "Basic";

main :: () {
    x := 123;                   // (1)
    defer print("x is %\n", x); // (2)
    {
        defer x = 4; // this is the same x as defined in line (1)
        x = 2;
    } // x is now 4!
    print("x is %\n", x); // => 4
    x = 234;
    // now the 1st defer statement from line (2) is executed
}
/*
x is 4
x is 234
*/
