#import "Basic";

A :: struct {
  data: int = 108;
}

B :: struct {
  using #as a: A;  // (1) 
}

proc1 :: (a: A) {
  print("Calling proc :: (a: A)\n");
}

proc2 :: (using a: A) {
  print("a.data = %\n", data);
}

main :: () {
  a: A;
  b: B;
 
  proc1(b);   // (2) => Calling proc :: (a: A)
  proc2(a);   // => a.data = 108
  proc2(b);   // (3) => a.data = 108
}