# 21 – Memory Allocators and Temporary Storage

## 21.1 General remarks
The default allocator is `rpmalloc` and so doesn't depend on the libc `malloc` of the operating system.

### 21.1.1 Overview of allocation and freeing methods
Previously (see § 11) we saw how to use alloc / New and free for using heap memory:  
- alloc(n) is used to allocate n bytes of (by default) heap memory (like malloc in C), free to release it 
- if you know the data type you want to allocate memory for, use `New`, for example: New(int) (see § 11.2)
- New and free is also used for structs (see § 12.5) (same as new in C++)
- NewArray or New and array_free, free for static arrays (see § 18.3)
- array_reserve and array_free or free for dynamic arrays (see § 18.4)
- sprint and free for dynamically building strings (see § 19.1)
- free_buffers to release the memory of a String Builder (see § 19.5)
- to_c_string() and free for C strings (see § 19.7)

For these methods, the heap is just a giant storage facility.
The compiler does not check whether memory is freed, so this is your responsibility as a developer.
Doing a free for every object allocated on the heap can be cumbersome and forgotten.
Luckily Jai also has in-built special storage mechanisms for data structures, called **Allocators**, that can help tremendously in this respect. And there is also a built-in **memory-leak detector**!(see § 21.5).

### 21.1.2 Use defer when possible
Whenever you allocate on the heap (alloc, New, NewArray, [..]Type, and so on), use `defer free(object)` immediately after creating it. But this works only when you use that object right there in your current procedure and then don't need it anymore, because defer calls the free at the end of the current proc.

### 21.1.3 Different sorts of memory allocation
According to Jon Blow, there are roughly four categories of lifetimes:
1) Extremely short lived. Can be thrown away by end of function.  
2) Short lived + well defined lifetime. Memory allocated "per frame".  
3) Long lived + well defined owner. Uniquely owned by a subsystem.  
4) Long lived + unclear owner. Heavily shared, unknown when it may be accessed or freed.  

Most program allocations fall in category 1.   
Category 4 allocations should be rare in well written programs.   
Categories 2 and 3 are best served by arena allocators, like temporary storage (see § 21.3) or a Pool (see § 34.3).


## 21.2 Allocators
In § 18.4 we discovered that the definition of a Resizable_Array contains a field `allocator : Allocator`.
Allocators are specialized ways you can invoke to allocate memory for an object. They are specialized in the sense that they store data very efficiently, and they often have simpler mechanisms for freeing memory.  

An Allocator is defined in _Preload_ as a struct:
```jai
Allocator :: struct {
    proc: Allocator_Proc;
    data: *void;
}
```

A proc of type `Allocator_Proc` is basically a function pointer, for example it can be used as an argument like:                    
`proc = my_allocator_proc,`  
where `my_allocator_proc` is a function that allocates memory.

Here is the signature of `Allocator_Proc` from module _Preload_:
```jai
Allocator_Proc :: #type (mode: Allocator_Mode, size: s64, old_size: s64, old_memory: *void,  
allocator_data: *void) -> *void;
```

For example module _Basic_ defines a proc `alloc_string`, which can take a specific allocator to store the string:  
`alloc_string :: (count: int, allocator: Allocator = .{}) -> string`

The default allocator is .{}, which initializes an Allocator with its default values.

Also a dynamic array arrdyn could store its data in an allocator Alloc1:  
`arrdyn.allocator = Alloc1;`

A struct Node could be allocated like:  
`New(Node, allocator = Alloc1);`

You can also write your own allocators.

(For an in-depth discussion see *how_to/800_allocators.jai*.)

**Global data**  
This data is needed until the end of the program. It's no use freeing it, because after the program exits, the memory is automatically reclaimed by the OS. You can make the memory debugger (see § 21.4) not count global data as a leak by using the following proc:  
` this_allocation_is_not_a_leak(some_global_data);`  

