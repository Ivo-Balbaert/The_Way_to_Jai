#import "Basic";

main :: () {
    arrdyn : [..]int;          // (1) dynamic array of integers.
    another_array : [..]int;
    another_array2 : []int;      
    b : [..]string;            // (2) dynamic array of strings.

    // clean up memory
    defer array_free(arrdyn);     // (3)
    defer free(*another_array);   // (4)
    defer free(*another_array2);   
    defer free(*b);   // 
    
    array_add(*arrdyn, 5);  // (5) Add 5 to the end of arrdyn
    array_add(*arrdyn, 9);  // Add 9 to the end of arrdyn
    array_add(*arrdyn, 13); // Add 13 to the end of arrdyn
    print("arrdyn is: %\n", arrdyn); // => arrdyn is: [5, 9, 13]

    print("Last item is %\n", peek(arrdyn)); // (5B) => Last item is 13
    print("arrdyn is: %\n", arrdyn); // => arrdyn is: [5, 9, 13]
    print("Last item is %\n", pop(*arrdyn)); // (5C) => Last item is 13
    print("arrdyn is: %\n", arrdyn); // => arrdyn is: [5, 9]
    
    print("%\n", array_find(arrdyn, 5));  // (6) => true -  looks for 5 in arrdyn

    for arrdyn {
        if it == 5 remove it;       // (7)
    }
    print("arrdyn is: %\n", arrdyn); // => arrdyn is: [13, 9]

    print("another_array is: %\n", another_array); // => another_array is: []
    array_copy(*another_array, arrdyn); // (8) copy arrdyn into another_array
    print("another_array is: %\n", another_array); // => another_array is: [13, 9]
    another_array2 = array_copy(arrdyn); // (8B)
    print("another_array2 is: %\n", another_array2); // => another_array2 is: [13, 9]
  
    array_reset(*arrdyn);  // (9) Reset (empties) arrdyn
    print("arrdyn is: %\n", arrdyn); // => arrdyn is: []

    // filling an array:
    N :: 100;
    for 0..N-1  array_add(*arrdyn, it);   // (10)
    // for i: 0..N-1  array_add(*arrdyn, i); // alternative for (10)

    array_reset(*arrdyn);  // 
    M :: 50;
    // more performant way:
    array_reserve(*arrdyn, M); // (11) - Reserve 50 items!
    for 1..M array_add(*arrdyn, it);  // 
}