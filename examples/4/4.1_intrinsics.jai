#import "Basic";

main :: () {
    x: int = 42;
    y: type_of(x);

    memcpy(*y, *x, size_of(type_of(x)));
    print("y is %\n", y);  // => y is 42; 
}

