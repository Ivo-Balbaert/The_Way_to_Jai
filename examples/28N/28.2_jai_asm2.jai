#import "Basic";

main :: () {
    count := 10;

    #asm {
        var1: gpr;          // (1)
        mov.q var1, 17;     // (2)

        // mov var2: gpr, 10;   // (3A) assign 10 to var2
        // shorter:
        mov var2:, 10;          // (3B)
            
        add count, var1;    // (4)   (10 + 17)

    }
    // print("var1 is now %\n", var1); // (5)
    // => Invalid % index 1 in the format string "var1 is now %
    // " at character 13. (There are only 0 insertable arguments.)  
    // var1 is now

    print("count is now %\n", count);
    // => count is now 27
}