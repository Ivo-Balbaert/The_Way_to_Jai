#import "Basic";

factorial :: (n: int) -> int {
    if n <= 1  return 1;
    return n * factorial(n-1);
}

perf_measure :: (code: Code) #expand {
    start_time := get_time();
    #insert code;   // (1)
    elapsed := get_time() - start_time;
    print("Piece of code took % ms\n", elapsed * 1000);
    // => Factorial 20 took 0.1857 ms
}

main :: () {
    code :: #code print("Factorial 20 is %\n", factorial(20));
    perf_measure(code);
    // Factorial 20 is 2432902008176640000
    // Piece of code took 0.2209 ms
}