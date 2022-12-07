#import "Basic";

#no_reset globvar := 0;
#run { globvar = 108; } // (1A)

array: [4] int;
#no_reset arraynr: [4] int;  // (2)

#run {                       // (3)
  array[0] = 1;
  array[1] = 2;
  array[2] = 3;
  array[3] = 4;
  arraynr[0] = 1;
  arraynr[1] = 2;
  arraynr[2] = 3;
  arraynr[3] = 4;
}

main :: () {
    print("globvar at runtime is: %\n", globvar); // (1B) => globvar at runtime is: 108

    print("%\n", array);   // (4) => [0, 0, 0, 0] 
    print("%\n", arraynr); // (5) => [1, 2, 3, 4]
}
