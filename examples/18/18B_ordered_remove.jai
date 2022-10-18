#import "Basic";

main :: () {
    strings : [..]string;
    defer array_free(strings);
    array_add(*strings, "Hello", "Sailor", "!", "Hello", "Sailor", "!");

    print("Before: %\n", strings);
    // => Before: ["Hello", "Sailor", "!", "Hello", "Sailor", "!"]

    // for s : strings {
    //     if s == "Sailor" {
    //         remove s;
    //     }
    // }
    // print("After: %", strings); // => After: ["Hello", "!", "!", "Hello"]  // (1)

    for s, sIndex : strings {   // (2)
       if s == "Sailor" {
           array_ordered_remove_by_index(*strings, sIndex);
           sIndex -= 1;
       }
    }
    print("After: %", strings); // (3) => After: ["Hello", "!", "Hello", "!"]
}
