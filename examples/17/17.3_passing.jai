#import "Basic";

passing_copy :: (m: int) {
  m = 108;
}

passing_pointer :: (m: *int) {
  << m = 108;
}

Person :: struct { name: string; }

change_name :: (pers: *Person) {
    pers.name = "Jon";
}

main :: () {
  n := 42;
  passing_copy(n);      // (1)
  print("n is % after passing by copy \n", n);  // => n is 42 after passing by copy 
  passing_pointer(*n);  // (2)
  print("n is % after passing by pointer \n", n); // => n is 108 after passing by pointer

  bob := Person.{name = "Robert"}; // (3)
  change_name(*bob);
  print("The person is now called %\n", bob.name); 
  // => The person is now called Jon
}

