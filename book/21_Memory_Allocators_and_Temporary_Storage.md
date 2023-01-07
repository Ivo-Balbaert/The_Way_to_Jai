# 21 – Memory Allocators and Temporary Storage

Previously (see § 11) we saw how to use alloc / New and free for using heap memory:  
- alloc(n) is used to allocate n bytes of by default heap memory (like malloc in C) 
- New and free is used for structs (see § 12.5) (same as new in C++)
- NewArray or New and free for static arrays (see § 18.3)
- array_reserve and array_free or free for dynamic arrays (see § 18.4)
- sprint and free for dynamically build strings (see § 19.1)
- free_buffers for a String Builder (see § 19.5)
- to_c_string() and free for C strings (see § 19.7)

**User defer when possible**
Whenever you allocate on the heap (alloc, New, NewArray, [..]Type, and so on), use `defer free(object)` immediately after creating it. But this works only when you use that object right now in your current procedure and then don't need it anymore, because defer calls the free at the end of the current proc.

For these methods, the heap is just a giant storage facility.
The compiler does not check whether memory is freed, so this is your responsibility as a developer.
Doing a free for every object allocated on the heap can be cumbersome and forgotten.
Luckily Jai also has in-built special storage mechanisms for data structures, called **Allocators**, that can help tremendously in this respect. And there is also a built-in **memory-leak detector!** (see § 21.4).

## 21.1 Allocators
In § 18.4 we discovered that the definition of a Resizable_Array contains a field `allocator : Allocator`.
Allocators are specialized ways you can invoke to allocate memory for an object. They are specialized in the sense that they store data very efficiently, and they often have simpler mechanisms for freeing memory.  

An Allocator is defined in _Preload_ as a struct:
```c++
Allocator :: struct {
    proc: Allocator_Proc;
    data: *void;
}
```

A proc of type `Allocator_Proc` is basically a function pointer, for example it can be used as an argument like:                    
`proc = my_allocator_proc,`  
where `my_allocator_proc` is a function that allocates memory.

Here is the signature of `Allocator_Proc` from module _Preload_:
```c++
Allocator_Proc :: #type (mode: Allocator_Mode, size: s64, old_size: s64, old_memory: *void, allocator_data: *void) -> *void;
```

For example module _Basic_ defines a proc `alloc_string`, which can take a specific allocator to store the string:  
`alloc_string :: (count: int, allocator: Allocator = .{}) -> string`

(The default allocator is .{}, which is ??)
Also a dynamic array arrdyn could store its data in an allocator Alloc1:  
`arrdyn.allocator = Alloc1;`

A struct Node could be allocated like:  
`New(Node, allocator = Alloc1);`

You can also write your own allocators.

**Global data**  
This data is needed until the end of the program. It's no use freeing it, because after the program exits, the memory is automatically reclaimed by the OS. You can make the memory debugger (see § 21.4) not count global data as a leak by using the following proc:  
` this_allocation_is_not_a_leak(some_global_data);`  

## 21.2 Temporary storage
Temporary storage is a special kind of Allocator. It is defined as a struct in the _Preload_ module, and module _Basic_ contains support routines to make working with temporary storage very easy. Its memory resides in the Context (see § 25).

