#import "Basic";

global_variable: int;

main :: () {
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