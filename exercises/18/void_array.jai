#import "Basic";

main :: () {
    test := [100_000]void;
    print("% bytes", size_of(type_of([100000] void)) ); // => 8 bytes
}

