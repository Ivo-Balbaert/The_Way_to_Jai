#import "Basic";

main :: () {
    x := 3;
    x *= x; 
    x *= x; 
    x *= x; 
    #insert -> Code {                       // (1)
        return #code x = (x * 10) + 3495;
    }
    print("x is %\n", x); // => x is 69105
    assert(x == 69105);
}