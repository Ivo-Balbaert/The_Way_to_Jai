#import "Basic";

factorial :: (f: int) -> int {
    if f <= 1  return 1;
    n := 1;
    for < f..2  n *= it;
    return n;
}

main :: () {
     print("f(%) = %\n", 20, factorial(20));
    // => f(20) = 2432902008176640000
}


