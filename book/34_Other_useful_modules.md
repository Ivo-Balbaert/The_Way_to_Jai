# 34 Other useful modules.

## 34.1 Sorting
This is covered by the _Sort_ module, which contains implementations of bubble sort and quicksort.
(We already used bubble sort in program 30.11_using_notes.jai - § 30.12)
Here we present a simple example for using these procs.

See *34.1_sorting.jai*:
```c++
#import "Basic";
#import "Sort";
#import "String";

main :: () {
    arrf := float.[8, 108, 42, 5, 3.14, 17, -5, -272];
    arrs := string.["the", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog"];

    quick_sort(arrf, compare_floats);
    print("arrf quick-sorted is %\n", arrf); 
    // => [-272, -5, 3.14, 5, 8, 17, 42, 108]

    quick_sort(arrs, compare_strings);
    print("arrs quick-sorted is %\n", arrs); 
    // => arrs quick-sorted is ["brown", "dog", "fox", "jumped", "lazy", "over", "quick", "the", "the"]

    arrf1 := float.[8, 108, 42, 5, 3.14, 17, -5, -272];
    arrs1 := string.["the", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog"];

    bubble_sort(arrf1, compare_floats);
    print("arrf1 bubble-sorted is %\n", arrf1); 
    // => [-272, -5, 3.14, 5, 8, 17, 42, 108]

    bubble_sort(arrs1, compare);
    print("arrs1 bubble-sorted is %\n", arrs1); 
    // => ["brown", "dog", "fox", "jumped", "lazy", "over", "quick", "the", "the"]
}
```

Both sorting procedures need a 2nd argument. This is a procedure which specifies how to compare 2 values of the given type. The `compare` proc comes from the _String_ module
quick_sort is also used in how_to/460.
There is also the *Intro_Sort* module, which uses the insertion sort algorithm.

## 34.2 The Hash_Table module
This is a really useful data structure, which most languages implement, Jai included. A hash table (sometimes called hash map) is a data structure that implements an associative array abstract data type. It's a structure that can map keys to values.
Hash tables let us implement things like phone books or dictionaries; in them, we store the association between a value (like a dictionary definition of the word "lamp") and its key (the word "lamp" itself). We can use hash tables to store, retrieve, and delete data uniquely based on their unique key.
A hash table uses a _hash_ function to compute an index, also called a hash code,
 into an array of buckets or slots, where the associated value can be found.
(For more info, see: [https://en.wikipedia.org/wiki/Hash_table])  

See *34.2_hash_table.jai*:
```c++
#import "Basic";
#import "Hash_Table";

main :: () {
    table := New(Table(string, string));            // (1)

    table_add(table, "John Smith" , "521-8976" );   // (2)
    table_add(table, "Lisa Smith" , "521-1234" );
    table_add(table, "Sandra Dee" , "521-9655" );

    lookup := "Lisa Smith";
    telnr, success := table_find(table, lookup);
    if success print("The telnr of % is %\n", lookup, telnr);
    else print("The telnr of % was not found\n", lookup);
    // The telnr of Lisa Smith is 521-1234

    lookup = "Jane Doe";
    telnr, success = table_find(table, lookup);
    if success print("The telnr of % is %\n", lookup, telnr);
    else print("The telnr of % was not found\n", lookup);
    // The telnr of Jane Doe was not found

    for table {                                     // (3)
        key, value := it_index, it;
        print("key is % and value is %\n", key, value);
    }
    print("\n");
    /*
    key is Sandra Dee and value is 521-9655
    key is John Smith and value is 521-8976
    key is Lisa Smith and value is 521-1234
    */

    del := "Lisa Smith";
    table_remove(table, del);                   // (4)
    for table {                                     
        key, value := it_index, it;
        print("key is % and value is %\n", key, value);
    }
    /*
    key is Sandra Dee and value is 521-9655
    key is John Smith and value is 521-8976
    */
}
```

A new hash table is created on the heap as in line (1). Key-value pairs are added to with with the proc `table_add`, and a pair is deleted with the proc `table_remove`.
You can iterate over the table with a for-loop as in line (3).

## 34.3 The Pool module
This module provides a memory allocator to quickly allocate memory blocks of many different sizes (including bigger sizes, the default size is 64Kb) on the heap, but all when you know that all those blocks will have approximately the same lifetime. Allocate memory from the pool when you need it, and you free the entire pool at once when the program no longer needs the memory. A Pool gives you a very-fast-allocating memory arena, for long-term use with well-defined ownership.

### 34.3.1 Using a Pool 
Here is an example which shows how to use a Pool:
See *34.3_pool.jai*:
```c++
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
```

You can use a declared Pool directly as in line (1) with the `get` procedure, which allocates 64 bytes here in the current context, which it will continue to use.  
You can also work explicitly as in line (2) and following, assigning `pool_allocator_proc` and `*pool` to the context. Then `memory` only needs the number of bytes to be allocated.  
Lines (3) and following show how to use a Pool for code that is called in a new separate context. `set_allocators` inits the pool to use `context.allocator`. Then the Pool allocator is used in all code in the block declared after `push_context` in line (4).  

`pool.memblock_size` : is the size of the Pool's memory blocks (default 64 Kb)
`pool1.bytes_left`   : is the number of free space in the current block,

The `release(*pool);` frees all the memory allocated for pool and gives it back to the OS. 
You could also call `reset(*pool);` before the actual release (as in line (6)): this makes the Pool consider all its memory to be free for reuse. However, it won't release the memory back to the OS, so that future allocations are fast. If you set `pool.overwrite_memory`, the Pool will clear the memory to STAMP at this time. Calling `release` on its own first calls `reset`, before giving the memory to the OS.

Before allocation and after release you see the somewhat misleading message:  
`pool1 has 0 bytes left.
pool1 contains now 65536 bytes.`
The the reset/initial state is indeed bytes_left = 0, because no memory has been allocated. So when you allocate, it sees that you have 0 remaining bytes, so it will allocate a new memblock_sized block.

### 34.3.2 Allocating a struct on a Pool 
To use a Pool allocator when using New, use allocator as the 2nd argument to New and set it to a Pool instance, like in the following example (see line (1)):

See *34.4_struct_pool.jai*:
```c++
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
```

### 34.3.3 Using a pool with a macro 
Here is an example (taken from the Jai Wiki site) showing how to use 
See *34.5_macro_pool.jai*:
```c++
#import "Basic";
#import "Pool";

use_pool :: (code: Code) #expand {
    pool: Pool;
    set_allocators(*pool);
    push_allocator(pool_allocator_proc, *pool);
    #insert code;
    release(*pool);
}

main :: () {
    x: string; // (1) 
    use_pool( #code {
        // your code here
        x = "some allocated data";
    } );
    print(x); // => some allocated data
}
```

Line (1) defines a variable that needs to out-live the pool. 
The pool itself is used only within the macro `use_pool`.

### 34.3.4 Using a flat pool
A simpler alternative than module _Pool_ with perhaps better performance characteristics is offered by the *Flat_Pool* module.

Here is a simple example of its use, see *34.6_flat_pool.jai*:
```c++
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
    
```

In line (1), we allocate memory for 100 bytes with `get`. We make a new struct Thing in line (3) with the flat pool allocator defined in line (2). Line (5) prints out garbage, because the structs memory was overwritten in line (4). To release the memory, use `fini` as in line (6). But it's not needed to do this at the end of the program: the memory is released to the OS anyway.