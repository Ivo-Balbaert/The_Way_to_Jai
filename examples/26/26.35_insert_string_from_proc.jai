#import "Basic";

// helper proc to generate a string that represents code
gen_code :: (v: int) -> string {
  // compile-time string alloc and format!
  return tprint("x *= %;", v);
}

factorial :: (x: int) -> int {
  if x <= 1 return 1;
  return x * factorial(x-1);
}

main :: () {
    x := 3;
    #insert "x *= 3;";          // (1)
    print("%\n", x); // => 9

    // generate and insert x *= 3;
    #insert #run gen_code(3);   // (2)
    print("%\n", x); // prints 27

    // compile-time run factorial(3) to produce 6
    // insert code x *= 6
    #insert #run gen_code(factorial(3));
    print("%\n", x); // print 54
}