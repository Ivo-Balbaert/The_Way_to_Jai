# import "Basic";

factorial :: (n: int) -> int {
    if n <= 1 return 1;           // (1)
    return n * factorial(n - 1);  // (2)
}

// Version with #this:
factorial2 :: (n: int) -> int {
    if n <= 1 return 1;           
    return n * #this(n - 1);  // (3)
}

main :: () {
    for i: 1..20 {  // correct till i == 20
        print("The factorial of % is %\n", i, factorial(i));
    }

    for i: 1..10 {  // correct till i == 20
        print("The factorial of % is %\n", i, factorial2(i));
    }
}

/*
The factorial of 1 is 1
The factorial of 2 is 2
The factorial of 3 is 6
The factorial of 4 is 24
The factorial of 5 is 120
The factorial of 6 is 720
The factorial of 7 is 5040
The factorial of 8 is 40320
The factorial of 9 is 362880
The factorial of 10 is 3628800
The factorial of 11 is 39916800
The factorial of 12 is 479001600
The factorial of 13 is 6227020800
The factorial of 14 is 87178291200
The factorial of 15 is 1307674368000
The factorial of 16 is 20922789888000
The factorial of 17 is 355687428096000
The factorial of 18 is 6402373705728000
The factorial of 19 is 121645100408832000
The factorial of 20 is 2432902008176640000
*/