# 28 Inline assembly
This feature allows the inclusion of assembly code in Jai code through the **#asm** directive. You would only do this for portions of the code where you need ultimate performance.  
Its great advantage is also the integration with the Jai language, versus using a not-integrated external assembler.
    
Assembly language is mainly used to generate custom CPU instructions, support SIMD (Single Instruction, Multiple Data see: [Wikipedia SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_datainstructions)) for parallelizing data transformations, or take explicit control over the code generation to get the most optimized code.  
At this stage only the x86-64 platform is supported. In the future, other instruction sets will be added.  
Inline assembly does not support jumping, branching, NOP (No Operation instruction), or calling functions; use Jai for that.  

The **#bytes** directive is used to put the bytes that follow #the directive into machine code.

Inline assembly is being used inside some of the more critical performance standard modules, for example:
* the inner workings of Apollo Time in _Basic_ use inline assembly. 
* other inline assembly examples can be found in: _modules/Atomics_, *modules/Bit_Operations*, *modules/Runtime_Support*. 
* module *Machine_X64.jai* contains useful routines for 64-bit Intel x86 machines.

## 28.1 Examples of using AVX and AVX2 SIMD operations
These are some basic SIMD Vector Code for a few 32-bit floats together at the same time. .x means to adding 4 floats at the same time, while .y indicates adding 8 floats together at the same time.

See *28.1_assembly.jai*:
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

#asm takes a code block with assembly instructions (see line (1)). In the last compilation phase they are compiled into machine instructions at that place in the code. In line (2) AVX instructions are used: #asm AVX.  
The #asm AVX, AVX2 allows for SIMD operations (see line (3) and following)
(see [Advanced Vector Extensions](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions) ).
In line (1), .x means that 4 32-bit floats are added at the same time (in parallel).
In line (2), .y indicates that 8 32-bit floats are added at the same time.
Line (3) uses basic SIMD Vector Code for adding 8-bit integers together at the same time: .x indicates a 128-bit vector lane, and since 128/8 is 16, this piece of code is adding 16 8-bit integers all at once. We use `paddb`, or add packed integers assembly instruction to add all the integers together using SIMD.

### 28.1.1 Assembly Feature Flags
`#asm AVX, AVX2 { }` are called Assembly Feature Flags.
x86 does not have a single set of instructions. Rather, there are feature flags that indicate whether or not a particular set of instructions is present or not.

Some instruction sets include:
* AVX (Advanced Vector Extensions)
* AVX2 (Haswell New Instructions)
* AVX-512 (extension to 512 bits)
* MMX (MMX instructions)
* SSE3 (SSE3 instructions)

You can test on which instruction sets are available with the proc `get_cpu_info` from module _Machine_X64_:
See *28.5_get_cpu_info_feature_flags.jai*
```c++
#import "Basic";
#import "Machine_X64";

main :: () {
    cpu_info := get_cpu_info();         // (1)
    print("cpu_info: %", cpu_info);
    // => cpu_info: {INTEL, [3219913727, 4294636431, 0, 739248128, 289, 0, 10250153, 0, 3154117632, 0, 15]}
    if check_feature(cpu_info.feature_leaves, x86_Feature_Flag.AVX2) {  // (2)
        print("Yes, we have AVX2!"); // => Yes, we have AVX2!
        #asm AVX2 {
    // Here the pxor gets the 256-bit .y version, since that is the default operand size with AVX. In an AVX512 block, the default operand size would be the 512-bit .z.
            pxor v1:, v1, v1;
        }
    } else {
         print("AVX2 is not available on this processor, we have to run our fallback path...");
    // AVX2 is not available on this processor, we have to run our fallback path...
    }   
}
```
We call the proc in line (1), and test whether it is AVX2 capable in line (2).

#asm can also be used inside macros, allowing to combine the power of inline assembly with macros.

## 28.2 Passing Inline Assembly Registers through Macro Arguments
`__reg` is the type for internal registers. 

See *28.2_asm_and_macros.jai*:
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

