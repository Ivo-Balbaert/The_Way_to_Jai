#import "Basic";

main :: () {
    // Test if n is an even or uneven number:
    n := 108;
    if n % 2 == 0 print("% is an even number\n", n); // (1)
    // => 108 is an even number
    if (n & 1) == 0 print ("even\n"); // (2) => even
    n = 109;
    if n & 1  print ("odd\n"); // => odd
    if n % 2  print("odd\n");    // (3) => odd
    if !(n % 2) print("even\n"); 
}