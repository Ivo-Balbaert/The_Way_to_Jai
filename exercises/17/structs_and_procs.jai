#import "Basic";
#import "Math";

Person :: struct {
    name            : string;
    age             : int;
    location        : Vector2;
}

move_person :: (person: *Person, newlocation: Vector2) {
    person.location = newlocation;     // (1)
}

main :: () {
    bob : Person;
    bob.name = "Bob";
    bob.age = 42;
    bob.location.x = 64.14;
    bob.location.y = -21.92;
    print("% is aged % and is currently at %\n", bob.name, bob.age, bob.location);
// => Bob is aged 42 and is currently at {64.139999, -21.92}
    v := Vector2.{3.14, 42}; 
    move_person(*bob, v);  // (1)
    print("% is aged % and has moved to %\n", bob.name, bob.age, bob.location);
    // => Bob is aged 42 and has moved to {3.14, 42}
}

/*
In line (1) we pass a pointer to the bob instance of Person to the proc `move_person`, 
whose 1st argument is of type *Person. Because of that, bob can be changed 
through `move_person`, as we already know from § 17.3
*/