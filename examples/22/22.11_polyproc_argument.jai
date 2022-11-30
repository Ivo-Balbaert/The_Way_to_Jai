#import "Basic";

apply_int :: (f: (x: int) -> int, x: int, count: int) -> int {
        for 1..count x = f(x);
        return x;
}

square :: (x: $T) -> T {
        return x * x;
}

main :: () {
    b := apply_int(square, 4, 4);  // (1)
    print("b is %, of type %\n", b, type_of(b)); // => b is 4294967296, of type s64
}
