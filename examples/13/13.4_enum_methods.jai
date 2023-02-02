#import "Basic";

Direction :: enum {
    EAST;  
    NORTH; 
    WEST;  
    SOUTH; 
}

main :: () {
    low, high := enum_range(Direction);
    print("The values range from % to %\n", low, high); 
    // => The values range from 0 to 3

    print("Values: ");
    values :=  enum_values_as_s64(Direction);
    print("%\n", values); // => Values: [0, 1, 2, 3]
    names := enum_names(Direction);
    print("\nThe values as strings are: %\n", names);
    // => The values as strings are: ["EAST", "NORTH", "WEST", "SOUTH"]
}