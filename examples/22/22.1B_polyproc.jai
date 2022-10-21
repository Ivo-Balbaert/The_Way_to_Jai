#import "Basic";

convert :: (arg: $T) {
    print("% of type %, cast to bool is %\n", arg, type_of(arg), cast(bool) arg);
}

main :: () {
    convert(0);             // => 0 of type s32, cast to bool is false
    convert(1);             // => 1 of type s32, cast to bool is true
    convert(cast(s8) -37);  // => -37 of type s32, cast to bool is true

    convert(69105.33);          // (1)
    // => 69105.328125 of type float32, cast to bool is true
    convert("Hello, Sailor!");  // (2)
    // => Hello, Sailor! of type string, cast to bool is true
    arr := int.[1, 2, 3, 4, 5];
    convert(arr);               // (3)
    // => [1, 2, 3, 4, 5] of type [] s64, cast to bool is true
    arr2 := bool.[true, false, true, false];
    convert(arr2);              // (4)
    // => [true, false, true, false] of type [] bool, cast to bool is true
}


