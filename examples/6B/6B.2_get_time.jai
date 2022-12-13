#import "Basic";

factorial :: (n: int) -> int {
    if n <= 1  return 1;
    return n * factorial(n-1);
}

main :: () {
    secs := get_time();
    print("Factorial 20 is %\n", factorial(20)); 
    // => Factorial 20 is 2432902008176640000
    secs = get_time() - secs;
    print("Factorial 20 took % seconds\n", secs);
    // => Factorial 20 took 0.000207 seconds
}