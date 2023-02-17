#import "Basic";

main :: () {
    rax := 5;
    rdx := 7;
    #asm {lea.q rax, [rdx];}
    #asm {lea.q rax, [rdx + rax*4];}
    print("rax is % and rdx is %", rax, rdx);
    // => rax is 35 and rdx is 7
}