#import "Basic";

main :: () {
// for loop over a range:
    for 1..5 print("Number % - ", it);              // (1)
    print("\n");
    for number: 1..5 print("Number % - ", number);  // (2)
    print("\n");
    
    count := 5;           // (3)
    for n: 1..count {
        print("Number % - ", n);
    }
    print("\n");

// Reverse for loop: 
    for < i: 5..0 { // (4) => 5 4 3 2 1 0
        print("% - ", i); 
    }
    print("\n");

// Nested for loops:
    for i: 1..5 {   // (5)
        for j: 10..15 {
            print("%, % / ", i, j);
        }
        print("\n");
    }
// Casting the index:
    for i: 0..cast(u8)255 { // (6) // casts i to u8.
       print("% - ", i);
    }
    // => 0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - ...
}

/*
Number 1 - Number 2 - Number 3 - Number 4 - Number 5 - 
Number 1 - Number 2 - Number 3 - Number 4 - Number 5 -
Number 1 - Number 2 - Number 3 - Number 4 - Number 5 -
5 - 4 - 3 - 2 - 1 - 0 -
1, 10 / 1, 11 / 1, 12 / 1, 13 / 1, 14 / 1, 15 /
2, 10 / 2, 11 / 2, 12 / 2, 13 / 2, 14 / 2, 15 /
3, 10 / 3, 11 / 3, 12 / 3, 13 / 3, 14 / 3, 15 /
4, 10 / 4, 11 / 4, 12 / 4, 13 / 4, 14 / 4, 15 /
5, 10 / 5, 11 / 5, 12 / 5, 13 / 5, 14 / 5, 15 /
0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 
*/
