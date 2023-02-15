# 28 Inline assembly

## 28.1 Inline assembly: what and why
This feature allows the inclusion of assembly code in Jai code through the **#asm** directive. This directive takes a code block with assembly instructions, which are compiled into machine instructions at that place in the code in the last compilation phase.  
You would only do this for portions of the code where you need ultimate performance.  
Its great advantage is also the integration with the Jai language, versus using a not-integrated external assembler.
    
Assembly language is mainly used to generate custom CPU instructions, support SIMD (Single Instruction, Multiple Data see: [Wikipedia SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_datainstructions)) for parallelizing data transformations, or take explicit control over the code generation to get the most optimized code.  
At this stage only the x86-64 platform is supported. In the future, other instruction sets will be added.  
Inline assembly does not support jumping, branching, NOP (No Operation instruction), or calling functions; use Jai for that.  

The **#bytes** directive is used to put the bytes that follow #the directive into machine code.

Inline assembly is being used inside some of the more critical performance standard modules, for example:
* the inner workings of Apollo Time in _Basic_ use inline assembly. 
* other inline assembly examples can be found in: _modules/Atomics_, *modules/Bit_Operations*, *modules/Runtime_Support*. 
* module *Machine_X64.jai* contains useful routines for 64-bit Intel x86 machines.

## 28.2 How do Jai and inline assembler interact? - Declaring variables  
Inside Jai code, we can start an inline assembler block like this:  
```c++
#asm {
    ...
}
```

All statements in this block are of the form:  
`mnemonic operand, operand, operand, ...`   
where mnemonic is a name for an operation, like add or move.  
Operands can be variable names or literal values; these values are stored in *general purpose registers*, **gpr** for short. Any modern CPU has between 8 and 32 gpr's.

Multiple #asm blocks can appear throughout Jai code.  
Such a block does NOT define a new scope. Jai variables defined in the same scope the #asm block is defined in are visible and can be changed inside it, as shown in the following example:

See *28.1_jai_asm1.jai*:
```c++
#import "Basic";

main :: () {
    count := 10;          // (1)

    #asm {
        add count, 17;    // (2)
    }

    print("count is %\n", count); // => count is 27
}
```
The variable `count` defined in line (1) in Jai on the stack is visible inside the #asm block, where it is stored in a gpr. In line (2) 17 is added to it. Jai sees that and prints out the changed value 27. Inside the #asm block, count is a named gpr.  

We can also define variables in the asm block, and let them interact with Jai variables like this:

See *28.2_jai_asm2.jai*:
```c++
#import "Basic";

main :: () {
    count := 10;

    #asm {
        var1: gpr;          // (1) 
        mov.q var1, 17;     // (2) - assign 17 to var1

        // mov var2: gpr, 10;   // (3A) 
        // shorter:
        mov var2:, 10;          // (3B)
    
        add count, var1;    // (4) (10 + 17)

    }
    // print("var1 is now %\n", var1); // (5)
    // => Invalid % index 1 in the format string "var1 is now %
    // " at character 13. (There are only 0 insertable arguments.)  
    // var1 is now

    print("count is now %\n", count);
    // => count is now 27
}
```
In line (1) a register variable var1 is explicitly declared up front as a gpr, and in line (2) we store the value 17 in it. This line uses an explicit operand size *.q* , which means a 64-bit operand size.  
Because we are in 64-bit mode with #asm, a 64-bit operand size is the default implicit size being used with scalar ops.

> #asm uses automatic register mapping, so you can use familiar high level names just like in Jai programming.

Knowing this, both statements can be combined as in line (3A-B), where a gpr variable var2 is declared and the value 10 is stored in it. In line (3B), we implicitly declare var2, without specifying the type.  
In line (4) var1 is added to `count`, and Jai prints out its new value 27.

> Jai cannot see the values declared in the #asm block, as you can see from the error in line (5).

#asm blocks can also be named, so that variables can be cross-referenced:  
```c++
block_1 :: #asm { pxor x:, x; }
block_2 :: #asm { movdqu y:, block_1.x; }
```

## 28.3 Some background info

