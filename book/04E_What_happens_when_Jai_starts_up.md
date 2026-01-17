# 4E - What happens when Jai starts up?
The actual entry point of any Jai program is called `__system_entry_point`, found in _modules/Runtime_Support.jai_:

```jai
#program_export
__jai_runtime_init :: (argc: s32, argv: **u8) -> *Context #c_call {
    __command_line_arguments.count = argc;
    __command_line_arguments.data  = argv;

    ts := *first_thread_temporary_storage;
    ts.data = first_thread_temporary_storage_data.data;
    ts.size = TEMPORARY_STORAGE_SIZE;

    ts.original_data = first_thread_temporary_storage_data.data;
    ts.original_size = TEMPORARY_STORAGE_SIZE;
    
    first_thread_context.temporary_storage = ts;

    return *first_thread_context;
}

#program_export
__jai_runtime_fini :: (_context: *void) #c_call {
    // Nothing here for now!
}

#program_export "main"           // <= starting point of execution
__system_entry_point :: (argc: s32, argv: **u8) -> s32 #c_call {
    __jai_runtime_init(argc, argv);      // (1)

    push_context first_thread_context {  // (2)
        __program_main :: () #runtime_support;   
        __program_main();                // (3)
    }
    
    return 0;
}
```

This first starts up a `__jai_runtime_init(argc, argv)` proc in line (1). This proc is also defined in the _Runtime_Support_ module. Its job is to take in the command-line arguments argc and argv and store them in the array `__command_line_arguments`. It also initializes the primary context and defines a temporary storage ts.
Then back in `__system_entry_point`, the created context `first_thread_context` is pushed (see line (2))and the `main` of your program is started (see line (3)). (See also https://jai.community/docs?topic=131).