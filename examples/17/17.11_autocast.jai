#import "Basic";

test_xx :: (f: float) {
  print("f is %\n", f); 
}

main :: () {
    n: int = 5;
    // (1) test_xx(n);  // Error: Number mismatch. Type wanted: float; type given: int. 
    test_xx(xx n);   // (2) => f is 5
}

