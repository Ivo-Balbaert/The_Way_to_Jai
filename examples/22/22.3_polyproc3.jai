#import "Basic";

arr_sum :: (a: [] $T) -> T {   // (1)
    result: T;
    for a result += it;
    return result;
}

main :: () {
    arr: [4] int;
    arr[0] = 45;
    arr[1] = 42;
    arr[2] = 43;
    arr[3] = 100;
    print("The sum over the array of ints is: %\n", arr_sum(arr)); // (2) 
    // => The sum over the array of ints is: 230

    arr2: [4] float32;
    arr2[0] = 4.5;
    arr2[1] = 4.2;
    arr2[2] = 4.3;
    arr2[3] = 10.0;
    print("The sum over the array of floats is: %\n", arr_sum(arr2)); // (3) 
    // => The sum over the array of floats is: 23
}
