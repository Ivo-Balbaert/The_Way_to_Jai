# 4C - The Preload module
We already talked about the Basic module, which is necessary for printing and lots more. But there is also a _Preload_ module, which is even more fundamental and is implicitly loaded whenever the Jai compiler is started, so it doesn’t need to be imported.
It contains the minimal definitions the compiler needs in order to compile user source code.

It contains enums for the _Operating_System_, the _Type_Info_ definitions, the definitions for _Allocator, Logger, Stack trace, Context, Temporary Storage, Source Code location, Array_View and Resizable_Array_.   
It also contains very low-level functions or **intrinsics** which closely mimic corresponding C functions, like the following.

  memcpy :: (dest: *void, source: *void, count: s64) #intrinsic;
	memcmp :: (a: *void, b: *void, count: s64) -> s16  #intrinsic;
	memset :: (dest: *void, value: u8, count: s64)     #intrinsic;
   
**memcpy** copies count bytes from source to dest.   
**memcmp** compares the first count bytes of a and b, its return value is < 0 when a is less than b, > 0 when a is greater than b and 0 when a is equal to b.    
**memset** sets count bytes of dest to value.  

> Notice the #intrinsic directive with which these functions are marked.

For some example code, See *4.2_intrinsics.jai*:
```jai
#import "Basic";

main :: () {
    x: int = 42;
    y: type_of(x);

    memcpy(*y, *x, size_of(type_of(x)));    // (1)
    print("y is %\n", y);  // => y is 42; 
}
```
