# Chapter 11 – Allocating and freeing memory

We talked about memory and Jai before in § 1.1.1, § 1.4 and § 4.10.
Now that we know the concept of pointers, we can discuss the basic mechanisms in Jai for creating (also called _allocating_) and _freeing_ memory.
Because there is no garbage collection in Jai, the developer is also responsible for the freeing of memory. Freeing memory should be done as soon as a variable is no longer needed, it is easy to forget.
If memory allocated on the heap is not freed when it is no longer needed, so-called _memory leaks_ can occur. This means your program continues to use up more and more memory, degrading performance of its execution and of the entire machine on which it runs.
Because Jai is a manually memory managed language, it is important to be aware of this from the start.  
Managing memory is not that cumbersome as in C++ however. Later on (see ??) we'll see how Jai makes it much simpler to handle memory. 

## 11.1 The defer keyword
The memory occupied by variables must be freed when it is no longer needed. But it can be difficult to manually keep track when this is the case; there can be a lot of code between the variable's creation (the allocation of its memory) and when the variable's lifetime is over (when its memory can be freed).  
Jai's solution to this is the **defer** keyword (first introduced by Go), which lets us logically free memory right after its allocation, with the compiler ensuring that this really happens at the right time. Thus the developer doesn't need to worry about this anymore, just create and 'free' immediately in code!  

Let's first see how defer works: See *11.1_defer.jai*
```c++
#import "Basic";

main :: () {
    print("step %\n", 1);
    print("step %\n", 2);
    defer print("This prints at the very end instead of between 2 and 3!\n"); // (1)
    print("step %\n", 3);
    print("step %\n", 4);
}

/*
step 1
step 2
step 3
step 4
This prints at the very end instead of between 2 and 3!
*/
```

We see that the defer statement in line (1) only executes right before the closing } of main. This is exactly the behavior we want. If you like, you can enclose the statement after defer within (), but this is optional. defer can also take a code block as argument, enclosed by { }.    
The execution of every statement or code block after the defer keyword is delayed until the end of the current (present) scope. This means that these deferred statements will be called when code execution has reached the ending }, that is: when we leave the current scope.

Now let's look at a second example, where multiple defer statements are used, see  *11.2_defer.jai*:
```c++
#import "Basic";

main :: () {
  print("1, ");
  defer print("5, ");
  print("2, ");
  defer print("4, ");
  print("3, ");
}

// => 1, 2, 3, 4, 5,
```
Notice that multiple defer statements execute in reverse LIFO order (Last In First Out) from the order in which they were declared. Also note that variables can change before the defer is actually executed (See *11.3_defer_levels.jai*).

Defer statements in loops (see § 15) are executed at the end of the loop, not the end of the function, which is different from the behavior in Go.

***Exercises***
Try your hand at the following exercises.

1) Print the strings "One!", "Two!" and "Three!" in this order:
"One!", "Three!" and "Two!" (see exercises/11/defer1.jai)

2) What is the output of the following program and then run to check (see defer2.jai):
```c++   
#import "Basic";

main :: () {
    defer print("One!\n");
    defer print("Two!\n");
    defer print("Three!\n");
}
```
Here is another example to demonstrate some subtleties where defer is used with a code block and nested levels, See *11.3_defer_levels.jai*:

```c++   
#import "Basic";

main :: () {
    x := 123;                   // (1)
    defer print("x is %\n", x); // (2)
    {
        defer x = 4; // this is the same x as defined in line (1)
        x = 2;
    } // x is now 4!
    print("x is %\n", x);      // => 4
    x = 234;
    // now the 1st defer statement from line (2) is executed
}
/*
x is 4
x is 234
*/
```

> A neat trick that uses defer is to start main() with:
> ´ defer print("Program ended gracefully");´
> If this message is printed out, your program ends without crashing

defer is mainly used to free memory or other resources (closing a file (see § 27.1), or a mutex (see § 31.3) or a database connection), as we'll see in the next sections.

