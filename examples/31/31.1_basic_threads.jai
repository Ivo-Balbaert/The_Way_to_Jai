#import "Basic";
#import "Thread";

thread_proc :: (thread: *Thread) -> s64 {  // (5)
    print("Thread context: %\n", context);
    return 0;
}

main :: () {
    print("Main context: %\n", context);
    thread1 := thread_create(thread_proc);  // (1)
    defer thread_destroy(thread1);          // (2)
    thread_start(thread1);                  // (3)
    sleep_milliseconds(1000);               // (4)
    while !thread_is_done(thread1) { }      // (5)
}

/*
Main context: {{thread_index = 0; allocator = {procedure 0x7ff7_35f4_7c60, null}; 
logger = procedure 0x7ff7_35f4_bcb0; logger_data = null; log_source_identifier = 0; 
log_level = NORMAL; temporary_storage = 7ff7_35f7_f008; dynamic_entries = [{(null), 
...
Thread context: {{thread_index = 1; allocator = {procedure 0x7ff7_35f4_7c60, null}; 
logger = procedure 0x7ff7_35f4_bcb0; logger_data = null; log_source_identifier = 0; 
log_level = NORMAL; temporary_storage = 21e_caf8_9b90; dynamic_entries = [{(null), 
...
*/