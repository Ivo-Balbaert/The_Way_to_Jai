#import "Basic";

main :: () {
    assert(5 == 5.0);
//  assert(4 == 5, "4 does not equal 5");  // (1)
//  print("This is not printed when previous assert is false");  // (2)

    n := 42;
    assert(type_of(n) == int);
}

// => With line 5 uncommented:
/*
d:/Jai/The_Way_to_Jai/6_Bool_and_number types/examples/6.3_assert.jai:5,3: Assertion failed: 4 does not equal 5

Stack trace:
c:/jai/modules/Runtime_Support.jai:103: runtime_support_assertion_failed
c:/jai/modules/Basic/module.jai:87: assert_helper
D:/Jai/The_Way_to_Jai/examples/06/6.2_assert.jai:5: main
A breakpoint was hit, but no debugger is attached.
*/