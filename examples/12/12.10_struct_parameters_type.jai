#import "Basic";

Entity :: struct (Payload: Type) {           // (1)
        payload: Payload;
}

proc :: (x: Entity) {                        // (3) 
    print("type_of(x) is %\n", type_of(x));  // (4)
    // => type_of(x) is Entity(Payload=(anonymous struct))
    print("x is %\n", x);
    // => x is {{"Volodimir", false}}
}
    
main :: () {
    thing: Entity(struct {name := "Volodimir"; typos := false;});  // (2) 
    proc(thing);
}

