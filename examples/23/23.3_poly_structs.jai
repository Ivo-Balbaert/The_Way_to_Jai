#import "Basic";

TwoD :: struct (M: int, N: int) {           // (1)
  array: [M][N] int;
}

TwoDb :: #bake_arguments TwoD(M = 5);       // (2)

main :: () {
  twod: TwoDb(N = 2);                        // (3)
  print("twod is %\n", twod);                // (4) 
  // => twod is {[[0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]}
  print("its dimensions are (%, %)\n", twod.M, twod.N);  // (5) 
  // => its dimensions are (5, 2)
}