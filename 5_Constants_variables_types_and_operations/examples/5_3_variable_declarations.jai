#import "Basic";

global_var := 108;

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
  ptr : *u32;                             // defaults to a null pointer to a u32.
  print("ptr: %\n", ptr);                 // => null

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
  print("counter contains the value %\n", counter4); // => 0
  print("average contains the value %\n", average);  // => 0

  print("the global var is %\n", global_var); // => the global var is 108

  // more than one statement in one code-line:
  n9: u8; m9: u8; n9 = 12; m9 = 13;
  print("% %\n", n9, m9); // => 12 13

  // char literal
  f := #char "1";     // Inferred as s64. f has the value of the ASCII character '1'
  print("f: %\n", f); // => 49

  // printing:
  print("Counter is % and valid is %\n", counter, valid); // => Counter is 100 and valid is false
  n := 7;
  m := 42;
  // print("m is", m); // =>  Warning: Incorrect number of arguments supplied to 'print': The format string requires 0 arguments, but 1 argument is given.
  print("n is %1 and m is %2\n", n, m); // => n is 7 and m is 42
  print("m is %2 and n is %1\n", n, m); // => m is 42 and n is 7
  print("%2 %1 %2\n", n, m); // => 42 7 42
  // print("% %", n, m, counter); // =>  Warning: Incorrect number of arguments supplied to 'print': The format string requires 2 arguments, but 3 arguments are given.

  // printing % with %%:
  value := 50;
  print("Everything is on sale for %1%% off!\n", value); // => Everything is on sale for 50% off!
  
  // Possible errors:
  // (1) Error: Undeclared identifier 'counter5'.
  // counter5 = 101; // => Error

  // (2) Error: Redeclaration of variable 'counter'.
  // counter := 42;

  // (3) Error: Type mismatch. Type wanted: int; type given: string.
  // counter = "France";
}
