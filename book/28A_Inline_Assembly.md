# 28 Inline assembly

## 28.1 Inline assembly: what and why
This feature allows the inclusion of assembly code in Jai code through the **#asm** directive. This directive takes a code block with assembly instructions, which are compiled into machine instructions at that place in the code in the last compilation phase.  
You would only do this for portions of the code where you need ultimate performance.  
Its great advantage is also the integration with the Jai language, versus using a not-integrated external assembler.
    
Assembly language is mainly used to generate custom CPU instructions, support SIMD (Single Instruction, Multiple Data see: [Wikipedia SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_datainstructions)) for parallelizing data transformations, or take explicit control over the code generation to get the most optimized code.  
At this stage only the x86-64 platform is supported. In the future, other instruction sets will be added.  
Inline assembly does not support jumping, branching, NOP (No Operation instruction), or calling functions; use Jai for that.  

The **#bytes** directive puts individual bytes into your program as machine code. This could be used to write one's own assembler.

Inline assembly is being used inside some of the more critical performance standard modules, for example:
* the inner workings of Apollo Time in _Basic_ use inline assembly. 
* other inline assembly examples can be found in: _modules/Atomics_ (for example `lock_xchg` for atomic_swap ), *modules/Bit_Operations*, *modules/Runtime_Support*. 
* module *Machine_X64.jai* contains useful routines for 64-bit Intel x86 machines.  

_Current Assembly Limitations_    
There are no goto and no jump instructions in the current assembly. There are no call instructions, and you cannot call a function in the middle of an assembly block.

## 28.2 How do Jai and inline assembly interact? - Declaring variables  
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
The variable `count` defined in line (1) in Jai on the stack is visible inside the #asm block, where it is stored in a gpr.  
In line (2) 17 is added to it. In assembly, `add a,b` is the same as a += b (or a = a + b).  
Jai sees that and prints out the changed value 27. Inside the #asm block, count is a named gpr.  

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

Knowing this, both statements can be combined as in line (3A-B), where a gpr variable var2 is declared and the value 10 is stored in it. In line (3B), we implicitly declare var2, without specifying the type. So going from (1-2) to (3A) to (3B) to get the shortest form.  
In line (4) var1 is added to `count`, and Jai prints out its new value 27.

> Jai cannot see the values declared in the #asm block, as you can see from the error in line (5). Also a variable declared in an #asm block cannot be redeclared in Jai.

**Cross Block #asm Referencing**
#asm blocks can also be named, so that variables can be cross-referenced:  
```c++
block_1 :: #asm { pxor x:, x; }
block_2 :: #asm { movdqu y:, block_1.x; }
```
Cross block #asm referencing keeps your registers alive across the procedure. LLVM optimizations could potentially spill them if required.

**Exercise**
Declare a `result` variable of type int. Write an #asm block that adds 42 and 13, and stores the sum in `result`. Verify by printing `result`.
(see *asm1.jai*)

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
The compiler implements register allocation to replace variables with registers, allowing you to use variable names to convey data flow the same way as in high level code. The register allocator takes lifetimes into account.  
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

    print("x * y = % : %\n", z, x);  (10)
    // => x * y = 9588 : 9532886391493626018
}
```
 
In lines (1-2), registers a and c are allocated, and they get freed in line (3).
In the 2nd block in line (4), we see how operator `===` is used: variable `t` is pinned to gpr 'a' (0/al/ax/eax/rax).  
In the same way in (5), `u` is pinned to gpr 'c' (1/cl/cx/ecx/rcx), and in (6), 'v' is pinned to vec '9' (xmm9/ymm9/zmm9).  
The === operator is used to pin variables to general purpose registers. In this simplified byte swap example, result is assigned to a register. The === operator can be used to map to registers a, b, c, d, sp, bp, si, di, or an integer between 0 and 15.  
In line (7), this is written inline. This is the verbose version of the inferred operands we saw earlier, specifying the entire declaration explicitly if you want.

In the 3rd block, we multiply x and y in asm, and put the result in z. The multiply requires the d register and the a register for the multiply instruction. Line (8) pins the high level var `x` to gpr 'a' as required by `mul`. Line (9) does the same for variable `z` to gpr 'd'.  
In line (10), z is uninitialized, so it contains its previous value.

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

The #asm AVX, AVX2 allows for SIMD operations (see [Advanced Vector Extensions](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions).)

## 28.7 Using AVX and AVX2 SIMD operations
Because SIMD involves arrays, we first have to see how we can load an array into asm memory.

## 28.7.1 Assembly memory operands: Loading memory into registers
In x86, there are several memory operands with the format `base + index * scale + displacement`. Just like in a traditional assembly, you can indicate a memory operand by wrapping it with brackets []. The ordering of the expression is rigid, and must be in the order base + index * scale + displacement. You cannot place the displacement first, or the base second, etc. This reduces ambiguity and confusion when fields can be ambiguous identifiers. The scale is limited to the number literals 8, 4 and 2.
Here are some other rules:  
* base  - required, must be a gpr
* index - optional, usually a gpr but can also be a vec in some instructions 
* scale - only valid when there is an index, can be 1, 2, 4, or 8, when omitted it is default 1
* disp  - optional, a signed 8 or 32 bit integer byte offset

See *28.9_loading_memory*:
```c++
#import "Basic";

