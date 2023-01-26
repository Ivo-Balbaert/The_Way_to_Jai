# Chapter 18C - Copying a struct with memcpy
(Example taken from how_to\006_structs)

In § 4.9, we saw the low-level memcpy function. We'll use this now to copy the contents of a struct to another struct, using a static array as intermediary. 

See *18C_memcpy_struct.jai*:
```c++
#import "Basic";

Rectangle :: struct {  
    x0: float;   // X coordinate of lower-left corner.
    y0: float;   // Y coordinate of lower-left corner.
    x1: float;   // X coordinate of upper-right corner.
    y1: float;   // Y coordinate of upper-right corner.
    color_name: string;   
}

main :: () {
    r := Rectangle.{10, 5, 50, 55, "chartreuse"};   
    t: Rectangle;
    print("Before copy, t is: %\n", t);

    S :: size_of(Rectangle);
    temporary: [S] u8;     // (1)
    memcpy(temporary.data, *r, S); // (2) 
    print("Contents of 'temporary', in bytes: ");
    for temporary print("% ", formatInt(it, base=16, minimum_digits=2)); // (3) 
    print("\n");
    memcpy(*t, temporary.data, S);   // (4) 
    print("After copy, t is: %\n", t);
}

/*
Before copy, t is: {0, 0, 0, 0, ""}
Contents of 'temporary', in bytes: 00 00 20 41 00 00 a0 40 00 00 48 42 00 00 5c 42 0a 00 00 00 00 00 00 00 b8 51 4d b7 f7 7f 00 00
After copy, t is: {10, 5, 50, 55, "chartreuse"}
*/
```

In line (1), we define a static array `temporary` of bytes, with count equal to the size of the struct.  
In line (2), we copy r's data into `temporary` using `memcpy`. Line (3) prints out the bytes in a for-loop. Line (4) then copies the data from `temporary` to a new Rectangle t.
