#import "Basic";

// proc1 :: ()         {      // (1)  procedure
proc1 :: () #expand {         // (2)  macro
    print("You are in proc1!");
}   

main :: () {
    proc1(); // => You are in proc1!
}