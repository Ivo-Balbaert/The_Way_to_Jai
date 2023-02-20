#import "Basic";

main :: () {
    result: int;

    #asm {
        // compiler picks a general purpose register for you
        // that seems cool?
        a1 : gpr;
        a2 : gpr;
        
        // assign some 64-bit qwords
        mov.q a1, 42;
        mov.q a2, 13;
        
        // a1 += a2
        add a1, a2;
        
        // result = a1
        mov result, a1;
    }

    print("%\n", result); // => prints: 55
}