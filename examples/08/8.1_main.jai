#import "Basic";

#load "part1.jai";
#load "subfolder/part2.jai";
#load "part3.jai";

main :: () {
  print("Loaded all three part files\n");
  print("a_part1 is: %", a_part1);
}

/* =>
Loaded all three part files
a_part1 is: 42
*/