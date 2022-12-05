#import "Basic";

proc1 :: (a : $T)    // (1)
#modify {
    T = s64;         // (3)
    return true;
}
{
    print("a is %, of type %\n", a, T);
}

main :: () {
    var_s8  : s8  = 1;
    var_s16 : s16 = 2;
    var_u32 : u32 = 3;
    var_s64 : s64 = 4;

    proc1(var_s8);   // (2) => a is 1, of type s64
    proc1(var_s16);  // => a is 2, of type s64
    proc1(var_u32);  // => a is 3, of type s64
    proc1(var_s64);  // => a is 4, of type s64

    var_bool: bool = true;
    // proc1(var_bool);  // (4) Error: Type mismatch. Type wanted: int; type given: bool.
    proc1(xx var_bool);  // (5) => a is 1, of type s64
}