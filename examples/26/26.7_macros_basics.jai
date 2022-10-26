#import "Basic";

macro0 :: () #expand { }   // (1)

macro1 :: () #expand {
  `a += 10;                //  (2) 
}

maxm :: (a: int, b: int) -> int #expand {  // (4)
  if a > b then return a;
  return b;
}

macro2 :: () -> int #expand {   // (5)
  if `b < `c {
    return 0;
  }
  defer print("Defer inside macro\n"); // => Defer inside macro
  return 1;
}

macro3 :: () #expand {
  print("This is macro3\n");
  nested_macro();

  nested_macro :: () #expand {
    print("This is a nested macro\n");
  }
}

factorial :: (n: int) -> int #expand {
  #if n <= 1 return 1;
  else {
    return n * factorial(n-1);
  }
}

macfunc :: () -> string {
  a := 0;
  b := 100;
  c := macron();
  return "none";

  macron :: () -> int #expand {
    `defer print("Defer inside macro\n");
    if `a < `b {
      `return "Backtick return macro"; 
    }
    return 1;
  }
}

main :: () {
  a := 0;
  macro1(); // (3)
  print("a is: %\n", a); // (4) => a is: 10

  b := 7;
  c := 3;
  print("max is %\n", maxm(b, c)); // => max is 7

  print("macro2 returns %\n", macro2()); // => macro2 returns 1

  macro3();
  // => This is macro3
  // => This is a nested macro

  x := factorial(5);
  print("factorial of 5 = %\n", x); // => factorial of 5 = 120

  s := macfunc();  // => Defer inside macro
  print("%\n", s); // (6) => Backtick return macro
}