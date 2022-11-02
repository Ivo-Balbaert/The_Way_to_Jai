#import "Basic";

Compass_Direction :: enum {
    NORTH;      // 0
    SOUTH;      // 1
    EAST;       // 2 
    WEST;       // 3   
}

Key_Code :: enum u32 {    // (1)
    UNKNOWN;
    ARROW_LEFT;
    ARROW_RIGHT;
    ARROW_UP;
    ARROW_DOWN;
    SHIFT;
    ESCAPE;
}

Log_Mode :: enum {
    NONE;           
    MINIMAL;        
    EVERYDAY;       
    VERBOSE;         
}

Log_Mode2 :: enum {
    NONE;            // 0
    MINIMAL;         // 1
    EVERYDAY :: 300; // (3) 300
    VERBOSE;         // 301
}

MIDDLE_VALUE :: 8; // this can come after the enum which uses it

Log_Mode3 :: enum {
    NONE;                      // 0
    MINIMAL :: NONE;           // 0
    EVERYDAY:: MIDDLE_VALUE;   // (4) 8
    VERBOSE;                   // 9
} 

main :: () {
    dir1: Compass_Direction = .EAST;
    print("dir1 is %\n", Compass_Direction.EAST);
    dir1 = .SOUTH;
    // dir2 := .WEST; // Error: This declaration is bound to a unary '.' dereference 
    // that was never resolved, so there is no way to know its type. 
    // dir3: Compass_Direction = .SOUTH_WEST; // (5) - Error: 'SOUTH_WEST' is not a member of Compass_Direction.

    print("MINIMAL is %.\n", Log_Mode.MINIMAL);
    logv := Log_Mode.VERBOSE;
    log1 := Log_Mode3.MINIMAL;  
    log1 = 10;   
    log2 := cast(Log_Mode.loose) Log_Mode.MINIMAL;

    // namespace:
    print("The first direction is %\n", Compass_Direction.NORTH);
    using Compass_Direction; // (6) if not: following line Error: Undeclared identifier 'NORTH'.
    print("The first direction is %\n", NORTH);

}

/*
dir1 is EAST
MINIMAL is MINIMAL.
The first direction is NORTH
The first direction is NORTH
*/