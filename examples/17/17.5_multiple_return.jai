#import "Basic";

proc1 :: () -> int, int {   // (1)
    return 3, 5;
}

proc2 :: () -> a: int, b: int {  // (1B)
  a := 100;
  b := 200;
  return a, b;
}

proc3 :: (var: bool) -> a: int = 100, b: int = 200 {  // (1C)
  if var == true then
    return; 
  else
    return 1_000_000; //
}

mult :: (n1: float, n2: float) -> float #must {  // (2)
    return n1 * n2;
}

main :: () {
    a := proc1();         // (2B)
    print("a is %\n", a); // => a is 3

    b, c := proc3(true);   // (2C)
    print("%, %\n", b, c); // =>  100, 200

    d, e := proc3(false);  // (2D)
    print("%, %\n", d, e); // => 1000000, 200
    // x, y: int;
    // x, y = proc1();
    // shorter:
    x, y := proc1();        // (3)
    print("x is % and y is %\n", x, y); // => x is 3 and y is 5
    n := 3.14;
    m := 5.18;
    print("mult is %\n", mult(n, m)); // => mult is 16.2652
    // mult(n, m); // (4) with #must 
    // => Error: Return value 1 is being ignored, which is disallowed by #must.
    mm := mult(n, m); // (5)
}
