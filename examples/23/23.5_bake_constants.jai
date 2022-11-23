#import "Basic";

printer :: (x: $T) {                // (1)
    print("PRINTING!!! %\n", x);
}

Polymorphic_Struct :: struct (T: Type, N: int) { // (2)
    values:   [N] T;
    pointer: *#this;

    proc :: #bake_constants printer(T=#this);  // (3)
}

main :: () {
    p0: Polymorphic_Struct(float, 3);    //   (4)
    p1: Polymorphic_Struct(string, 2);   //   (5)

    print("p0 is %\n", p0); // (6) => p0 is {[0, 0, 0], null} 
    print("p1 is %\n", p1); // => p1 is {["", ""], null}

    p0.proc(p0);  // => PRINTING!!! {[0, 0, 0], null}  // (7)
    p1.proc(p1);  // => PRINTING!!! {["", ""], null}   // (8)

    assert(type_of(p0.pointer) == *type_of(p0));
    assert(type_of(p1.pointer) == *type_of(p1));
}