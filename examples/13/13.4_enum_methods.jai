#import "Basic";

Direction :: enum {
    EAST;  
    NORTH; 
    WEST;  
    SOUTH; 
}

main :: () {
    low, high := enum_range(Direction);
    print("The values range from % to %\n", low, high); // 0 to 3

    print("Values:\n");
    values :=  enum_values_as_s64(Direction);
    for values  print("% - ", it); // => 0 - 1 - 2 - 3 -

    names := enum_names(Direction);
    print("\nThe values as strings are: %\n", names);
}
/*
The values range from 0 to 3
The values as strings are: ["EAST", "NORTH", "WEST", "SOUTH"]
*/