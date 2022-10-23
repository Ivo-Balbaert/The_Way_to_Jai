#import "Basic";
#import "Math";

main :: () {
  a := Vector3.{1.0, 2.0, 3.0};
  b := Vector3.{3.0, 4.0, 2.5};
  c := a + b;             // (1)
  c += a;                 // (2)
  print("c = %\n", c);    // => c = {5, 8, 8.5}

  a2 := Vector3.{3.0, 4.0, 5.0};  
  c2 := a2 * 3;           // (3)
  print("c2 = %\n", c2);  // => c2 = {9, 12, 15}
  c3 := 3 * a2;           // (4)
  print("c3 = %\n", c3);  // => c3 = {9, 12, 15}
}