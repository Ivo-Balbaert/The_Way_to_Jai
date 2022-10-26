#import "Basic";

macro0 :: () #expand {
  // This is a macro that doesn't do anything
}

// Example 1:
macro1 :: () #expand {
  `a += 10; // add 10 to the "a" variable found in the outer scope.
}

// Returning values: (not clear example why macro is needed)
maxm :: (a: int, b: int) -> int #expand {
  if a > b then return a;
  return b;
}

macro2 :: () -> int #expand {
  if `b < `c {
    return 0;
  }
  defer print("Defer inside macro\n");
  return 1;
}

macfunc :: () -> string {
  a := 0;
  b := 100;
  c := macro();
  return "none";

  macro :: () -> int #expand {
    `defer print("Defer inside macro\n");
    if `a < `b {
      `return "Backtick return macro"; // return a value from the function macfunc
    }
    return 1;
  }
}

// Nested Macros:
macro3 :: () #expand {
  print("This is macro3\n");
  nested_macro();

  nested_macro :: () #expand {
    print("This is a nested macro\n");
  }
}

// Recursive macros:
// This version of the macro fails to compile since the 'if' is a runtime 'if'
//  Info: While expanding macro 'factorial' here...

//     macro3();
//     x := factorial(5);

// D:/Jai/The book of Jai/Chapter 9 - Metaprogramming - Compile-time code execution/code/macros.jai:48,16: Error: Too many nested macro expansions. (The limit is 1000.)
// factorial :: (n: int) -> int #expand {
//   if n <= 1 return 1;
//   else {
//     return n * factorial(n-1);
//   }
// }

// This code works and compiles.
// #else gives an error, is not a directive
factorial :: (n: int) -> int #expand {
  #if n <= 1 return 1;
  else {
    return n * factorial(n-1);
  }
}

// using Code argument and #insert:
macro4 :: (c: Code) #expand {
  #insert c;
  #insert c;
  #insert c; // In this macro, we insert the code "c" into the macro three times
  // print("d is %\n", d); // => Error: Undeclared identifier 'd'.
}

main :: () {
  a := 0;
  macro1(); //call the macro
  print("a is: %\n", a); // => a is: 10

  b := 7;
  c := 3;
  print("max is %\n", maxm(b, c)); // => max is 7

  print("macro2 returns %\n", macro2()); // => 1

  macro3();

  x := factorial(5);
  print("factorial of 5 = %\n", x); // => factorial of 5 = 120

  f := 0;
  macro4("f += `a + `b;");
  print("f is %\n", f); // => f is 0 ?? f += `a + `b; doesn't work

  s := macfunc();
  print("%\n", s); // s = "Backtick return macro"
}

/* =>
a is: 10
max is 7
Defer inside macro
macro2 returns 1
This is macro3
This is a nested macro
factorial of 5 = 120
f is 0
Defer inside macro
Backtick return macro
*/