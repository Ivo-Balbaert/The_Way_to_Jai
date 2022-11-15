# 28 Inline assembly

This allows the inclusion of assembly code through the **#asm** directive. You would only do this for portions of the code where you need ultimate performance.  
The inner workings of Apollo Time in _Basic_ use inline assembly and operator overloading.  

Notes:
- `__reg` is the type for internal registers. 


## 28.1 Examples of AVX and AVX2 SIMD operations
See _28.1_assembly.jai_:
```c++
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
```

#asm takes a code block with assembly instructions (see line (1)). In the last compilation phase they are compiled into machine instructions at that place in the code. In line (2) AVX (Advanced Vector Extensions) instructions are used: #asm AVX.  
The #asm AVX, AVX2 allows for SIMD operations (see line (3) and following)
(see [Advanced Vector Extensions](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions) ). 

#asm can also be used inside macros, allowing to combine the power of inline assembly with macros.

## 28.2 Passing Inline Assembly Registers through Macro Arguments
See _28.2_asm_and_macros.jai_:
```c++
add_regs :: (c: __reg, d: __reg) #expand {  // (1)
  #asm {
     add c, d;
  }
}

main :: () {
  #asm {            // (2)
     mov a:, 10;
     mov b:, 7;
  }

  add_regs(b, a);   // (3)
}
```

In line (1) we define a macro `add_regs` that is called in line (3). It takes 2 parameters b and a, pushes them into 2 registers c and d of type `__reg` and adds them up. 