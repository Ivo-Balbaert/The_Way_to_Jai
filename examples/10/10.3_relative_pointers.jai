#import "Basic";

main :: () {
    ptra:  *~s32 int; // (1) - 32-bit relative pointer to an int
    ptrb:  *~s16 int; // (2) - 16-bit relative pointer to an int
    ptrc:  *~s8  int; // (3) - 8-bit relative pointer to an int
    print("ptrc is %\n", ptrc); // => ptrc is r null  - r for relative

    print("size: %\n", size_of(*~s8 int));  // => size: 1
	print("size: %\n", size_of(*~s16 int)); // => size: 2
	print("size: %\n", size_of(*~s32 int)); // => size: 4
	print("size: %\n", size_of(*~s64 int)); // => size: 8

    a := New(int);
    << a = 5;
    ptrb = a;       // (4)
    print("ptrb is %\n", ptrb); // => ptrb is r1998 (d1_f31c_0080)
    // print("ptrb points to %\n", << ptrb); 
    // => The program crashed because of an access violation reading location 0x352ff00080
}