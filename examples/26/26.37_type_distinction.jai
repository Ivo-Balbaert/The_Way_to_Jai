#import "Basic";

// cpp: using HandleA = u32;
// rust: type HandleA = u32;
HandleA :: u32;

// cpp: no equivalent
// rust: no equivalent
HandleB :: #type,distinct u32;

// Functions
do_stuff_u :: (h: u32) { /* ... */ }
do_stuff_a :: (h: HandleA) { /* ... */ }
do_stuff_b :: (h: HandleB) { /* ... */ }

main :: () {
    // Variables
    u : u32 = 7;
    a : HandleA = 42;
    b : HandleB = 1776;

    // HandleA converts to u32, HandleB does not
    // Assignment
    u = a;
    a = u;
    // a = b; // compile error
    // b = a; // compile error
    // u = b; // compile error
    // b = u; // compile error

    // procedure takes u32, but also HandleA
    do_stuff_u(u);
    do_stuff_u(a);
    //do_stuff_u(b); // compile error

    // procedure takes HandleA, but also u32
    do_stuff_a(u);
    do_stuff_a(a);
    // do_stuff_a(b); // compile error

    // procedure takes HandleB only
    // do_stuff_b(u); // compile error
    // do_stuff_b(a); // compile error
    do_stuff_b(b);
}