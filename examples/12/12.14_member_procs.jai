#import "Basic";

Obj :: struct {
  x: int;
  set_x :: (obj: *Obj, x: int) {
    obj.x = x;
  }
}

set_x :: (obj: *Obj, x: int) {
    obj.x = x;
}

main :: () {
    o: Obj;
    // o.set_x(100); // this is not allowed
    Obj.set_x(*o, 100);
    print("o is %\n", o); // => o is {100}
    set_x(*o, 42);
    print("o is %\n", o); // => o is {42}
}