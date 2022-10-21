#import "Basic";

add :: (a, b) => a + b;
// create an add10 function that adds 10 to a given number
add10 :: #bake_arguments add(a=10); 

mult :: (a: float, b: float) -> float {
    return a * b;
}

mult1 :: #bake_arguments mult(b = -9);

// structs:
A :: struct (M: int, N: int) {
  array: [M][N] int;
}

AA :: #bake_arguments A(M=10);

main :: () {
  b := 20;
  c := add10(b);  
  print("c is %\n", c);               // => c is 30
  print("mult1(2) is %\n",mult1(2));  // => mult1(2) is -18

  a: AA(N=2);
  print("a=(%, %)\n", a.M, a.N);       // => a=(10, 2)
}