#import "Basic";

PolyStruct :: struct(T: Type) {     // (1)
    data : T;
}

main :: () {
    ps: PolyStruct(int);            // (2)
    ps.data = 42;
    print("ps type = %\n", ps.T); // => ps type = s64
    print("ps is %\n", ps); // => ps is {42}

    // comparing types:              // (3)
    assert(type_of(ps) == PolyStruct(int));
    assert(ps.T == int);
    print("%\n", type_of(ps)); // => PolyStruct(T=s64)
    // assert(type_of(ps) == PolyStruct); // Assertion failed!
}