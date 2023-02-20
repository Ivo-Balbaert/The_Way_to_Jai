#import "Basic";

main :: () {
    my_proc :: (v: int) -> int { return v + 5; }
    my_proc_type :: #type (int) -> int;        // (1)
    assert(type_of(my_proc) == my_proc_type);  // (1B)

    an_int : int = 42;
    a_proc_ptr : my_proc_type = my_proc;       // (2)
    another_int := a_proc_ptr(an_int);         // (3)
    print("%", another_int); // => 47
}