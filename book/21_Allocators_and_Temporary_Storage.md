# 21 – Allocators and Temporary Storage

Previously (see § 11) we saw how to use alloc / New and free for using heap memory:  
- New and free is used for structs (see § 12.5)
- NewArray or New and free for static arrays (see § 18.3)
- array_reserve and array_free or free for dynamic arrays (see § 18.4)
- sprint and free for dynamically build strings (see § 19.1)
- free_buffers for a String Builder (see § 19.5)
- to_c_string() and free for C strings (see § 19.7)

For these methods, the heap is just a giant storage facility.
The compiler does not check whether memory is freed, so this is your responsibility as a developer.
Doing a free for every object can be cumbersome and forgotten.
Luckily Jai also has in-built special storage mechanisms for data structures, called **Allocators**, that can help tremendously in this respect.

## 21.1 Allocators
In § 18.4 we discovered that the definition of a Resizable_Array contains a field `allocator : Allocator`.
 Allocators are specialized ways you can invoke to allocate memory for an object. They are specialized in the sense that they store data very efficiently, and they often have simpler mechanisms for freeing memory.  

An Allocator is basically a function pointer, for example it can be used as an argument like:	`Allocator = my_malloc,`  
where my_malloc is a function that allocates memory.

For example module _Basic_ defines a proc `alloc_string`, which can take a specific allocator to store the string:  
`alloc_string :: (count: int, allocator: Allocator = .{}) -> string`
(The default allocator is .{}, which is ??)
Also a dynamic array arrdyn could store its data in an allocator Alloc1:  `arrdyn.allocator = Alloc1;`  
A struct Node could be allocated like:  
`New(Node, allocator = Alloc1);`

You can also write your own allocators.

## 21.2 Temporary storage
Temporary storage is a special kind of Allocator. It is defined as a struct in the _Preload_ module, and module _Basic_ contains support routines to make working with temporary storage very easy.

It's a linear allocator, the fastest kind. There is a pointer to the start of free memory. If enough free memory is available to service your request, the pointer is advanced and returns the result. If there's not enough free memory, we ask the OS for more RAM. Because Temporary_Storage is expected to be for small-to-medium-sized allocations, we don't expect this to happen very often (and if we want, we can pre-allocate all the memory and lock it down so that the OS is never consulted.)  

When does the memory get freed? 	_Fire and forget!_
It happens when your program  calls `Basic.reset_temporary_storage()`. When does this happen? Whenever you want, but many programs have a natural time at which it is best to call this. For example, interactive programs like games or phone applications tend to run in a loop, drawing one frame for each iteration of the loop. You can call `reset_temporary_storage()` at the end of each frame. This makes a clear boundary that you know temporarily-allocated memory cannot cross: at the end of the loop, it's all gone. You can't free individual items in Temporary Storage.

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

`temp` is an abbreviation for Temporary Storage, so the examples in § 21.1 can be rewritten when the Allocator is Temporary Storage as follows:
`arrdyn.allocator = temp;`  
`New(Node, allocator = temp);`

## 21.3 Examples of using Temporary Storage
See _21.1_temp_storage.jai_:
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
    
    print("Temporary_Storage uses % bytes\n", context.temporary_storage.occupied); // (3)
    // => Temporary_Storage uses 88 bytes
    reset_temporary_storage(); // (4)
    print("Temporary_Storage uses % bytes\n", context.temporary_storage.occupied); // (5)
    // => Temporary_Storage uses 88 bytes
}
```

_Basic_ defines a function `temporary_alloc`, that is just like `alloc` but uses Temporary_Storage. 

## 21.3.1 Storing strings in temp with tprint
`talloc_string :: (count: int) -> string` is the equivalent of `alloc_string` that uses Temporary Storage.  
But even easier to use is the `tprint` proc, which is the equivalent of `sprint` (see § 19.4.5) that uses Temporary Storage.
It is defined as: 
`tprint :: (format_string: string, args: .. Any) -> string;`  
It is used in line (2).

>  Use tprint to create a string, but without having to think about freeing the memory. 

## 21.3.2 Storing arrays in temp
Line (1) shows how to use the temporary allocator for creating a dynamic array. If you need this frequently, you can write your own `make_array` proc.

## 21.3.3 How much memory is allocated in temp?
This is given by the field: `context.temporary_storage.occupied`.  
We see in line (5) that it goes back to 0 after the temp memory has been reset in (4).

