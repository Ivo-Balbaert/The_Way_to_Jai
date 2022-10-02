#import "Basic";

proc1 :: (n: u8) -> u8 {
    print("In proc1 - u8 line (1)\n");
    return n * 2; 
}       // (1)

proc1 :: (n: u16) -> u16 {
    print("In proc1 - u16 line (2)\n");
    return n * 2; 
}     // (2)

proc2 :: (n: u8) { print("In proc2 - u8 line (3)\n"); }            // (3)
proc2 :: (str: string) { print("In proc2 - string line (4)\n"); }  // (4)

main :: () {
    a := proc1(12);   // => In proc1 - u8 version (1)
    b := proc1(256);  // => In proc1 - u16 version (2)
    print("The results are % and %\n", a, b); 
    // => The results are 24 and 512

    {
        proc2 :: (n: u16) { print("In proc2 - u16 line (5)\n"); }         // (5)
        proc2 :: (n: u64) { print("In proc2 - u64 line (6)\n"); }         // (6)  
        m: u8 = 8;
        proc2(m);                 // (7) 
        // => In proc2 - u8 line (3)
        proc2("Hello, JAI!");     // (8)
        // => In proc2 - string line (4)
    }
}

