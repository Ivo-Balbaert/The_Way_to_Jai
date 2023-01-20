#import "Basic";

OUTER_VALUE :: 5;
    
A_Struct :: struct (param := "Hello") {  // (1)
    x := OUTER_VALUE;
    y := param;
}               

main :: () {
    a: A_Struct;
    print("a is: %\n", a); // => a is: {5, "Hello"}
    print("a.x is: %\n", a.x); // => a.x is: 5
    print("a.param is: %\n", a.param); // => a.param is: "Hello"
    // print("a.OUTER_VALUE is: %\n", a.OUTER_VALUE);  
    // Error: 'OUTER_VALUE' is not a member of A_Struct.

    b: A_Struct(param = "Sailor!");  // (2)
    print("b is: %\n", b); // => b is: {5, "Sailor!"}
}