## 11.2 Allocating and freeing primitive variables
Let's take a look at *11.4_memory.jai*:

```c++
#import "Basic";

main :: () {
    n0 := 3;                    // (1) - on stack

    n1 := cast(*int) alloc(size_of(int));  // (2) - on heap
    defer free(n1);             // (3)
    print("The address n1 points at is %\n", n1); // => The address n1 points at is 2ad_131f_5700
    print("The value n1 points at is %\n", << n1); // => The value n1 points at is 0
    print("The type of n1 is %\n", type_of(n1)); // => The type of n1 is *s64
    << n1 = 7;   // (4) fill in a value for n1 to point to
    print("%\n", << n1); // => 7

    length := 108;
    buffer := cast(*u8) alloc(length); // (4B)

    // alternative way:
    n2 := New(int);   // (5)
    defer free(n2);   // (6)
    print("%\n", type_of(n2)); // => *s64
    << n2 = 8;
    print("%\n", << n2); // => 8
    n2 = null;  // (7) to really wipe out the previous value in that memory location
}

/*
The address n1 points at is 264_7bd6_5840
The value n1 points at is 0   
The type of n1 is *s64        
7
*s64
8
 */
```
> Remark: This example is somewhat contrived: normally you wouldn't allocate an int on the heap.

The int variable n0 defined in line (1) is allocated on the stack; it will automatically be freed at the end of the procedure (here main) it is defined in.
The n1 variable is created on the heap in line (2) with the `alloc` proc, like this:

```c++
n1 := cast(*int) alloc(size_of(int));  // (2) - on heap
defer free(n1);                        // (3)
```
it returns a pointer to a series of contiguous bytes allocated on the heap, which is uninitialized memory (`*void`). The cast is needed because `alloc` itself returns `*void`.

`alloc` allocates memory by default on the _heap_, what is also called _dynamic allocation_. The 1st argument of `alloc` is the size in bytes of the amount of memory to allocate; here we allocate 8 bytes (which is the size of an int). `alloc` returns a (void) pointer to the first byte of the memory allocated, which forms a series of contiguous bytes (we'll discuss the 2nd Allocator argument later, see § 21), so it is a pointer to uninitialized memory. Because we know n1 will point to an int, we can already cast to it with `cast(*int)`, so the compiler knows it too. Because the allocation is on the heap, we must free this memory ourself. This is done in line (3) with `free(n1`.  
Notice that we call it with the defer proc from the previous §. The result is that n1's 8 bytes memory will be freed at the closing } of the proc it is defined in, which marks the end of scope or lifetime for n1.  
In line (4) the allocated memory is filled with a value 7 assigned to `<< n1`.

The `alloc` and `free` procs are both defined in module _Basic_ (file module.jai).  
  
`alloc :: (size: s64, allocator: Allocator = .{}) -> *void { ...`  
`free :: (memory: *void, allocator: Allocator = .{}) { ...`

The 1st argument of `free` is a void pointer to the memory to be freed (de-allocated). In our example n1 is the pointer which must be given as argument to free.   
Also a  `realloc` proc exists to resize already allocated memory:  
`realloc :: (memory: *void, size: s64, old_size: s64, allocator: Allocator = .{}) -> *void`

Line (4B) shows a common way to allocate a buffer for `length` number of bytes.

Using `alloc` this way is a bit cumbersome. In line (5) the exact same thing is accomplished with **New**:  `n2 := New(int);`
New always allocates memory on the heap, returning a pointer. It must be followed with a `free` of that memory (line (6)). New just calls alloc and then the initializer, which sets the memory to its default zero-value.  
New is not a keyword built into the language, but rather a regular procedure that does heap allocation. It is also defined in the _Basic_ module. 
You could be extremely careful and write a zero-value (here null) in that memory as in line (7), just to be sure that subsequent use of that memory will be more safe. But this is by no means necessary.