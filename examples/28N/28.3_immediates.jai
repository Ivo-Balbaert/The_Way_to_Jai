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