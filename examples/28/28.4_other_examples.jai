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
    print(" z is %\n", z); // => z is 9588  (??)

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