#import "Basic";

array: [4] int;
#no_reset arraynr: [4] int;  // (1)

#run {                       // (2)
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
  print("%\n", array);   // (3) => [0, 0, 0, 0] 
  print("%\n", arraynr); // (4) => [1, 2, 3, 4]
}
