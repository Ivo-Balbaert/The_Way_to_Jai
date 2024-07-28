#import "Basic";

main :: () {
    b1 := true;
    print("b1 is % and of type %\n", b1, type_of(b1)); // => b1 is true and of type bool

    // equality:
    print("Are 1 and 1.0 equal? %\n", 1 == 1.0); // => Are 1 and 1.0 equal? true
    print("Are Jai and Java different? %\n", "Jai" != "Java"); // => Are Jai and Java different? true

    n := 7;
    m := 42;
    print("%\n", n != m); // => true

    // operators:
    print("! changes to %\n", !b1); // => ! changes to false
    b2 := !b1;
    print("b2 is %\n", b2); // => b2 is false

    print("b1 and b2 is %\n", b1 && b2); // => b1 and b2 is false
    print("b1 or b2 is %\n", b1 || b2);  // => b1 or b2 is true
}