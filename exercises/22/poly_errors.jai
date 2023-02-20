#import "Basic";

array_add1 :: (arr: [..]$T, value: T)  {}
array_add2 :: (arr: [..]T, value: $T)  {}

main :: () {
    nums: [..]int;

    array_add1(nums, "not an int");
    // => Error: Type mismatch. Type wanted: int; type given: string.

    array_add2(nums, "not an int");    
    // => Error: Type mismatch. Type wanted: string; type given: int.
}