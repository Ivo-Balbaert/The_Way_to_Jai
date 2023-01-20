#import "Basic";

A :: struct {}
B :: struct {}

say :: (a1: A, a2: A) {
    print("aa\n");
}

say :: (a: A, b: B) {
    print("ab\n");
}

say :: (b: B, a: A) {
    print("ba\n");
}

say :: (b1: B, b2: B) {
    print("bb\n");
}

say_swaps :: (x: $X, y: $Y) {
    say(x, y);
    say(y, x);
}

main :: () {
    a: A;
    b: B;
    say(a, b); 
    say_swaps(a, b); 
    
}

/*
ab
ab 
ba
*/