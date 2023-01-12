#import "Basic";

SomeTrait :: struct(                                   // (1)
    type: Type,
    get: (a: type, int) -> int,
    set: (a: *type, int, int) -> ()
){}

get :: inline (a: $A/SomeTrait, i: int) -> int {       // (2)
    return a.get(a, i);
}

set :: inline (a: *$A/SomeTrait, i: int, val: int) {    // (3)
    a.set(a, i, val);
}

ExSomeTrait :: struct {                                         // (4)
    using #as _t: SomeTrait(#this, ex_get, ex_set);
    data: [4]int;
}

ex_get :: (f: ExSomeTrait, i: int) -> int {
    return f.data[i];
}

ex_set :: (f: *ExSomeTrait, i: int, val: int) {
    f.data[i] = val;
}

do_sth :: (x: *$X/SomeTrait) {
    set(x, 0, 12345);
}

main :: () {
    f : ExSomeTrait;
    f.set(*f, 1, 42);
    print("%\n", f);
    print("%\n", f.get(f, 1));
    print("%\n", get(f, 3));

    set(*f, 3, 2021);
    print("%\n", f);
    do_sth(*f);                     // (5)
    print("%\n", f);
}
/*
{[0, 42, 0, 0]}
42
0
{[0, 42, 0, 2021]}
{[12345, 42, 0, 2021]}
*/