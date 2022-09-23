#import "Basic";

Person :: struct {
    name            : string;
    age             : int;
}

main :: () {
    bob := New(Person);            // (1)
    print("%\n", type_of(bob));    // (2) => *Person
    defer free(bob);

    bob.name = "Robert";           
    bob.age = 42;
    print("%\n", bob);             // (3) => 2d1_e8d2_c100
    print("%\n", << bob);          // (4) => {"Robert", 42}

    bob2 := New(Person);
    defer free(bob2);
    bob2 = *Person.{"Robert", 42}; // (5)
}