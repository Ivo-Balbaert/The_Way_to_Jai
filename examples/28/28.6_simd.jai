#import "Basic";

main :: () {
  array := float32.[1, 2, 3, 4];
  ptr := array.data;
  print("array before: %\n", array); // => 1, 2, 3, 4
  #asm {                         // (1)
    v: vec;
    movups.x v, [ptr];
    addps.x v, v;
    movups.x [ptr], v;
  }
  print("array after: %\n", array); // => 2, 4, 6, 8

  array2 := float32.[1, 2, 3, 4, 5, 6, 7, 8];
  ptr2 := array2.data;
  print("array2 before: %\n",array2); // => 1, 2, 3, 4, 5, 6, 7, 8
  #asm AVX {                    // (2)
      v2a: vec;
      movups.y v2a, [ptr2];
      addps.y v2a, v2a, v2a;
      movups.y [ptr2], v2a;
  }
  print("array2 after: %\n", array2); // => 2, 4, 6, 8, 10, 12, 14, 16

  // SIMD:
  a: [16] u8;
  b: [16] u8;
  c: [16] u8;

  // initialize 
  for i: 0..15 {
    a[i] = xx i;
    b[i] = xx (i+1);
  }

  ptr1 := a.data;
  ptr2b := b.data;
  ptr3 := c.data;

  #asm AVX, AVX2 {            // (3)
    movdqu.x v1:, [ptr1];     // v1 = [a]
    movdqu.x v2:, [ptr2b];    // v2 = [b]
    paddb.x  v3:, v1, v2;     // v3 = v1 + v2
    movdqu.x [ptr3],  v3;     // [c] = v3
  }

  print("a=%\n", a);
  print("b=%\n", b);
  print("c=%\n", c);
}


/*
array before: [1, 2, 3, 4]
array after: [2, 4, 6, 8]
array2 before: [1, 2, 3, 4, 5, 6, 7, 8]
array2 after: [2, 4, 6, 8, 10, 12, 14, 16]
a=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
b=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
c=[1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31]
*/