Here is the struct's definition:
```c++
Temporary_Storage :: struct {  
    data:     *u8;
    size:     s64;
    occupied: s64;
    high_water_mark: s64;
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

It's a linear allocator, the fastest kind, it is much faster than malloc. It helps your program run faster while also providing many of the benefits of garbage collected languages. Normally Temporary_Storage will allocate heap memory, but see § 21.3.4 
There is a pointer `data` to the start of free memory. If enough free memory is available to service your request, this pointer is advanced and returns the result. If there's not enough free memory, we ask the OS for more RAM. Because Temporary_Storage is expected to be for small-to-medium-sized allocations, we don't expect this to happen very often (and if we want, we can pre-allocate all the memory and lock it down so that the OS is never consulted.)  

When does the memory get freed? 	_Fire and forget!_
It happens when your program  calls `Basic.reset_temporary_storage()`. When does this happen? Whenever you want, but many programs have a natural time at which it is best to call this. For example, interactive programs like games or phone applications tend to run in a loop, drawing one frame for each iteration of the loop. You can call `reset_temporary_storage()` at the end (or beginning) of each frame. This makes a clear boundary that you know temporarily-allocated memory cannot cross: at the end of the loop, it's all gone. You can't free individual items in Temporary Storage. Also, don't keep pointers to things in Temporary Storage.

> What happens when Temporary Storage is completely occupied?
> In a debug build, if the `high_water_mark` exceeds the temporary storage memory capacity, temporary storage will default back to the normal heap allocator to allocate more memory. In a release build, your program might crash, or have memory corruption problems. Use the memory-leak detector discussed in § 21.4 to investigate such cases.

> When is Temporary_Storage appropriate? when your memory allocations have a (relatively) short life-time.  
> When is Temporary_Storage NOT appropriate? If your data need to live beyond the current frame, or be seen by a separate thread that doesn't re-join before you reset the memory.

A typical game loop goes like this:

```c++
while true {
            input();
            simulate();
            render();

            reset_temporary_storage(); // (1)
}
```
In line (1), the memory is freed and a new cycle can begin.

`temp` is an abbreviation for `__temporary_allocator` (the long variable name for Temporary Storage), so the examples in § 21.1 can be rewritten when the Allocator is Temporary Storage as follows:

## 21.3 Examples of using Temporary Storage
See *21.1_temp_storage.jai*:
```c++
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
    
    print("Temporary_Storage uses % bytes\n", context.temporary_storage.occupied); // (3)
    // => Temporary_Storage uses 344 bytes
    reset_temporary_storage(); // (4)
    print("Temporary_Storage uses % bytes\n", context.temporary_storage.occupied); // (5)
    // => Temporary_Storage uses 0 bytes
}
```

_Basic_ defines a function `temporary_alloc`, that is just like `alloc` but uses Temporary_Storage. 

## 21.3.1 Storing strings in temp with tprint
`talloc_string :: (count: int) -> string` is the equivalent of `alloc_string` that uses Temporary Storage, see it used in line (6).  
But even easier to use is the `tprint` proc, which is the equivalent of `sprint` (see § 19.4.5) that uses Temporary Storage.
It is defined as: 
`tprint :: (format_string: string, args: .. Any) -> string;`  
It is used in line (2).

>  Use tprint to create a string, but without having to think about freeing the memory. 

## 21.3.2 Storing arrays and string builders in temp
Line (1) shows how to use the temporary allocator for creating a dynamic array. When this array resizes, it will use Temporary_Storage to get its memory. If you need this frequently, you can write your own `make_array` proc.
Line (6B) shows how to store a string builder in temporary storage; this makes calling `free_buffers` unnecessary.

## 21.3.3 Using New with temp
As we saw in § 21.1, New can take any defined Allocator, so also `temp`! This can be done with the following code:

```c++
Node :: struct {
  value: int;
  name: string;
}

node  := New(Node, allocator = temp);
array := NewArray(10, int, temp);

arrdyn: [..] int;
arrdyn.allocator = temp;
```

## 21.3.4 Using Temporary Storage on the Stack
This can be done by using the `auto_release_temp` macro to set the mark. Then you can allocate whatever you want temporarily, then release all the memory at once when the stack unwinds by setting the mark back to the original location with `auto_release_temp()`.
(example ??)

## 21.3.5 How much memory is allocated in temp?
This is given by the field: `context.temporary_storage.occupied`.  
We see in line (5) that it goes back to 0 after the temp memory has been reset in (4).

## 21.4 Memory-leak detector
To cope with a possible problem of memory-leakage, Jai has a built-in memory-leak detector. It can be activated by importing _Basic_ like this:
`#import "Basic"()(MEMORY_DEBUGGER=true);`  
This hooks alloc(), free(), and realloc() with routines that record allocations and frees. Enabling the MEMORY_DEBUGGER will slow down your program, so use it only when solving memory-issues.

See *21.2_leak_detect.jai*:
```c++
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
{count = 1; bytes = 100; allocations_since_last_visualizer_update = 1; bytes_allocated_since_last_visualizer_update = 100; alloc_site_trace = 1ca_ada2_85e8; allocator_proc = procedure 0x7ff6_5518_14f0; group_info = null; }

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

**Exercise**
Try this out on program 18.5_array_for.jai, without and with free (see leak_array_for.jai).

`push_allocator` can be used with temp, see § 25.2.