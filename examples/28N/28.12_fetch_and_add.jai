#import "Basic";

global_variable := 108;

main :: () {
    fetch_and_add :: (val: *int) #expand {
        #asm {
            mov incr: gpr, 1;
            xadd.q [val], incr;    // (1)
        }
    }
    fetch_and_add(*global_variable);
    print("global_variable is %\n", global_variable);
    // => global_variable is 109
}
