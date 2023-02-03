#import "Basic";

Thing :: struct {
    x: int; @amount
}

main :: () {
    s := type_info(Thing).members[0].notes[0]; 
    print("The note of field x is: %", s); 
    // => The note of field x is: amount
}

