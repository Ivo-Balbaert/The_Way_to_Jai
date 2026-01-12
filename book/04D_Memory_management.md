# 4D - Memory management
In Jai, developers have complete control over where and when memory is allocated. Jai does an excellent job of _packing_ values in memory so they are close together, which increases runtime performance.   
Optimal memory use places data **contiguous in memory**, that means memory is assigned in consecutive blocks (having consecutive addresses) that are adjacent to each other.
  
The compiler knows how much memory each type uses. It also knows the type of each variable. A variable's memory is allocated at type declaration, for example: variable `counter` of type int will allocate 8 bytes. It will occupy one word on a 64 bit machine. 

Variables of a basic type are stored by default in _stack_ memory for performance reasons. This memory is freed automatically when the variable is no longer needed (when it goes out of scope), see § 7.  
However most of your program's memory will be allocated in the _heap_. Jai has no automatic memory management, so the developer is responsible for releasing (freeing) that memory.
We'll later (see § 11 and 21) detail the mechanisms Jai offers to do that.

For a good discussion about these two types of memory, see [Stack vs Heap](https://hackr.io/blog/stack-vs-heap).  