#import "Basic";

main :: () {
    // Test if n is an even or uneven number:
    n := 108;
    if n % 2 == 0 print("% is an even number\n", n); // (1)
    // => 108 is an even number
    if (n & 1) == 0 print ("even\n"); // (2) => even, can also be written as if n & 1
    n = 109;
    if n % 2    print("uneven\n"); // (3) => uneven
}