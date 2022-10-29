#import "Basic"()(MEMORY_DEBUGGER=true);

main :: () {
    x := alloc(100);                // (1)
    // ....
    free(x);                        // (2)

    report := make_leak_report();   // (2)
    log_leak_report(report);        // (3)
}

/* When not freed:
----- 100 bytes in 1 allocation -----
alloc  c:/jai/modules/Basic/module.jai:87
main   d:/Jai/The_Way_to_Jai/examples/21/21.2_leak_detect.jai:4

Total: 100 bytes in 1 allocation.

Marked as non-leaks: 0 bytes in 0 allocations.
*/

/* When freed:
Total: 0 bytes in 0 allocations.

Marked as non-leaks: 0 bytes in 0 allocations.
*/