## 21.3 Temporary storage
Temporary storage is a special kind of Allocator, more specifically a simple linear allocator / bump allocator.  
An allocation is a simple increment into a block of memory. Objects can not be freed individually.  

It is defined as a struct in the _Preload_ module, and module _Basic_ contains support routines to make working with temporary storage very easy. Its memory resides in the Context (see § 25).

Here is the struct's definition:
```jai
Temporary_Storage :: struct {  
    data:     *u8;
    size:     s64;
    current_page_bytes_occupied: s64;
    total_bytes_occupied: s64;
    high_water_mark: s64;
    last_set_mark_location: Source_Code_Location;
    
    overflow_allocator := Allocator.{__default_allocator_proc, null};
    overflow_pages: *Overflow_Page;
    original_data: *u8;  
    original_size: s64;
    
    Overflow_Page :: struct {
        next: *Overflow_Page;
        allocator: Allocator;
        size: s64;
    }
}
```

It's a linear allocator, the fastest kind, it is much faster than malloc. It helps your program run faster while also providing many of the benefits of garbage collected languages. Normally Temporary_Storage will allocate heap memory, but see § 21.4.4   
There is a pointer `data` to the start of free memory. If enough free memory is available to service your request, this pointer is advanced and returns the result. If there's not enough free memory, we ask the OS for more RAM.  
Because Temporary_Storage is expected to be for small-to-medium-sized allocations, we don't expect this to happen very often (and if we want, we can pre-allocate all the memory and lock it down so that the OS is never consulted.)  

When does the memory get freed?  
_Fire and forget!_
It happens when your program  calls `Basic.reset_temporary_storage()`.   When does this happen?  
Whenever you want, but many programs have a natural time at which it is best to call this. For example, interactive programs like games or phone applications tend to run in a loop, drawing one frame for each iteration of the loop. You can call `reset_temporary_storage()` at the end (or beginning) of each frame. This makes a clear boundary that you know temporarily-allocated memory cannot cross: at the end of the loop, it's all gone. You can't free individual items in Temporary Storage. Also, don't keep pointers to things in Temporary Storage.

> What happens when Temporary Storage is completely occupied?
> In a debug build, if the `high_water_mark` exceeds the temporary storage memory capacity, temporary storage will default back to the normal heap allocator to allocate more memory. In a release build, your program might crash, or have memory corruption problems. Use the memory-leak detector discussed in § 21.4 to investigate such cases.

> When is Temporary_Storage appropriate? When your memory allocations have a (relatively) short life-time.  
> When is Temporary_Storage NOT appropriate? If your data need to live beyond the current frame, or be seen by a separate thread that doesn't re-join before you reset the memory.

A typical game loop goes like this:

```jai
while true {
            input();
            simulate();
            render();

            reset_temporary_storage(); // (1)
}
```
In line (1), the memory is freed and a new cycle can begin.

`temp` is an abbreviation for `__temporary_allocator` (the long variable name for Temporary Storage).  
The procedure `push_allocator(temp)` is used to set temporary storage as the current allocator (see § 25.3).

## 21.4 Examples of using Temporary Storage
See *21.1_temp_storage.jai*:
```jai
#import "Basic";

make_array :: (x: int) -> [..] int {
    result: [..] int;
    result.allocator = temp;  // (1) 
    for 1..x array_add(*result, it);
    return result;
}

main :: () {
    b := "Resounding ";
    ch := "世界";
    temp_str := tprint("% %!\n", b, ch); // (2)
    print("%\n", temp_str); // => Resounding 世界!

    arrdyn := make_array(5);
    print("%\n", arrdyn); // => [1, 2, 3, 4, 5]
        
    s := talloc_string(256); // (6)

    builder: String_Builder;
    builder.allocator = temp;   // (6B)
    
    print("Temporary_Storage uses % bytes\n", context.temporary_storage.total_bytes_occupied); // (3)
    // => Temporary_Storage uses 344 bytes
    reset_temporary_storage(); // (4)
    print("Temporary_Storage uses % bytes\n", context.temporary_storage.total_bytes_occupied); // (5)
    // => Temporary_Storage uses 0 bytes
}
```

