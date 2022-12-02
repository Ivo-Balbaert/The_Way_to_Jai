#import "Basic";

Color :: enum u8 { RED; YELLOW; GREEN; ORANGE; MAUVE; };  
    
Matchable :: struct {
    name:   string;
    color:  Color;
}

Thing :: struct {
    duration: float64;
    tag:      string;
    name:     string;
    type:     Type;
    color:    Color;
}

discuss :: (x: $T/interface Matchable) {
    print("type_of(x) is %\n", type_of(x));
    print("x has a name '%' and has color %.\n", x.name, x.color);
    print("The entirety of x is %\n", x);
}
    
main :: () {
    match := Matchable.{"Nice", .ORANGE};
    discuss(match);
    // => type_of(x) is Matchable
    // => x has a name 'Nice' and has color ORANGE.

    thing: Thing;
    thing.name  = "Kurt Russell";
    thing.tag   = "Hello";
    thing.type  = void;
    thing.color = .RED;
    discuss(thing);
    // => type_of(x) is Thing
    // => x has a name 'Kurt Russell' and is the color RED.
    // => The entirety of x is {0, "Hello", "Kurt Russell", void, RED}
}

/*

*/