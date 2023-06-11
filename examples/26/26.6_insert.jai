#import "Basic";

my_code :: #string END_STRING
  a += 100;
  b += 100;
  c += 1000;
END_STRING;

main :: () {
    add :: (n: int, m: int) -> int { return n + m; };

    a := 1;
    b := 2;
    #insert "c := a + b;";   // (1)
    print("c is %\n", c);    // => c is 3

    d :: "add(42, 8);";      // (2)
    x := 1 - #insert d;
    print("x = %\n", x);     // => x = -49

    #insert my_code;         // (3) 
    print("a, b, c are % % % \n", a, b, c);    // => a, b, c are 101 102 1003
}
