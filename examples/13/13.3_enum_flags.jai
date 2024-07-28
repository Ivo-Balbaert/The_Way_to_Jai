#import "Basic";

Direction :: enum_flags u8 {
    EAST;  // == 1 == 0b00_01
    NORTH; // == 2 == 0b00_10
    WEST;  // == 4 == 0b01_00
    SOUTH; // == 8 == 0b10_00
}

main :: () {
    d: Direction;
    using Direction;
    d = WEST;            
    print("d is %, of type %.\n", d, type_of(d));
    d = EAST | WEST;
    print("d is %\n", d);
    d = EAST | WEST | NORTH | SOUTH;
    print("d is %\n", d);
    d &= ~SOUTH;   // mask the SOUTH flag
    print("d is %\n", d);

    e: Direction = .WEST | .EAST;   // (1)
    f: Direction = .WEST;
    g: Direction = 1; 
    h: Direction = Direction.WEST + 1;
    print("e: % - f: % - g: % - h: %\n", e, f, g, h);
    // => e: EAST | WEST - f: WEST - g: EAST - h: EAST | WEST
}

/*
d is WEST, of type Direction.
d is EAST | WEST
d is EAST | NORTH | WEST | SOUTH
d is EAST | NORTH | WEST
*/

/* Explanation:
0001
0010
0100
1000
| --> 1111
~ .SOUTH = ~ 1000 = 0111

  1111
& 0111
  0111 <--> EAST | NORTH | WEST
  */