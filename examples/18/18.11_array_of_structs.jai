#import "Basic";

Vec2 :: struct {
    x: float = 1;
    y: float = 4;
}

main :: () {
    va: [10] Vec2;                      // (1)
    print("% %\n", va[7].x, va[7].y); // => 1 4
    // loop through array:
    for va print("% % - ", it.x, it.y);  // (2)
    // => 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 -
    print("\n"); 
    va2 : [10]Vec2 = ---;                // (3)
    print("% %\n", va2[7].x, va2[7].y);  // => 0 0 // undefined behavior prints mostly 0 0
}