#import "Basic";

print_int_array :: (arr: [] int) {
    print("Array has size % - ", arr.count);
    for arr print("arr[%] = % / ", it_index, it);
    // for i: 0..arr.count-1 {
    //     print("arr[%] = % / ", i, arr[i]);
    // }
    print("\n");
}

add_numbers :: (numbers: [] int) -> int {   
    sum := 0;
    for numbers sum += it;
    return sum;
}

main :: () {
    N :: 4;
    static_array: [N]int = .[0, 1, 2, 3]; 
    // Printing an array:
    print_int_array(static_array); // (1)
    // => Array has size 4 - arr[0] = 0 / arr[1] = 1 / arr[2] = 2 / arr[3] = 3 / 

    dynamic_array : [..]int;
    defer array_free(dynamic_array);
    array_add(*dynamic_array, 4);
    array_add(*dynamic_array, 5);
    array_add(*dynamic_array, 6);
    print_int_array(dynamic_array); // (2)
    // => Array has size 3 - arr[0] = 4 / arr[1] = 5 / arr[2] = 6 /

    sum := add_numbers(.[1, 2, 3, 4, 5]); // (3)
    print("sum is %\n", sum); // => sum is 15
    sum = add_numbers(static_array);
    print("sum is %\n", sum); // => sum is 6
    sum = add_numbers(dynamic_array);
    print("sum is %\n", sum); // => sum is 15
}


