#import "Basic";

Point3D :: struct {
  x, y, z: float;
}

main :: () {
  pnt := Point3D.{1,2,3};
  using pnt;
  // no need to do pnt.x, just access x directly
  print("The coordinates of pnt are % % %\n", x, y, z);  
  // => The coordinates of pnt are 1 2 3
}
