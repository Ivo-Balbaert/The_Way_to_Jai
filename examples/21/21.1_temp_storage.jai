#import "Basic";

make_array :: (x: int) -> [..] int {
    result: [..] int;
    result.allocator = temp;  // (1) 
    for 1..x array_add(*result, it);
    return result;
}

main :: () {
    b := "Resounding ";
    ch := "世界";
    temp_str := tprint("% %!\n", b, ch); // (2)
    print("%\n", temp_str); // => Resounding 世界!

    arrdyn := make_array(5);
    print("%\n", arrdyn); // => [1, 2, 3, 4, 5]

    s := talloc_string(256); // (6)

    builder: String_Builder;
    builder.allocator = temp;   // (6B)
    
    print("Temporary_Storage uses % bytes\n", context.temporary_storage.occupied); // (3)
    // => Temporary_Storage uses 344 bytes
    reset_temporary_storage(); // (4)
    print("Temporary_Storage uses % bytes\n", context.temporary_storage.occupied); // (5)
    // => Temporary_Storage uses 0 bytes
}