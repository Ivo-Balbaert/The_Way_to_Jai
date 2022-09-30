#import "Basic";
#import "Math";

Person :: struct {
    name            : string;
    age             : int;
    location        : Vector2;
}

main :: () {
    bob := Person.{"Robert", 42, Vector2.{64.139999, -21.92}};
    rob := *bob;
    print("rob is %\n", rob);   // => rob is 8d_425b_fe20
    print("The type of rob is %\n", type_of(rob)); // => The type of rob is *Person
    print("The value rob points to is %\n", << rob); 
    // => The value rob points to is {"Robert", 42, {64.139999, -21.92}}

    // 2nd example:
    Entity :: struct {
        serial_number: int;
    }

    e: Entity;              // e is a variable of type Entity
    e.serial_number = 0349825645;
//    ptr: *Entity;           // (1) ptr is a pointer to an Entity struct- a declaration
//    ptr = *e;               // (2) ptr is a pointer to e - initialization
    // shorter:
    ptr := *e;
    print("e's value is: %\n", << ptr); // => e's value is: {349825645}
   
}


