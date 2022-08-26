#import "Basic";

// global scope:
MASS_EARTH0 : float : 5.97219e24;  // (1) in kg
MASS_EARTH :: 5.97219e24;          // (2)

main :: () {
  MASS_MARS :: MASS_EARTH * 0.15;  // (3)
  print("The earth mass is %\n", MASS_EARTH);
  // => The earth mass is 5972189887017193070000000

  print("%\n", type_of(MASS_EARTH));     // (4) => float32
  print("%\n", is_constant(MASS_EARTH)); // (5) => true
}