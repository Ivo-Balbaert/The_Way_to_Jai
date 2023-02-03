#import "Basic";
#import "Math";

Direction :: enum {
    NORTH;      
    SOUTH;      
    EAST;      
    WEST;         
}

Operating_Systems :: enum u16 #specified {
        VMS      :: 1;
        ATT_UNIX :: 2;
        WINDOWS  :: 3;
        GNU_SLASH_LINUX :: 4;
}

main :: () {
    info := type_info(Direction); // (5) this is a *Type_Info_Enum
    print("enum '%' is ", info.name); // => enum 'Direction' is
    if info.enum_type_flags & .SPECIFIED    print("specified.\n");
    else print("*NOT* specified.\n");       // => *NOT* specified.
    
    info = type_info(Operating_Systems); 
    print("enum '%' is ", info.name); // => enum 'Operating_Systems' is .
    if info.enum_type_flags & .SPECIFIED    print("specified.\n"); // => specified
    else print("*NOT* specified.\n");
}