_Basic_ defines a function `temporary_alloc`, that is just like `alloc` but uses Temporary_Storage. 

## 21.4.1 Storing strings in temp with tprint
`talloc_string :: (count: int) -> string` is the equivalent of `alloc_string` that uses Temporary Storage, see it used in line (6).  
But even easier to use is the `tprint` proc, which is the equivalent of `sprint` (see § 19.4.5) that uses Temporary Storage.
It is defined as: 
`tprint :: (format_string: string, args: .. Any) -> string;`  
It is used in line (2).

>  Use tprint to create a string, but without having to think about freeing the memory. 

## 21.4.2 Storing arrays and string builders in temp
Line (1) shows how to use the temporary allocator for creating a dynamic array. When this array resizes, it will use Temporary_Storage to get its memory. If you need this frequently, you can write your own `make_array` proc.
Line (6B) shows how to store a string builder in temporary storage; this makes calling `free_buffers` unnecessary.

## 21.4.3 Using New with temp
As we saw in § 21.2, New can take any defined Allocator, so also `temp`. This can be done with the following code:

```jai
Node :: struct {
  value: int;
  name: string;
}

node  := New(Node, allocator = temp);

// static arrays:
array := NewArray(10, int, temp);

// dynamic arrays:
arrdyn: [..] int;
arrdyn.allocator = temp;
```

## 21.4.4 Using Temporary Storage on the Stack
This can be done by using the `auto_release_temp` macro (defined in module _Basic_) to set the mark. Then you can allocate whatever you want temporarily, then release all the memory at once when the stack unwinds by setting the mark back to the original location with `auto_release_temp()`.

## 21.4.5 How much memory is allocated in temp?
This is given by the field: `context.temporary_storage.total_bytes_occupied`.  
We see in line (5) that it goes back to 0 after the temp memory has been reset in (4).

## 21.5 Memory-leak detector
To cope with a possible problem of memory-leakage, Jai has a built-in memory-leak detector. It can be activated by importing _Basic_ like this:
`#import "Basic"()(MEMORY_DEBUGGER=true);`  
This hooks alloc(), free(), and realloc() with routines that record allocations and frees. Enabling the MEMORY_DEBUGGER will slow down your program, so use it only when solving memory-issues.

See *21.2_leak_detect.jai*:
```jai
#import "Basic"()(MEMORY_DEBUGGER=true);

main :: () {
    x := alloc(100);                // (1)
    // ....
    free(x);                        // (2)

    report := make_leak_report();   // (3)
    for report.sorted_summaries print("** Summary %: **\n%\n", it_index, <<it); // (3B)

    log_leak_report(report);        // (4)
}

/* When memory is not freed:
** Summary 0: **
{count = 1; bytes = 100; allocations_since_last_visualizer_update = 1; bytes_allocated_since_last_visualizer_update = 100;  
alloc_site_trace = 1ca_ada2_85e8; allocator_proc = procedure 0x7ff6_5518_14f0; group_info = null; }

----- 100 bytes in 1 allocation -----
alloc  c:/jai/modules/Basic/module.jai:87
main   d:/Jai/The_Way_to_Jai/examples/21/21.2_leak_detect.jai:4

Total: 100 bytes in 1 allocation.

Marked as non-leaks: 0 bytes in 0 allocations.
*/

/* When freed:
Total: 0 bytes in 0 allocations.

Marked as non-leaks: 0 bytes in 0 allocations.
*/
```

In line (1) we allocate 100 bytes which is never freed. Starting the leak detector in line (3), and showing its log report through line (4) shows that these 100 bytes, allocated in line (1) were never freed. Line (3B) also gives raw data about the non-freed allocations, to be used/filtered in a report or graphic.
If we do free them, we get the 2nd output.  
You can ask for a memory leak report at any time in the program.
If the output is too verbose, there are ways to alleviate that (see modules/Basic/examples/memory_debugger.jai)

