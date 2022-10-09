#import "Basic";

main :: () {
    static_array := int.[1, 2, 3, 4, 5];
    print("% \n", static_array); // => [1, 2, 3, 4, 5] 
    for *p: static_array { <<p += <<p; }
    print("% \n", static_array); // => [2, 4, 6, 8, 10]
    i := 0;
    while i < static_array.count-1 {
        static_array[i] = static_array[i] * 2;
        i += 1;
    }
    print("% \n", static_array); // => [4, 8, 12, 16, 10]
}