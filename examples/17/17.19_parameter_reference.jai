#import "Basic";
#import "Math";

perlin :: (p: Vector2) -> Vector2 {
    p_ := p;                                                           // (1) 
    // p *= 2.;  // => Error: Can't assign to an immutable argument.   // (2)
    p_ *= 2;
    return p_;
}

main :: () {
   v1 := Vector2.{1.2, 3.14};  
   v2 := perlin(v1);
   print("v2 is %", v2); // => v2 is {2.4, 6.28}
}
