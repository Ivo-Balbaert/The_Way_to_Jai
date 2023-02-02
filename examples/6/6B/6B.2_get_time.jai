#import "Basic";

factorial :: (n: int) -> int {
    if n <= 1  return 1;
    return n * factorial(n-1);
}

main :: () {
    start_time := get_time();
    print("Factorial 20 is %\n", factorial(20)); 
    // => Factorial 20 is 2432902008176640000
    elapsed := get_time() - start_time;
    print("Factorial 20 took % ms\n", elapsed * 1000);
    // => Factorial 20 took 0.1857 ms

    // Apollo time:    
    start := current_time_monotonic();              // (3)
    print("%\n", start); // => // {3386047850652241920, 5}
    factorial(20);
    duration := operator - (current_time_monotonic(), start); // (3B)
    print("%\n", duration); // => //{185400000000, 0}
    // This is 0.1854 ms
}