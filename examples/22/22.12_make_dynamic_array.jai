#import "Basic";

make_dynamic_array :: ($T: Type, allocator: Allocator, capacity := 8) -> [..]T {
    arr: [..]T;
    arr.allocator = allocator;
    array_reserve(*arr, capacity);
    return arr;
}

main :: () {
    arrdyn := make_dynamic_array(int, temp);
    print("%\n", arrdyn); // => []
}