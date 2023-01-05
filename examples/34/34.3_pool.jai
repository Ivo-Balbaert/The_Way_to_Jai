#import "Basic";
#import "Pool";

main :: () {
    pool: Pool;
    memory := get(*pool, 64);        // (1)

    context.allocator.proc = pool_allocator_proc;   // (2)
    context.allocator.data = *pool;
    memory = alloc(64);
    // use the pool in the current context ...

    pool1: Pool;
    new_context := context;          // (3)
    new_context.allocator.proc = pool_allocator_proc;
    new_context.allocator.data = *pool1;
    set_allocators(*pool1);
    push_context new_context {       // (4)
        // Everything in here uses the pool1 Pool allocator!
        // ...
        print("pool1 memblock size % bytes.\n", pool1.memblock_size);
        print("Before allocation:\n");
        print("pool1 has % bytes left.\n", pool1.bytes_left);
        print("pool1 contains now % bytes.\n", pool.memblock_size - pool1.bytes_left);
        print("\n");
        // ...
        memory = alloc(256);
        print("After allocation:\n");
        print("pool1 has % bytes left.\n", pool1.bytes_left);
        print("pool1 contains now % bytes.\n", pool.memblock_size - pool1.bytes_left);
        print("\n");
    }
    release(*pool1);               // (5)
    print("After release:\n");
    print("pool1 has % bytes left.\n", pool1.bytes_left);
    print("pool1 contains now % bytes.\n", pool.memblock_size - pool1.bytes_left);
    print("\n");

    print("pool memblock size % bytes.\n", pool.memblock_size);
    print("pool has % bytes left.\n", pool.bytes_left);
    print("pool contains now % bytes.\n", pool.memblock_size - pool.bytes_left);
//    reset(*pool);                   // (6)
    release(*pool); 
}

/*
pool1 memblock size 65536 bytes.
Before allocation:
pool1 has 0 bytes left.
pool1 contains now 65536 bytes.

After allocation:
pool1 has 65272 bytes left.
pool1 contains now 264 bytes.

After release:
pool1 has 0 bytes left.
pool1 contains now 65536 bytes.

pool memblock size 65536 bytes.
pool has 65400 bytes left.
pool contains now 136 bytes.
*/