main :: () {
    array: [32] u8;
    pointer := array.data;
    #asm {
        mov a:, [pointer];       // (1) 
        mov i:, 10;              // 
        mov a,  [pointer + 8];   // (2)
        mov a,  [pointer + i*1]; // (3)
    }
}
```

The instruction in line (1) effective declares register a to be the array.data pointer. We move the pointer to the next byte in line (2). Line (3) shows how to access individual bits.

## 28.7.2 Working with SIMD
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
`add_regs` or any #asm block does not return any value

## 28.9 Compile-time execution
#asm blocks can also run at compile time, just like any other code. The code is compiled to machine code once and runs at native speed, so you can expect it to be just as fast.

See *28.8_compile_time_exec.jai*:
```c++
#import "Basic";

do_some_work :: (a: int, b: int) -> int {
    #asm {
        add a, b;
    }
    return a;
}

A :: #run do_some_work(10, 13);

main :: () {
    print("A: %\n", A); // => A: 23 
}
```

## 28.10 Other useful examples

## 28.10.1 Manipulating an array through pointers
This manipulates a memory operand with a vector index, known as a VSIB in assembly documentation.
In the following example, we have a float array `orig_arr`, an indices mask 
`gather_indices`, and the destination array `dest_arr`.
To clearly see what's going on, we shuffled the indices a bit. In the #asm block, we take  
the items from `orig_arr` in the order of `gather_indices`, and put them in `dest_arr`.

See *28.10_vsib1.jai*:
```c++
#import "Basic";

main :: () {
    orig_arr := float.[ 1, 2, 3, 4, 5, 6, 7, 8 ];
    gather_indices := u32.[ 0, 6, 5, 2, 3, 4, 1, 7 ];
    dest_arr: [8] float;

    orig_arr_ptr := orig_arr.data;
    gather_indices_ptr := gather_indices.data;
    dest_arr_ptr := dest_arr.data;

    #asm AVX, AVX2 {
        movdqu vindex:, [gather_indices_ptr];       // (1) 
        pcmpeqd gather_mask:, gather_mask, gather_mask; // (2)
        gatherdps gather_dest:, [orig_arr_ptr + vindex*4], gather_mask;
        movdqu [dest_arr_ptr], gather_dest;         // (3)
    }

    print("gather result: %\n", dest_arr);          // (4)
    // => gather result: [1, 7, 6, 3, 4, 5, 2, 8] 
}
```

In line (1), we load the register we are going to use for indexing from the gather_indices array. In line (2), We get all 1's in our gather mask, we want to just let all lanes through.
Note that we scale our indices by 4. That is because these are byte offsets and we need to step in multiples of the element size (32-bits), like any other memory operand. Also note that we don't use a displacement, but it is supported and behaves just like a normal memory operand.  
In line (3), the destination array is filled, and in (4), Jai prints it out.
   
## 28.10.2 Load Effective Address (LEA) and Load and Read Instruction 
Here is a basic example to do load effective address. Note that in rax*4, the constant must go after the register. LEA is explained [here](https://www.felixcloutier.com/x86/lea). 

See *28.11_load_effective_address.jai*:
```c++
#import "Basic";

