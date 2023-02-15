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