#import "Basic";

main :: () {
    print("Hello, Sailor!\n"); // => Hello, Sailor!
    // This doesn't work:
    // print(42);    // =>  Error: Type mismatch. Type wanted: string; type given: s64.
    // print(false); // =>  Error: Type mismatch. Type wanted: string; type given: bool.

    // But these do:
    print ("I greet you: %\n", "Hello, Sailor!"); // => I greet you: Hello, Sailor!
    print("%\n", 42);    // => 42
    print("%\n", false); // => false

    // char literal
    print("char literal: %\n", #char "1"); // => char literal: 49

    print("The type of % is %\n", "Hello, Sailor!", type_of("Hello, Sailor!"));
    // => The type of Hello Sailor! is string
    print("The type of % is %\n", 42, type_of(42)); // => The type of 42 is s64
    print("The type of % is %\n", false, type_of(false)); // => The type of false is bool
}