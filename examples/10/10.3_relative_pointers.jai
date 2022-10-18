#import "Basic";

main :: () {
    Obj :: struct { var := 0; }

    ptr0: *Obj;      // (1)
    print("ptr0 is %\n", ptr0); // => ptr0 is null
    ptra: *~s32 Obj; // (2) - 32-bit relative pointer to an Obj
    ptrb: *~s16 Obj; // (3) - 16-bit relative pointer to an Obj
    ptrc: *~s8  Obj; // (4) - 8-bit relative pointer to an Obj
    print("ptrc is %\n", ptrc); // => ptrc is r null
}