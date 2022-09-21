#import "Basic";

main :: () {
  print("1, ");
  defer print("5, ");
  print("2, ");
  defer print("4, ");
  print("3, ");
}

// => 1, 2, 3, 4, 5,