#import "Basic";

Vec2D :: struct {  x, y: float;  }

make_vec2D :: (x: float, y: float) -> Vec2D {
    v: Vec2D;
    v.x = x;
    v.y = y;
    return v;
}

main :: () {
    vec1 := make_vec2D(1.0, 3.14);
    print("vec1 has x coordinate % and y coordinate %\n", vec1.x, vec1.y);  
    // => vec1 has x coordinate 1 and y coordinate 3.14
    vec2 := Vec2D.{1.0, 3.14};
}
 
