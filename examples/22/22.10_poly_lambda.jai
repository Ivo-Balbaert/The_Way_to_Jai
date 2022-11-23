#import "Basic";

main :: () {
    call_with :: (arg: $T, f: (T)) {        // (1)
        f(arg);
    }
    call_with(5, x => { print("x is %\n", x); if x > 0 then #this(x-1); });
}
/* 
x is 5
x is 4
x is 3
x is 2
x is 1
x is 0
*/