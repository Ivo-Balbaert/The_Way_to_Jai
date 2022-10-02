#import "Basic";

swap :: (x: int, y: int) -> (int, int) {    // (1)
    return y, x;
}

swap_all :: (x: Any, y: Any) -> (Any, Any) {  // (2)
    return y, x;
}

main :: () {
    a, b := swap(1, 2); 
    print("% %\n",a, b); // => 2 1
    c, d := swap_all(1, 2);
    print("% %\n", c, d); // => 2 1
}
