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