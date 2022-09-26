#import "Basic";

main :: () {
    // ternary operator:
    a2 := 0;
    b2 := 100;
    c := ifx a2 > b2 10 else 1000;
    print("ternary c is %\n", c); // => ternary c is 1000
}