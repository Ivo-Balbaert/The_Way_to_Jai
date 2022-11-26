#import "Basic";

Accumulator :: struct {
  accumulation: [2][256] s16 #align 64;         // (1)
  computedAccumulation: s32;
}

Object :: struct {member: int #align 64; }      // (1B)

Thing :: struct {
   member1: u8  #align 1;                        // (2)
   member2: u32 #align 1;
}

global_var: [100] int #align 64;                 // (3) 

main :: () {
    assert(cast(int)(*global_var) % 64 == 0);    // (4)
    object := New(Object);         // (5)
    // assert(cast(int)(*object) % 64 == 0); // => Assertion failed
    free(object);
    N :: 100;
    object_array := NewArray(N, Object, alignment=64);  // (6)
    assert(cast(int)(*object_array[0]) % 64 == 0);      // (7)
    assert(cast(int)(*object_array[1]) % 64 == 0);
    assert(cast(int)(*object_array[10]) % 64 == 0);
}