#import "Basic";

factorial :: (n: int) -> int {
    if n <= 1  return 1;
    return n * factorial(n-1);
}

main :: () {
    start_time := seconds_since_init();
    print("Factorial 20 is %\n", factorial(20)); 
    // => Factorial 20 is 2432902008176640000
    elapsed := seconds_since_init() - start_time;
    print("Factorial 20 took % ms\n", elapsed * 1000);
    // => Factorial 20 took 0.1857 ms

    // Apollo time:    
    start := current_time_monotonic();              // (3)
    // print("%\n", start); // => // {3386047850652241920, 5}
    factorial(20);
    duration := current_time_monotonic() - start; // (3B)
    // duration := operator - (current_time_monotonic(), start); // (3C)
    print("%\n",  duration); // =>  //{185400000000, 0}
    print("%\n",  to_float64_seconds(duration) * 1.e6); // ?? =>  //{185400000000, 0}  
    // This is 0.1854 ms
}

/*
Factorial 20 is 2432902008176640000
Factorial 20 took 0.1048 ms
{12835685124494348288, 32}
{59900000000, 0}  // ?? ms
*/