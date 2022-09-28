#import "Basic";
#import "Math"; // contains Vector2

// default values:
Vector2d :: struct {
  x : float = 1;
  y : float = 4;
}

//  Uninitialized struct
Vector2un :: struct {
    x: float = ---;
    y: float = ---;
}

//  Uninitialized member(s):
Vector3un :: struct {
    x: float = 1;
    y: float = ---; // uninitialized
    z: float = 3;
}

Entity :: struct {
    serial_number: int;
}

Person :: struct {
    name            : string;
    age             : int;
    location        : Vector2;
}

main :: () {
    v : Vector2;  // defined in module Math
    print("%\n", v); // (0) => {0, 0}
    print("% %\n", v.x, v.y); // (1) => 0 0
    v.x, v.y = 42, 108;       // (2)
    print("% %\n", v.x, v.y); // => 42 108

    v3 : Vector2d;
    print("% %\n", v3.x, v3.y); // (3) => 1 4

    v4 : Vector2un;
    print("% %\n", v4.x, v4.y); // => 0 0
    print("%\n", type_of(v4)); // => Vector2un
    // (4) Undefined behavior, could print anything, mostly "0 0"

    bob : Person;
    bob.name = "Robert";           // (5)
    bob.age = 42;
    bob.location.x = 64.14;        // (6)
    bob.location.y = -21.92;
    print("% is aged % and is currently at location %\n", bob.name, bob.age, bob.location); // (7)
    print("%\n", bob); // (8) => {"Robert", 42, {64.139999, -21.92}}
    assert(type_of(bob) == Person);

    // struct literals:
    vec2 := Vector2.{2.0, 6.28}; // (9)
    print("%\n", vec2); // => {2, 6.28}
    // same as:
    vec3 : Vector2;
    vec3 = .{2.0, 6.28};
    vec4:= Vector2.{y = 6.28, x= 2.0}; 
    bob2 := Person.{"Robert", 42, Vector2.{64.139999, -21.92}}; // (10)
    print("%\n", type_of(bob2)); // => Person
    print("%\n", size_of(Person)); // => 32 // (bytes)
}

/*
0 0
42 108
1 4
0 0
Robert is aged 42 and is currently at location {64.139999, -21.92}
*/
