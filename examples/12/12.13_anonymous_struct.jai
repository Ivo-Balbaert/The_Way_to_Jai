#import "Basic";

state: struct {
    a, b: int;
};

variable := struct {
  x: int;
  y: int;
  z: int;
}

Vector3 :: struct {
  union {
    struct { x, y, z: float; }
    struct { r, g, b: float; }
    struct { s, t   : float; }
  }
}

main :: () {
    some_function :: () {
        state.a = 4;
    }

    some_function();
    print("state is: % - %\n", state.a, state.b); // => state is: 4 - 0
    print("variable is: %", variable); // => variable is: u64
}

