#import "Basic";
#import "Math";

// Example 1:
display_xy :: (v: $T) {                             // (1)
   print("x coordinate is %\n", v.x); 
   print("y coordinate is %\n", v.y); 
}

baked1 :: #bake_constants display_xy(T = Vector2);  // (2)

// Example 2:
random :: () -> $T { 
    value := 0xcafe;  
    return cast(T) value;
}

random_s32 :: #bake_constants random(T = s32);   // (5)
random_u8  :: #bake_constants random(T = u8);    // (6)

// Example 3:
named_bake_test :: (a1: $A, a2: A, b1: $B, b2: B) -> A, B { // (9)
    a_sum := a1 + a2;
    b_product := b1 * b2;
    return a_sum, b_product;
}

nbt :: #bake_constants named_bake_test(A = float, B = int);  // (10)

main :: () {
    v2 := Vector2.{1, 2};
    baked1(v2); // (3)
    // => x coordinate is 1
    // => y coordinate is 2
    v3 := Vector3.{1, 2, 3};
    // baked1(v3); // Error: Type mismatch: incompatible structs (wanted 'Vector2', given 'Vector3').

    // random();  // (4) Error: Compile-time variable 'T' is needed but was not specified.
    print("%\n", random_s32() ); // (7) => 51966
    // print("%\n", random_u8() ); // (8) Cast bounds check failed.  Number must be in [0, 255]; it was 51966.

    sum, product := nbt(1, 2, 3, 4);  // (11)
    print("Sum is %, product is %\n", sum, product);
    // => Sum is 3, product is 12
}



