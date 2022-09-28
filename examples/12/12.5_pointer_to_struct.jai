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
}


