# 4E - What happens when Jai starts up?
The actual entry point of any Jai program is called `__system_entry_point`, found in _modules/Runtime_Support.jai_:

```c++
#program_export "main"
__system_entry_point :: (argc: s32, argv: **u8) -> s32 #c_call {
    __jai_runtime_init(argc, argv);  // (1)

    push_context first_thread_context {
        #if ENABLE_BACKTRACE_ON_CRASH {
            Handler :: #import "Runtime_Support_Crash_Handler";
            Handler.init();
        }

        __instrumentation_first ();
        __instrumentation_second();
        
        __program_main :: () #runtime_support;
        __program_main();   // (2)
    }
    
    return 0;
}
```

This first starts up a `__jai_runtime_init(argc, argv)` proc in line (1). This proc is also defined in the _Runtime_Support_ module. Its job is to take in the command-line arguments, and initialize the primary context.
Then back in `__system_entry_point` the runtime crash handler is activated and the `main` of your program is started (see line (2)).
(See also https://jai.community/docs?topic=131).