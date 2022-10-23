
#import "Basic";

describe_array :: (x: [$N] $T) {    // (1)
    print("An array of % items of type %\n", N, T);
}

main :: () {
    x := int.[1,2,3,4];
    describe_array(x); // => An array of 4 items of type s64
}