### 28.3.1 Overview of inline assembly instructions
The mnemonics used in #asm are identical to the official mnemonic provided by Intel and AMD.  
Here you can find the [list](https://www.felixcloutier.com/x86/index.html) of instructions.

### 28.3.2 List of size abbreviations
These specify the assignment-size:

* .b is a byte (8-bit integer).
* .w is a regular word (16-bit integer).
* .d is double-word (32-bit integer).
* .q is quad-word (64-bit integer).
* .x is the SSE is in the feature set, xmmword (128-bit)
* .y is the AVX is in the feature set, ymmword (256-bit)
* .z is the AVX512F is in the feature set, zmmword (512-bit)
* 
In traditional assembly you specifiy operand sizes through the names of the registers (ax/eax/rax). Here those names aren't used, the size is appended onto the mnemonic.
            
Since we are in 64-bit mode, a 64-bit operand size is the default implicit size being used with scalar ops.
When dealing with vector ops, either .x, .y, or .z is used depending on the computer's feature set.

### 28.3.3 Assembly Language Data Types
The types are: `gpr`, `imm`, `mem`, `str`, `vec`, and `omr`.
* gpr stands for general purpose register.
    gpr.a means that the gpr must be pinned to the register a (e.g. EAX: gpr === a),
    pool: 8 in 32-bit mode, 16 in 64-bit mode
* imm8 is an 8 bit immediate
* mem means the operation must be a memory operand (e.g. lea.q [EAX], rax)
* str stands for stack register, pool: 8 (mostly legacy, used by fpu and mmx instructions).
* vec stands for a vector type. This is used for manipulating SIMD instructions, pool: 8 in 32-bit mode, 16 in 64-bit mode pre AVX512, 32 in 64-bit mode post AVX512
* omr stands for op-mask register, only available with AVX512

### 28.3.4 Assembly Feature Flags
Sometimes an #asm block is declared like this:
`#asm AVX, AVX2 { }`   
The AVX and AVX2 are called Assembly Feature Flags. What are these?  
x86 does not have a single set of instructions. Rather, there are feature flags that indicate whether or not a particular set of instructions is present or not in the CPU.

Some instruction sets include:
* AVX (Advanced Vector Extensions)
* AVX2 (Haswell New Instructions)
* AVX-512 (extension to 512 bits)
* MMX (MMX instructions)
* SSE3 (SSE3 instructions)

### 28.3.5 List of registers
The allowed registers are:   
*a, b, c, d, sp, bp, si, di*
or an integer between 0 and 15 (representing SIMD registers from xmm0 to xmm15).

The `===` operator is used to put values in registers, for example:
`result === a`  //  result is represented as register a

### 28.3.6 The Machine_X64 module
This module contains useful routines for 64-bit Intel/AMD x86 computer architecture machines, for example:

* `prefetch` : a method for speeding up by beginning a fetch operation before the memory is needed; an example:  `prefetch(array.data, Prefetch_Hint.T0);`
* `mfence` : Memory Fence - performs a serializing operation on all load-from-memory and store-to-memory instructions that were issued prior the mfence instruction
* `pause`
* `get_cpu_info` : gets the CPU info and checks whether a particular assembly instruction is available, example:

The module also contains a list of feature flags (see § 28.6) that can be used, namely in the `x86_Feature_Flag` enum. 

(For more details: see [Community Wiki](https://jai.community/docs?topic=178))


## 28.4 Immediate operands
Using the sizes from § 28.3.2, we can do the following `mov` instructions. We just have to take care that the number of bits of the value fit in the indicated bit size.  
If not, you get an error, like in (1).

See *28.3_immediates.jai*:
```c++
#import "Basic";

main :: () {
    #asm {
        mov.b b1:,  255;
        mov.b b2:, -127;
        // mov.b b3:, 256; // (1) => Error: A matching instruction form was not found...

        mov.w w1:,  65535;
        mov.w w2:, -32768;
        mov.d d1:,  4294967295;
        mov.d d2:, -2147483648;
        mov.q q3:,  18446744073709551615;
        mov.q q4:, -9223372036854775808;

        mov.q q1:,  2147483647;
        mov.q q2:, -2147483648;

        mov.d f1:, 133.247;
        mov.q f2:, 133.247;
    }
}
```

The types used in these instructions are imm8 to imm64, according to the size.

## 28.5 Allocation and pinning
You can also directly use the names of registers (see § 28.3.5) to allocate values in them:

See *28.4_allocation_pinning.jai*:
```c++
#import "Basic";

main :: () {
    // using gpr:
    #asm {
        mov a:, 32; // (1) 
        mov c:, 16; // (2) 
        add a,  c;  // (3) 
    }

    #asm {
        t: gpr === a; // (4) 
        u: gpr === c; // (5)
        v: vec === 9; // (6)
        mov w: gpr === 15, 10; // (7)
    }

    x: u64 = 197589578578;
    y: u64 = 895173299817;
    z: u64 = ---;

    #asm {
        x === a; // (8) 
        z === d; // (9) 
        mul z, x, y;
    }

    print("x * y = % : %\n", z, x); 
    // => x * y = 9588 : 9532886391493626018
}
```

In lines (1-2), registers a and c are allocated, and they get freed in line (3).
In the 2nd block in line (4), we see how operator `===` is used: variable `t` is pinned to gpr 'a' (0/al/ax/eax/rax).  
In the same way in (5), `u` is pinned to gpr 'c' (1/cl/cx/ecx/rcx), and in (6), 'v' is pinned to vec '9' (xmm9/ymm9/zmm9).  
In line (7), this is written inline. This is the verbose version of the inferred operands we saw earlier, specifying the entire declaration explicitly if you want.

In the 3rd block, we multiply x and y in asm, and put the result in z. Line (8) pins the high level var `x` to gpr 'a' as required by `mul`. Line (9) does the same for variable `z` to gpr 'd'.

## 28.6 Feature flags
These were introduced in § 28.3.4. Feature flags can be specified on a global build level, or on a per-asm-block level, or both. Flags specified on both levels add up.

### 28.6.1 Global build level
To specify flags on a global build level, you setup the flags you want and pass them with the build options during your build step. The flags are binary compatible with the feature bits specified by CPUID. 

Set feature bits on `build_options.machine_options.x86_features.leaves` via the `enable_feature function` in *Machine_X64.jai*.


### 28.6.2 Asm-block level
In addition to the global build flags, you can specify additional features to enable for a specific #asm block. The names match with the `x86_Feature_Flag` enum in *Machine_X64.jai.*  
Do this by listing the feature flags as follows:
```c++
    #asm AVX, AVX2 {
        ...
    }
```
Now you can use AVX and AVX2 instructions in that block, even when our global build feature set didn't include them.

### 28.6.3 Checking on feature flags
To make use of feature flags, you'll have to do a runtime check and branch on the flags. In our example above, we'd have to check for AVX and AVX2 support on the current hardware, and branch to an older feature set if it doesn't support these flags.  

You can test on which instruction sets are available with the proc `get_cpu_info` from module *Machine_X64*:

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
            pxor v1:, v1, v1;
        }
    } else {
         print("AVX2 is not available on this processor, we have to run our fallback path...");
    }   
}
```
We call the proc in line (1), and test whether it is AVX2 capable in line (2). If so we add the flag to our #asm block.  
In it, we have a `pxor` instruction, which is the 256-bit .y version, since that is the default operand size with AVX. In an AVX512 block, the default operand size would be the 512-bit .z.

The #asm AVX, AVX2 allows for SIMD operations (see [Advanced Vector Extensions](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions).

## 28.7 Using AVX and AVX2 SIMD operations
Here is some basic SIMD Vector Code to process a few 32-bit floats together in parallel (at the same time).   

See *28.6_simd.jai*:
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
 
In line (1), .x means that 4 32-bit floats are added at the same time (in parallel).
In line (2), .y indicates that 8 32-bit floats are added at the same time.
Line (3) uses basic SIMD Vector Code for adding 8-bit integers together at the same time: .x indicates a 128-bit vector lane, and since 128/8 is 16, this piece of code is adding 16 8-bit integers all at once. We use `paddb`, or the add packed integers assembly instruction to add all the integers together using SIMD.

## 28.8 Macros and asm
#asm can also be used inside macros, allowing to combine the power of inline assembly with macros.  
Registers can't be passed to other procedures, but you can pass inline assembly registers to macro arguments.  
No additional mov's or other instructions will be generated as a result of this. The names are simply bound to one another by the compiler and the same underlying register allocation is used.  

This is used in the following example:
See *28.7_asm_and_macros.jai*:
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

    add_regs(a, b);   // (3)

    c: u64 = ---;
    #asm {
        mov c, b;
    }
    print("c: %\n", c); // (4) => c: 17
}
```

In line (1) we define a macro `add_regs` that is called in line (3). It takes 2 parameters a and b, pushes them into 2 registers c and d of type `__reg` and adds them up. The result is printed out in line (4).





XYZ
For memory operands in the form 'base + index * scale + displacement', see procedure memory() in how_to/900_inline_assembly.jai.

===============================================================




See the following examples: *28.8_other_examples.jai*
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



