#import "Basic";

add :: (a, b) => a + b;                 // (1)
add10 :: #bake_arguments add(a=10);     // (2)

mult :: (a: float, b: float) -> float {
    return a * b;
}

mult1 :: #bake_arguments mult(b = -9);  // (3)

main :: () {
  b := 20;
  c := add10(b);                      // (4)
  print("c is %\n", c);               // => c is 30
  print("mult1(2) is %\n",mult1(2));  //(5) => mult1(2) is -18
}