main :: () {
    rax := 5;
    rdx := 7;
    #asm {lea.q rax, [rdx];}
    #asm {lea.q rax, [rdx + rax*4];}
    print("rax is % and rdx is %", rax, rdx);
    // => rax is 35 and rdx is 7
}
```

## 28.10.3 Fetch and add macro to increment a variable
The fetch-and-add instruction increments the contents of a memory location by a specified value. This is a translation of a C++ fetch add from `Godbolt`. This operation is normally used in concurrency. More information on this can be found at: [Fetch-and-Add](https://en.wikipedia.org/wiki/Fetch-and-add)

See *28.12_fetch_and_add.jai*:
```c++
#import "Basic";

global_variable := 108;

main :: () {
    fetch_and_add :: (val: *int) #expand {
        #asm {
            mov incr: gpr, 1;
            xadd.q [val], incr;     // (1)
        }
    }
    fetch_and_add(*global_variable);
    print("global_variable is %\n", global_variable);
    // => global_variable is 109
}
```
`global_variable` is incremented through the xadd.q instruction in line (1).

## 28.10.4 Binary swap
Here is how you can do a swap operation in inline assembly:

See *28.13_binary_swap.jai*:
```c++
#import "Basic";

main :: () {
    foo : u16 = 0xff00;
    print("%\n", formatInt(foo, base=16)); // => ff00
    #asm {
        mov a: gpr === a, foo;
        bswap.w a;
        mov foo, a;
    }
    print("%\n", formatInt(foo, base=16)); // => ff
    #asm {
        mov a, foo;
        bswap.w a;
        mov foo, a;
    }
    print("%\n", formatInt(foo, base=16)); // => ff00
}
```

## 28.10.5 Reset Lowest Set Bit (BLSR)
BLSR, or Reset Lowest Set Bit, is an instruction that copies all bits from the source into the destination, and sets the least significant bit to zero. This is equivalent to a &= a-1. You can find more information on BLSR [here](https://www.felixcloutier.com/x86/blsr).

See *28.14_blsr.jai*:
```c++
#import "Basic";

popbit :: (a: u64) -> u64 #expand {
  #asm { blsr.q a, a; }
  return a;
}

main :: () {
    a: u64 = 0xFF;
    print("%\n", formatInt(a, 2));
    a = popbit(a);
    print("%\n", formatInt(a, 2));
    a = popbit(a);
    print("%\n", formatInt(a, 2));
    a = popbit(a);
    print("%\n", formatInt(a, 2));
}

/*
11111111
11111110
11111100
11111000
*/
```

## 28.10.6 Reversing 64-bits integer
This is some code from the Jai Community Wiki to reverse a 64-bit integer, translated from an objdump on a clang intrinsic. movabs can be replaced by a mov.q.

See *28.15_bit_reverse.jai*:
```c++
#import "Basic";

bit_reverse64  :: (x: u64) -> u64 #expand {
  // Modified from clang objdump
  rdi: u64 = x;
  rax, rcx, rdx: u64;
  #asm {
    bswap.q   rdi;
    mov.q     rax, 1085102592571150095;
    and.q     rax, rdi;
    shl.q     rax, 4;
    mov.q     rcx, -1085102592571150096;
    and.q     rcx, rdi;
    shr.q     rcx, 4;
    or.q      rcx, rax;
    mov.q     rax, 3689348814741910323;
    and.q     rax, rcx;
    mov.q     rdx, -3689348814741910324;
    and.q     rdx, rcx;
    shr.q     rdx, 2;
    lea.q     rax, [rdx + rax*4];
    mov.q     rcx, 6148914691236517205;
    and.q     rcx, rax;
    mov.q     rdx, -6148914691236517206;
    and.q     rdx, rax;
    shr.q     rdx;
    lea.q     rax, [rdx + rcx*2];
  }
  return rax;
}

main :: () {
    x := cast(u64) 0xA;
    y := bit_reverse64(x);
    print("%\n", y); // => 5764607523034234880
    // Binary convert this numnber:
    // 01010000000000000000000000000000000000000000000000000000000
}
```

0xA == 10 == 1010 in binary, so reversed this becomes: 0101000...

## 28.10.7 Broadcasting, rounding and masking with EVEX
See procedure `advanced_features :: ()` in how_to/900_inline_assembly.jai, last three examples.
To execute this, your computer must support the AVX512F instruction set.








