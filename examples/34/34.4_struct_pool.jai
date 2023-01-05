#import "Basic";
#import "Pool";

Person :: struct {
    name            : string;
    age             : int;
}

pool: Pool;

main :: () {
    set_allocators(*pool);
    palloc: Allocator;
    palloc.proc = pool_allocator_proc;
    palloc.data = *pool;

    bob := New(Person, allocator = palloc);            // (1)
    bob.name = "Robert";           
    bob.age = 42;

    print("pool has % bytes left.\n", pool.bytes_left);
    // => pool has 65504 bytes left
    release(*pool);
    print("pool has % bytes left.\n", pool.bytes_left);
}