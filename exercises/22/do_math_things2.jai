#import "Basic";

// version with parameter types
mult_and_add_with_constants :: (a: $Ta, b: $Tb) -> Ta {
    return 1.5 * a + 4.6 * b;
}

main :: () {
    k1: float64 = 1.0;
    k2: float64 = 2.0;

    result := mult_and_add_with_constants(k1, k2);
    print("the result is: %\n", result); // => the result is: 10.7

    do_math_things :: (a: $Ta, b: $Tb) -> Ta {
        return mult_and_add_with_constants(a, b);
    }

    resulth := do_math_things(k1, k2);
    print("the result is: %\n", resulth); // => the result is: 10.7
}

/*

the result is: 10.7
*/

// change k1 to float32
// change k2 to float32
