#import "Basic";
#import "System";

main :: () {
    num_cpus := get_number_of_processors();   // (1)
    assert(num_cpus >= 1);
    if num_cpus > 200  num_cpus = 200;
    #if (OS == .WINDOWS) || (OS == .LINUX) {  // (2) 
        num_cpus /= 2;
    }
    num_threads := max(num_cpus - 1, 2);
    log("This machine reports % CPUs; starting % threads.\n", num_cpus, num_threads);
    // => This machine reports 6 CPUs; starting 5 threads.
    // init(*thread_group, num_threads, work_proc);
}