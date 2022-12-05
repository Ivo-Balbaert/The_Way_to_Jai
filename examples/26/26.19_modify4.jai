#import "Basic";

sum :: (array: [] $T) -> T {        // (1)
    result: T;
    for array  result += it;
    return result;
}

sum2 :: (a : [] $T) -> $R           // (4)
#modify {
    R = T;                          // (5)
    ti := cast(*Type_Info) T;       // (6)
    if ti.type == .INTEGER {        // (7)
        info := cast(*Type_Info_Integer) T; // (8)
        if info.runtime_size < 4 {  // (9)
            if info.signed R = s32; // (10) 
            else           R = u32;
        }
    }
    return true;
}
{ 
    result : R = 0;
    for a result += it;
    return result;
}

main :: () {
    floats := float.[1, 4, 9, 16, 25, 36, 49, 64, 81];  // (2)
    ints   := int  .[1, 4, 9, 16, 25, 36, 49, 64, 81];
    u8s    := u8   .[1, 4, 9, 16, 25, 36, 49, 64, 81];

    print("sum of floats is %\n", sum(floats)); // => sum of floats is 285
    print("sum of ints   is %\n", sum(ints));   // => sum of ints is 285
    print("sum of u8s    is %\n", sum(u8s));       // (3) => sum of u8s is 29

    print("sum2 of u8s %\n", sum2(u8s));    // (11) => sum2 of u8s 285
}