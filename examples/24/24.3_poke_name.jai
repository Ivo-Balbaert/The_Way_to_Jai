#import "Basic";
Math :: #import "Math";

Vector4 :: struct { x, y, z, w : float; };

dot_product :: (a: Vector4, b: Vector4) -> float { 
    return a.x*b.x+a.y*b.y+a.z*b.z+a.w*b.w; 
}

#poke_name Math dot_product;        // (1)

main :: () {
    v1 := Vector4.{1, 2, 3, 4};
    v2 := Vector4.{6, 7, 8, 9};
    print("dot_product is: %", Math.dot(v1, v2)); // (2)
    // => dot_product is: 80
}

