#import "Basic";

Vector3 :: struct { x, y, z: float; }

operator * :: (p: Vector3, q: Vector3) -> Vector3 {
    r: Vector3 = ---;
    r.x = p.x * q.x;
    r.y = p.y * q.y;
    r.z = p.z * q.z;
    return r;
}

square :: (n: $T) -> T {
    return n * n;
}

main :: () {
    print("square(5) is %\n", square(5)); // => square(5) is 25
    print("square(3.14) is %\n", square(3.14)); // => square(3.14) is 9.859601
   
    v := Vector3.{1, 2.5, 4};
    print("square(v) is %\n", square(v)); 
    // Without operator *: Error: Procedure call did not match any of the possible overloads.
    // With operator * => square(v) is {1, 6.25, 16}
}

