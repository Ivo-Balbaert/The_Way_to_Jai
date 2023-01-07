#import "Basic"()(MEMORY_DEBUGGER=true);

main :: () {
    x := alloc(100);                // (1)
    // ....
    free(x);                        // (2)

    report := make_leak_report();   // (2)
    for report.sorted_summaries print("** Summary %: **\n%\n", it_index, <<it); // (2B)

    log_leak_report(report);        // (3)

}

/* When not freed:
** Summary 0: **
{count = 1; bytes = 100; allocations_since_last_visualizer_update = 1; bytes_allocated_since_last_visualizer_update = 100; alloc_site_trace = 1ca_ada2_85e8; allocator_proc = procedure 0x7ff6_5518_14f0; group_info = null; }

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
