#import "Basic";

count1 :: (x: $T) -> s64 { return x.count; }
count2 :: x => x.count;

main :: () {
    array_a := int.[1, 2, 3, 4, 5, 6, 7, 8];
    array_dyn: [..]float;
    array_add(*array_dyn, 1.2);
    array_add(*array_dyn, 2.4);
    array_add(*array_dyn, 3.1415);
    str := "The quick brown fox";

    print("count of array_a is %\n", count1(array_a));
    // => count of array_a is 8
    print("count of array_dyn is %\n", count1(array_dyn));
    // => count of array_dyn is 3
    print("count of str is %\n", count1(str));
    // => count of str is 19

    print("count of array_a is %\n", count2(array_a));
    // => count of array_a is 8
    print("count of array_dyn is %\n", count2(array_dyn));
    // => count of array_dyn is 3
    print("count of str is %\n", count2(str));
    // => count of str is 19

    defer array_free(array_dyn);
}

