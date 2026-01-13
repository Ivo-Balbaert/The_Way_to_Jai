#import "Basic";

my_swap :: (a: *$T, b: *T) {  // (1)
    tmp := a.*;   
    a.* = b.*;
    b.* = tmp;
}

main :: () {
    a, b := 3, 5;
    print("Pre-swap: a is %, b is %\n", a, b);
    my_swap(*a, *b);    // (2)
    print("Post-swap: a is %, b is %\n", a, b);

    a2, b2 := "Hello ", "Sailor!";
    print("Pre-swap: a2 is %, b2 is %\n", a2, b2);
    my_swap(*a2, *b2);  // (3)
    print("Post-swap: a2 is %, b2 is %\n", a2, b2);

    // using the swapping procedure from module Basic:
    n2 := 2; m2 := 3;
    swap(*n2, *m2);  // (5)
    print("n2 is % and m2 is %\n", n2, m2);   
}

/*
Pre-swap: a is 3, b is 5
Post-swap: a is 5, b is 3
Pre-swap: a2 is Hello , b2 is Sailor!
Post-swap: a2 is Sailor!, b2 is Hello
n is 3 and m is 2
n2 is 3 and m2 is 2     
*/