The Visual Memory Debugger tool in module _Basic_ can communicate the collected information about memory allocations to an external visualization client like `examples/codex_view`.

**Exercise**  
Try this out on program 18.5_array_for.jai, without and with free (see leak_array_for.jai).

`push_allocator` can be used with temp, see § 25.2.

## 21.6 Check which allocator owns an allocation
The following program does just that, which could be useful while debugging.
(// v 0.1.072: assert in line 52 doesn't work anymore for rpmalloc ?? )

See *21.3_allocators_check.jai*:
```jai
// An example that uses several different allocators, then asks them all
// who owns which memory.
//
// Note that this is probably not the kind of thing you want to do at runtime
// in the steady state, as it may not be very fast, but it could be a very helpful
// debugging facility.
//

#import "Basic";
#import "Pool";
#import "Flat_Pool";
#import "rpmalloc";

main :: () {
    pool: Pool;
    flat: Flat_Pool;

    a := context.default_allocator;
    b := Allocator.{pool_allocator_proc, *pool};
    c := Allocator.{flat_pool_allocator_proc, *flat};
    d := Allocator.{rpmalloc_allocator_proc, null};

    // rpmalloc needs explicit init right now, but others don't.
    d.proc(.STARTUP, 0, 0, null, null);  
    
    ma := alloc(1000, allocator=a);
    mb := alloc(1000, allocator=b);
    mc := alloc(1000, allocator=c);
    md := alloc(1000, allocator=d);

    report_who_owns(ma, a, b, c, d);
    report_who_owns(mb, a, b, c, d);
    report_who_owns(mc, a, b, c, d);
    report_who_owns(md, a, b, c, d);
}

report_who_owns :: (memory: *void, allocators: .. Allocator) {
    someone_owns_this := false;
    
    print("Querying all allocators for address: %\n", memory);
    
    for allocators {
        caps, name := get_capabilities(it);
        assert((caps & .IS_THIS_YOURS) != 0);  
        
        yours := cast(bool) it.proc(.IS_THIS_YOURS, 0, 0, memory, it.data);
        print("[%] says \"%\"\n", yours, name);

        someone_owns_this ||= yours;
    }

    assert(someone_owns_this);
}

/*
Querying all allocators for address: 217_186a_0080
[true] says "stripped-down rpmalloc 1.4.4 intended as Default_Allocator"
[false] says "modules/Pool"
[false] says "modules/Flat_Pool"
[false] says "rpmalloc 1.4.4"
Querying all allocators for address: 217_186b_0088
[true] says "stripped-down rpmalloc 1.4.4 intended as Default_Allocator"
[true] says "modules/Pool"
[false] says "modules/Flat_Pool"
[false] says "rpmalloc 1.4.4"
Querying all allocators for address: 217_18aa_0000
[false] says "stripped-down rpmalloc 1.4.4 intended as Default_Allocator"
[false] says "modules/Pool"
[true] says "modules/Flat_Pool"
[false] says "rpmalloc 1.4.4"
Querying all allocators for address: 217_28aa_0080
[false] says "stripped-down rpmalloc 1.4.4 intended as Default_Allocator"
[false] says "modules/Pool"
[false] says "modules/Flat_Pool"
[true] says "rpmalloc 1.4.4"
*/
```

The program works with four different allocators a-d. It allocates 1000 bytes with each of them (ma-md). For each allocation, it then queries all allocators to check which allocator owns that allocation.

Here is how you could write a simple [scratch allocator](https://github.com/onelivesleft/jai-string/tree/main/Scratch) by Iain King, which only ever allocates two pieces of memory: the buffer we are reading from and the buffer we are writing to. This could be useful when you want to perform a series of string operations, one after another; for example: replacing HTML character markers with the actual characters.