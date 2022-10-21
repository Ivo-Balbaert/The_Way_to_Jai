#import "Basic";

// version with parameter values
mult_and_add_with_constants :: (a: float64, b: float64) -> float64 {
    return 1.5 * a + 4.6 * b;
}

main :: () {
    k1: float64 = 1.0;
    k2: float64 = 2.0;

    result := mult_and_add_with_constants(k1, k2);
    print("the result is: %\n", result); // => the result is: 10.7

    do_math_things :: (a: float64, b: float64) -> float64 {
        return mult_and_add_with_constants(a, b);
    }

    resulth := do_math_things(k1, k2);
    print("the result is: %\n", resulth); // => the result is: 10.7
}