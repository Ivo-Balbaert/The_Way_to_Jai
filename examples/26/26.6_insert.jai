#import "Basic";

main :: () {
    a := 1;
    b := 2;
    #insert "c := a + b;";   // (1)
    print("c is %\n", c); // => c is 3
}
