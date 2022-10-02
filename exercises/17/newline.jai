#import "Basic";

new_line :: () { print("\n"); }

main :: () {
    print("123"); 
    new_line();   // comment this out to see the result
    print("456");
}

/*
123
456
*/