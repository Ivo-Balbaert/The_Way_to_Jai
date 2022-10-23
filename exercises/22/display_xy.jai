#import "Basic";
#import "Math";

display_xy :: (v: $T) { 
   print("x coordinate is %, y coordinate is %\n", v.x, v.y); 
}

main :: () {
    v2 := Vector2.{1, 2}; // => x coordinate is 1, y coordinate is 2
    v3 := Vector3.{3.14, 3, 4};
    v4 := Vector4.{5, 6, 7, 8};

    display_xy(v2); // => x coordinate is 1, y coordinate is 2
    display_xy(v3); // => x coordinate is 3.14, y coordinate is 3
    display_xy(v4); // => x coordinate is 5, y coordinate is 6
}

