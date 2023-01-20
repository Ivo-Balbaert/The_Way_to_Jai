#import "Basic";

factorial :: (n: int) -> int {
    if n <= 1  return 1;
    return n * factorial(n-1);
}

perf_measure :: (code: Code) #expand {
    secs := get_time();
    #insert code;   // (1)
    secs = get_time() - secs;
    print("Piece of code took % seconds\n", secs);
}

main :: () {
    code :: #code print("Factorial 20 is %\n", factorial(20));
    perf_measure(code);
    // Factorial 20 is 2432902008176640000
    // Piece of code took 0.000151 seconds
}