# Chapter 18B - Ordered remove in arrays

In § 18.4, we used **remove** to delete a value from an array. However, then the value was replace by the last array item. What if we just want the array items to stay in place?
Solution: use the _array_ordered_remove_by_index_ proc

See *18B_ordered_remove.jai*:

```c++
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

```

In line (1) we see how the normal remove works. Lines (2) and following show the ordered remove in action, with the result shown in line (3).