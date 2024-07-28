#import "Basic";

global_var := 108;  // (1)

main :: () {
    // Case 1: full type declaration and initialization: 
    counter : int = 100;
    pi : float = 3.14159;
    valid : bool = false;
    first_name : string = "Jon";
    print("counter: %\n", counter);   // => 100

    // Case 2: only type declaration, no explicit initialization 
    // (the variables have a default value of zero):
    counter2 : int;   
    print("counter2: %\n", counter2);       // => 0
    pi2 : float;     
    print("pi2: %\n", pi2);                 // => 0
    valid2 : bool; 
    print("valid2: %\n", valid2);           // => false
    first_name2 : string;   
    print("first_name2: %\n", first_name2); // => ""
    
    // change default value afterwards:
    counter2 = 100;
    first_name2 = "Jon";
    print("counter2: %\n", counter2);       // => 100
    print("first_name2: %\n", first_name2); // => "Jon"
  
    // Case 3: only initialization (type is inferred):
    counter3 := 100;         // an int
    pi3 := 3.14159;          // a float
    valid3 := false;         // a bool
    first_name3 := "Jon";    // a string
    print("pi3 is of type %, value %.\n", type_of(pi3), pi3); // => pi3 is of type float32, value 3.14159.
    print("counter3: %\n", counter3); // => 100
  
    // Case 4: uninitialized declaration (no default value is given):
    counter4 : int = ---;
    average : float = ---;
    print("counter4 contains the value %\n", counter4); // => 31525674139189348
    print("average contains the value %\n", average);  // => 0

    print("the global var is %\n", global_var); // => the global var is 108

    // char literal
    f := #char "1";     // (2) Inferred as s64. f has the value of the ASCII character '1'
    print("f is % and has type %\n", f, type_of(f)); 
    // => f is 49 and has type s64

    varv: void;
    print("varv is %\n", varv); // (2B) => void

  // Possible errors:  // (3)
  // 1] Error: Undeclared identifier 'counter5'.
  // counter5 = 101; // => Error

  // 2] Error: Redeclaration of variable 'counter'.
  // counter := 42;

  // 3] Error: Type mismatch. Type wanted: int; type given: string.
  // counter = "France";
}
