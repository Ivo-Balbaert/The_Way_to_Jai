#import "Basic";

add_int :: (a: s32, b: s32) -> s32                   #foreign my;   // (3A)
add_double :: (a: float64, b: float64) -> float64    #foreign my;   // (3B)
my :: #library "libmy";                                     // (4)

main :: () {
    print("%\n", add_int(3,8));            // (5A) => 11
    print("%\n", add_double(38.3,83.5));   // (5B )=> 121.8
}