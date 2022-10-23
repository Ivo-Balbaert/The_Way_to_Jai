/*
In Workspace 2 ("Target Program"):
d:/Jai/program_errors/polymorphic2.jai:10,33: Error: When trying to evaluate a constant Type, a non-constant declaration was encountered.

    display_xy :: (v: $T) {
       print("x coordinate is %\n", v.x);

d:/Jai/program_errors/polymorphic2.jai:9,16: Error: ... Here is the problematic declaration.

    }
    display_xy :: (v: $T) {
*/
#import "Basic";
#import "Math";

display_xy :: (v: $T) { 
   print("x coordinate is %\n", v.x); 
   print("y coordinate is %\n", v.y); 
}

main :: () {
  v2 := Vector2;
  display_xy(v2);
}

