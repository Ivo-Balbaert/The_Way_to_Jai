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