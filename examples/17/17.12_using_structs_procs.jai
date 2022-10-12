#import "Basic";

Vector2 :: struct {
    x: float = 1;
    y: float = 4;
}

Entity :: struct {
  position: Vector2;
}

print_position_a :: (entity: *Entity) {
  print("print_position_a: (%, %)\n", entity.position.x, entity.position.y);
}

print_position_b :: (entity: *Entity) {
  using entity;
  print("print_position_b: (%, %)\n", position.x, position.y);
}

print_position_c :: (using entity: *Entity) {
  print("print_position_c: (%, %)\n", position.x, position.y);
}

print_position_d :: (entity: *Entity) {
  using entity.position;
  print("print_position_d: (%, %)\n", x, y);
}

main :: () {
    e: Entity;

    print_position_a(*e); // => print_position_a: (1, 4)
    print_position_b(*e); // => print_position_b: (1, 4)
    print_position_c(*e); // => print_position_c: (1, 4)
    print_position_d(*e); // => print_position_d: (1, 4)
}