#import "Basic";
#import "Math";

proc1 :: () { print("This is proc1 :: ()\n"); }
proc2 :: () -> int { 
    print("This is proc2 :: ()\n");
    return 42;
}

#run proc1();             // (1) => This is proc1 :: ()
result := #run proc2();   // (2) => This is proc2 :: ()
PIA :: #run compute_pi();  // (3)

compute_pi :: () -> float {
  // calculate pi using the Leibniz formula.
  n := 1.0;
  s := 1.0;
  pi := 0.0;

  for 0..10000 {
    pi +=  1.0 / (s*n);
    n += 2.0;
    s = -s;
  }
  return pi*4.0;
}

globvar := 0;
#run { globvar = 108; } // (7A)

main :: () {
    proc1();        // => This is proc1 :: () - proc1 is called at run-time

    print("result is %\n", result); // => result is 42   
    print("PIA is %\n", PIA); // => PIA is 3.141699

    // PIA2 :: compute_pi(); // Error: Declaration claims to be 
    // constant, but uses an expression that is not constant.
    PIA2 := compute_pi();

    print("globvar at runtime is: %\n", globvar); // (7B) => globvar at runtime is: 0

    f1 :: ()  => 1000;
    f2 :: (c) => c + 1;

    a :: #run f1();     // (4)
    b :: #run f2(a);    // (5)
    print("a=%, b=%\n", a, b); // => a=1000, b=1001

    #run {              // (6)
        print("I am running this block only at compile-time!");
        n := 108;
    }

    R22 :: 0.7071068;
    TAU :: 6.0;
    v, v2: Vector3;
    v = .{cast(float) #run sin(R22 * .5), 1, 0};
    // v2 = .{sin(TAU * .5), 1, 0}; // Error: All values provided in a struct literal must be constant, but argument 1 is not.
}

/* Output when compiling:
This is proc1 :: ()
This is proc2 :: ()
I am running this block only at compile-time!
*/

/* Output when running:
This is proc1 :: ()
result is 42
PI is 3.141699
a=1000, b=1001
*/