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
}

// version with defer:
main :: () { 
    start_time := get_time();
    defer {
        elapsed := get_time() - start_time;
        print("Factorial 20 took % ms\n", elapsed * 1000);
    }
    print("Factorial 20 is %\n", factorial(20)); 
    // => Factorial 20 is 2432902008176640000
    // calling all code of which we want to measure performance

    // executing defer block:
    // => Factorial 20 took 0.1857 ms
}