## 28.3 Overview of Inline Assembly instructions
Instructions are named based on the mnemonic and operands provided and are identical to the official mnemonic provided by Intel and AMD.  
Here you can find the [list](https://www.felixcloutier.com/x86/index.html).

## 28.4 Assembly Language Data Types
The types are: `gpr`, `str`, `vec`, and `omr`.
* gpr stands for general purpose register.
    gpr.a means that the gpr must be pinned to the register a (e.g. EAX: gpr === a),
    pool: 8 in 32-bit mode, 16 in 64-bit mode
* imm8 is an 8 bit immediate
* mem means the operation must be a memory operand (e.g. lea.q [EAX], rax)
* str stands for stack register, pool: 8 (mostly legacy, used by fpu and mmx instructions).
* vec stands for a vector type. This is used for manipulating SIMD instructions, pool: 8 in 32-bit mode, 16 in 64-bit mode pre AVX512, 32 in 64-bit mode post AVX512
* omr stands for op-mask register, only available with AVX512

  ### 28.4.1 Declaration of variables
See *28.3_declarations.jai*:
```c++
main :: () {
    #asm {
        var: gpr; // declared a general purpose register named 'var'
        mov var, 1; // assign var = 1
    }

    #asm {
        // declared a general purpose register named 'var2', and mov 1 into it
        mov var2: gpr, 1; // assign var2 = 1
    }

    #asm {
        // implicitly declare 'var3' without specifying the type
        mov var3:, 1;
    }
}
```

### 28.4.2 List of different operations
These specify the assignment-size:

* .b is a byte (8-bit integer).
* .w is a regular word (16-bit integer).
* .d is double-word (32-bit integer).
* .q is quad-word (64-bit integer).
* .x is the SSE is in the feature set, xmmword (128-bit)
* .y is the AVX is in the feature set, ymmword (256-bit)
* .z is the AVX512F is in the feature set, zmmword (512-bit)

### 28.4.3 List of registers
The allowed registers are:   
a, b, c, d, sp, bp, si, di,  
or an integer between 0 and 15 (representing SIMD registers from xmm0 to xmm15).

The `===` operator is used to put values in registers, for example:
`result === a`  //  result is represented as register a

See the following examples: *28.4_other_examples.jai*
```c++
#import "Basic";

global_variable: int;

main :: () {
    // Multiply x and y to z
    x: u64 = 197589578578;
    y: u64 = 895173299817;
    z: u64 = ---;
    #asm {
        x === a; // We pin the high level var 'x' to gpr 'a' as required by mul.
        z === d; // We pin the high level var 'z' to gpr 'd' as required by mul.
        mul z, x, y;
    }
    print(" z is %\n", z); // => z is 9588  (z is uninitialized, so contains its previous value)

    // loading memory into registers
    array: [32] u8;
    pointer := array.data;
    #asm {
        mov a:, [pointer];      // a := array.data
        mov i:, 10;             // declare i:=10
        mov a,  [pointer + 8];
        mov a,  [pointer + i*1];
    }

    // Load Effective Address (LEA) Load and Read Instruction Example
    rax := 5;
    rdx := 7;
    #asm {lea.q rax, [rdx];}
    #asm {lea.q rax, [rdx + rax*4];}
    // NOTE: This does not work, 4*rax is wrong, must be rax*4
    // #asm {lea.q rax, [rdx + 4*rax];} 
    // => Error: Bad memory operand, syntax is [base + index * 1/2/4/8 +/- disp].

    // Fetch and add:
    // fetch and add.
    fetch_and_add :: (val: *int) #expand {
        #asm {
            mov incr: gpr, 1;
            xadd.q [val], incr;
        }
    }
    fetch_and_add(*global_variable);
}
```

#asm blocks can be named, so that variables can be cross-referenced:  
```
block_1 :: #asm { pxor x:, x; }
block_2 :: #asm { movdqu y:, block_1.x; }
```

## 28.5 The Machine_X64 module
This module contains useful routines for 64-bit Intel/AMD x86 computer architecture machines, for example:

* `prefetch` : a method for speeding up by beginning a fetch operation before the memory is needed; an example:  `prefetch(array.data, Prefetch_Hint.T0);`
* `mfence` : Memory Fence - performs a serializing operation on all load-from-memory and store-to-memory instructions that were issued prior the mfence instruction
* `pause`
* `get_cpu_info` : gets the CPU info and checks whether a particular assembly instruction is available, example:

(For more details: see [Community Wiki](https://jai.community/docs?topic=178))