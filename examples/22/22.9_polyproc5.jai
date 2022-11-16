#import "Basic";

Ice_Cream_Info :: struct {
    temperature   := -10.0;
    flavor        := "vanilla";
    num_scoops    := 2;
    cone_style    := "waffle";
    add_sprinkles := false;
}

check_temperature :: (s: $T) { // T is any struct with a member named 'temperature'.
    if s.temperature < -20  print("Too cold!!!\n");
    else                    print("Temperature okay!\n");
}

main :: () {
    check_temperature(Ice_Cream_Info.{num_scoops=4, add_sprinkles=true}); // (1)
    // => Temperature okay!
    // check_temperature(.{num_scoops=4, add_sprinkles=true}); // (2)
    // => Error: Attempt to match a literal, without a type designation, 
    // to a polymorphic variable. This would not define the type of the struct literal, so, 
    // it doesn't make sense.
}

/* 

*/