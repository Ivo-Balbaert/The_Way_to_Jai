#import "Basic";

main :: () {
    assert(5 == 5.0);
    assert(4 == 5, "4 does not equal 5");
    // (1) print("This is not printed when assert (false)");

    n := 42;
    assert(type_of(n) == int);
}

// => With line 5 uncommented:
/*
d:/Jai/The_Way_to_Jai/6_Bool_and_number types/examples/6.3_assert.jai:5,3: Assertion failed: 4 does not equal 5

Stack trace:
c:/jai/modules/Preload.jai:334: default_assertion_failed
c:/jai/modules/Basic/module.jai:74: assert
d:/Jai/The_Way_to_Jai/6_Bool_and_number types/examples/6.3_assert.jai:5: main
*/