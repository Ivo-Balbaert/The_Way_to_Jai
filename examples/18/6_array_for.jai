#import "Basic";

main :: () {
    N :: 14;
    static_array : [N]int; 
    dynamic_array : [..]int;
    unknown_size_array : []int = static_array;

    for static_array  static_array[it_index] = it;
    //for 0..static_array.count-1  static_array[it_index] = it;
    for 0..dynamic_array.count-1        dynamic_array[it] = it;
    for 0..unknown_size_array.count-1   unknown_size_array[it] = it;   
    
    // simple for:
    for static_array print("static array item = %\n", it);
    for dynamic_array print("Dynamic array item: %\n", it); // this array is still empty! --> no print
    for unknown_size_array print("Unknown size array item: %\n", it);

    for static_array        static_array[it_index] = it * it;
    // Printing an array:
    print_int_array(static_array);
    print_int_array(dynamic_array);
    print_int_array2(static_array);

    // for a: arr
    for n: static_array     print("arr[0] = %\n", n);

    // for value, index:
    for value, index: unknown_size_array {
        print("Array[%] = %\n", index, value);
    }

  // for loop over arrays:
  // Error: This declaration is bound to a struct or array literal that did not specify its type, so there is no way to know its type.
  //  my_array := .[5, 10, 15, 20, 25, 30];
    my_array := u8.[5, 10, 15, 20, 25, 30];
    for my_array {
        print("We got a %\n", it);
    } // or on 1 line

    foods := string.["Burek", "Pho", "Khachapuri", "Empanadas", "Jjajangmyeon"];
    print("Top five dishes:\n");
    for foods {
        print(" %. %\n", it_index, it);
    }

    // dynamic array:
    arr : [..]int;
    for i: 0..10 {
        array_add(*arr, i);
    }
    for a: arr {
        if a == 2 {
            remove a;
        }
    }
    print("the dynamic array arr is: %\n", arr); // => the dynamic array arr is: [0, 1, 10, 3, 4, 5, 6, 7, 8, 9]
    // removed item is replaced by last item!

    array := int.[1, 2, 3, 4, 5];
    for *elem: array {
        val := <<elem;
        <<elem = val * val; // take all the values in an array and square the items
    }
    print("array is: %\n", array); // => array is: [1, 4, 9, 16, 25]
} // end main

// Passing an array to a function:
print_int_array :: (arr: []int) {
    print("Array arr has size %\n", arr.count);
    for i: 0..arr.count-1 {
        print("arr[%] = %\n", i, arr[i]);
    }
}

// improved function:
print_int_array2 :: (arr : []int) {
    print("Array arr has size %\n", arr.count);
    for arr print("arr[%] = %\n", it_index, it);
}

/*
static array item = 0
static array item = 1
static array item = 2
static array item = 3
static array item = 4
static array item = 5
static array item = 6
static array item = 7
static array item = 8
static array item = 9
static array item = 10
static array item = 11
static array item = 12
static array item = 13
Unknown size array item: 0
Unknown size array item: 1
Unknown size array item: 2
Unknown size array item: 3
Unknown size array item: 4
Unknown size array item: 5
Unknown size array item: 6
Unknown size array item: 7
Unknown size array item: 8
Unknown size array item: 9
Unknown size array item: 10
Unknown size array item: 11
Unknown size array item: 12
Unknown size array item: 13
Array arr has size 14
arr[0] = 0
arr[1] = 1
arr[2] = 4
arr[3] = 9
arr[4] = 16
arr[5] = 25
arr[6] = 36
arr[7] = 49
arr[8] = 64
arr[9] = 81
arr[10] = 100
arr[11] = 121
arr[12] = 144
arr[13] = 169
Array arr has size 0
Array arr has size 14
arr[0] = 0
arr[1] = 1
arr[2] = 4
arr[3] = 9
arr[4] = 16
arr[5] = 25
arr[6] = 36
arr[7] = 49
arr[8] = 64
arr[9] = 81
arr[10] = 100
arr[11] = 121
arr[12] = 144
arr[13] = 169
arr[0] = 0
arr[0] = 1
arr[0] = 4
arr[0] = 9
arr[0] = 16
arr[0] = 25
arr[0] = 36
arr[0] = 49
arr[0] = 64
arr[0] = 81
arr[0] = 100
arr[0] = 121
arr[0] = 144
arr[0] = 169
Array[0] = 0
Array[1] = 1
Array[2] = 4
Array[3] = 9
Array[4] = 16
Array[5] = 25
Array[6] = 36
Array[7] = 49
Array[8] = 64
Array[9] = 81
Array[10] = 100
Array[11] = 121
Array[12] = 144
Array[13] = 169
We got a 5
We got a 10
We got a 15
We got a 20
We got a 25
We got a 30
Top five dishes:
 0. Burek
 1. Pho
 2. Khachapuri
 3. Empanadas
 4. Jjajangmyeon
the dynamic array arr is: [0, 1, 10, 3, 4, 5, 6, 7, 8, 9]
array is: [1, 4, 9, 16, 25]
*/