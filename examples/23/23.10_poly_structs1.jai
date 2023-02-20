#import "Basic";

Vec :: struct($T: Type, $N: s64) {
  values : [N]T;
}

main :: () {
    // a simple vector of 3 floats
    Vec3 :: Vec(float, 3);
    v1 := Vec3.{.[1,2,3]};

    // a big vector of 1024 ints 
    BigVec :: Vec(int, 1024);
}