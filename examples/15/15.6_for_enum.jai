#import "Basic";

Direction :: enum {
    EAST;  
    NORTH; 
    WEST;  
    SOUTH; 
}

main :: () {
    print("% contains the following values:\n", Direction);
    for enum_values_as_s64(Direction) {         // (1)
        print("\t%: %\n", it, cast(Direction) it);
    }
}
/*
Direction contains the following values:
        0: EAST
        1: NORTH
        2: WEST
        3: SOUTH
*/