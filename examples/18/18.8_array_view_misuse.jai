#import "Basic";

main :: () {
        a: [..] int;
        for 1..10 array_add(*a, it);  // Just fill a with some values.
        v: [] int = a;                // Make a view onto a.
        for 1..10 array_add(*a, it);  // (3) Add more items to a.

        for a print("% - ", it);
        // (4) => 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 
        print("\n");
        for v print("% / ", it);       // (5) 
        // => 2487748255840 / 2487748277696 / 3 / 4 / 5 / 6 / 7 / 8 / 9 / 10 /
}

