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