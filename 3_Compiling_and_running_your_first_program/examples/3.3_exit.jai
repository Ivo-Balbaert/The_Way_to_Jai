#import "Basic";

main :: () {
  print("Before exiting\n"); // => Before exiting
  exit(0); // exits the program
  print("After exiting\n"); // <= this will never print!
}