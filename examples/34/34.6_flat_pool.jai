#import "Basic";
#import "Flat_Pool";

pool: Flat_Pool;

Thing :: struct {
    name := "A Thing";
    value := 42.0;
}

main :: () {
    memory := cast(*u8) get(*pool, 100);  // (1)
    for 0..99 memory[it] = xx it;

    fpalloc: Allocator;
    fpalloc.proc = flat_pool_allocator_proc;    // (2)
    fpalloc.data = *pool;
    thing := New(Thing, allocator = fpalloc);   // (3)
    print("'thing' is: %\n", <<thing);
    // => 'thing' is: {"A Thing", 42}

    reset(*pool, overwrite_memory=true);        // (4)
    print("(2) 'thing' is: %\n", <<thing);      // (5)
    // =>  'thing' is: {"", -107374176}         

    fini(*pool);                                // (6)
}
    