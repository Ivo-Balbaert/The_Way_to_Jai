#import "Basic";

main :: () {
  // the explicit null assignment is not needed because null is the zero-value for pointers  
  // c : *int = null;
  c : *int;
  // ... other pieces of code
  // print("%\n", c); // (1) => null
  // assert(c != null);  // (2) => Assertion failed!
  // print("%\n", << c); // (3) program compiles but crashes at run-time with stack trace
}

// #run main(); // (4)

// with assert:
// D:/jai/testing/test2.jai:5,3: Assertion failed!

// Stack trace:
// c:/jai/modules/Preload.jai:334: default_assertion_failed
// c:/jai/modules/Basic/module.jai:74: assert
// D:/jai/testing/test2.jai:5: main

// Linux gives a: Segmentation fault 
// when running

/* Windows:
The program crashed. Printing the stack trace:
handle_exception                  c:\jai\modules\Runtime_Support_Crash_Handler.jai:211
... (skipping OS-internal procedures)
get_s64_from_void_pointer         c:\jai\modules\Basic\Print.jai:152
print_integer                     c:\jai\modules\Basic\Print.jai:358
print_item_to_builder             c:\jai\modules\Basic\Print.jai:757
print_to_builder                  c:\jai\modules\Basic\Print.jai:1126
print                             c:\jai\modules\Basic\Print.jai:390
main                              d:\Jai\The_Way_to_Jai\examples\10\10.2_dereference_a_null_pointer.jai:7
*/