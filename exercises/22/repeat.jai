#import "Basic";

repeat :: (item: $T, count: s64) -> (output: [] T) {
    result: [..] T;
    for 1..count array_add(*result, item);
    return result;
}

main :: () {
    a := repeat(69105, 5);
    b := repeat("Hello, Sailor!", 3);

    print("a is %\n", a); // => a is [69105, 69105, 69105, 69105, 69105]
    print("b is %\n", b); // => b is ["Hello, Sailor!", "Hello, Sailor!", "Hello, Sailor!"]
}

