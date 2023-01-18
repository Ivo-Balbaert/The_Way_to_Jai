#import "Basic";

Accumulator :: struct {
  accumulation: [2][256] s16 #align 64;         // (1)
  computedAccumulation: s32;
} #no_padding                                   // (1C)

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
}