#import "Basic";

main :: () {
// declaring and assigning in one code-line:
    n1: u8; m1: u8; n1 = 12; m1 = 13; // (1)
    print("% %\n", n1, m1); // => 12 13

// compound assignment is NOT allowed:
  // n1: u8;    m1: u8;     n1 = m1 = 13; // (2) => Error: Operator '=' can only be used at statement level.
  // but write it as:
    n2, m2 : u8 = 12, 13;   // (3) Full declaration and initialization: 	
    print("% %\n", n2, m2); // => 12 13
// or shorter with type inference:
    n3, m3 := 12, 13;
// works also for one rvalue and multiple lvalues, also for assignment:
    p, q, r := 13;  
    print("% % %\n", p, q, r); // => 13 13 13

// values of different types or expressions:
    x, y := 1, "hello";      // an int and a string
    print("x is % and y is %\n", x, y);         // => x is 1 and y is hello
    s, t := 2 + 3, 2 * 3;
    print("s is % and t is %\n", s, t);
    s1, t1 := #run(2 + 3), #run(2 * 3);
    print("s1 is % and t1 is %\n", s1, t1);     // => s is 5 and t is 6

  // i, j : int;
  // i, j = n1 + 1, m1 + 1;
  // or shorter:
    i, j := n1 + 1, m1 + 1;

  // multiple declaration, default values, and subsequent assignment:
    n4, m4 : int;
    print("n4 is % and m4 is %\n", n4, m4);     // => n4 is 0 and m4 is 0
    n4, m4 = 1, 2; 
    print("n4 is % and m4 is %\n", n4, m4);     // => n4 is 1 and m4 is 2

   // advanced compound assignment:
    b := 5;
    a, b=, c := 1, 2, 3;                       // (4)
    print("a is % b is % c is %\n", a, b, c);  //  => a is 1 b is 2 c is 3
    a, d:, c = 4, 5, 6;                        // (5)
    print("a is % c is % d is %\n", a, c, d);  // => a is 4 c is 6 d is 5
}

/* Output:
12 13
12 13
13 13
x is 1 and y is hello
s is 5 and t is 6
s1 is 5 and t1 is 6
n4 is 0 and m4 is 0
n4 is 1 and m4 is 2
a is 1 b is 2 c is 3
a is 4 c is 6 d is 5
*/