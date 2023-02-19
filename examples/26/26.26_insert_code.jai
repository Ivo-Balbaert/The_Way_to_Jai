#import "Basic";

what_type :: ($c: Code) {                   // (2)
    T :: c.type;
    print("T is %\n", T);
}

main :: () {
    x := 3;

    x *= x; 
    x *= x; 
    x *= x; 
    #insert -> Code {                       // (1)
        return #code x = (x * 10) + 3495;
    }
    print("x is %\n", x); // => x is 69105
    assert(x == 69105);

    what_type(2 + 3 + 4);           // (3A) => T is s64
    what_type("Hello, Sailor!");    // (3B) => T is string
}