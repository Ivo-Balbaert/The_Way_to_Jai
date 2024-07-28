#import "Basic";

// global scope:
MASS_EARTH0 : float : 5.97219e24;  // (1) in kg
MASS_EARTH :: 5.97219e24;          // (2)
COMP_CALC :: #run (234 * 15);      // (2B)

main :: () {
    MASS_MARS :: MASS_EARTH * 0.15;  // (3)
    print("The earth mass is %\n", MASS_EARTH);
    // => The earth mass is 5972189887017193070000000

    // MASS_EARTH = 5.98e24; // => (4) Error: Attempt to assign to a constant.

    print("I was computed at compile time: %\n", COMP_CALC); 
    // => I was computed at compile time: 3510

    print("%\n", type_of(MASS_EARTH));     // (5) => float32
    print("%\n", is_constant(MASS_EARTH)); // (6) => true
    print("%\n", is_constant("Hello"));  // => true
}