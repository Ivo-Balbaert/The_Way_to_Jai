#import "Basic";

main :: () {
    MAX :: 20;

    for 10..MAX {
        print("The square of % is: %\n", it, it * it);
    }

    // alternative:
    for n: 10..MAX {
        print("The square of % is: %\n", n, n * n);
    }

}

/*
The square of 10 is: 100
The square of 11 is: 121
The square of 12 is: 144
The square of 13 is: 169
The square of 14 is: 196
The square of 15 is: 225
The square of 16 is: 256
The square of 17 is: 289
The square of 18 is: 324
The square of 19 is: 361
The square of 20 is: 400
The square of 10 is: 100
The square of 11 is: 121
The square of 12 is: 144
The square of 13 is: 169
The square of 14 is: 196
The square of 15 is: 225
The square of 16 is: 256
The square of 17 is: 289
The square of 18 is: 324
The square of 19 is: 361
The square of 20 is: 400
*/