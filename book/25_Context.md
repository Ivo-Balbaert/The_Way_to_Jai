# 25 Context

A central concept in Jai is the **context**.

The context struct is defined in module _Preload_ as:  
```c++
Context_Base :: struct {
    thread_index   : u32;
    allocator      := Allocator.{__default_allocator_proc, null};  // (1)

    logger         := default_logger;       // (2)
    logger_data    :  *void;
    log_source_identifier: u64;     
    log_level      :  Log_Level;    
    temporary_storage: *Temporary_Storage;  // (3)
    dynamic_entries: [16] Dynamic_Context_Entry;
    num_dynamic_entries: s32;
    stack_trace: *Stack_Trace_Node;         // (4)
    assertion_failed := default_assertion_failed;
    handling_assertion_failure := false;  

    default_logger           :: (message: string, data: *void, info: Log_Info) { runtime_support_default_logger :: (message: string, data: *void, info: Log_Info) #runtime_support; runtime_support_default_logger(message, data, info); }  
    default_assertion_failed :: (loc: Source_Code_Location, message: string) { runtime_support_assertion_failed :: (loc: Source_Code_Location, message: string) #runtime_support; runtime_support_assertion_failed(loc, message); }  default_allocator        :: Allocator.{__default_allocator_proc, null};  // (5)
}
```

The context is available at runtime and is globally known in the code. 
It contains memory allocation ((5)), logging functionality (2), assertion handler (what procedure you will call), thread index, maintains the indexes in dynamic arrays, hashes, and so on.   
It also contains temporary storage (3), so you can add things yourself to it.

In Jai, each procedure takes a context-based allocation scheme in which the memory allocator is implicitly passed to all procs (unless otherwise specified with #c_call). The context can be overloaded with a custom allocator: this allows memory management to be coordinated between the compiler and the developer.
You change the way memory is allocated by passing a different context to the function. 

See _25.1_context.jai_:
```c++
#import "Basic";

#add_context this_is_the_way := true;   // (1)

main :: () {
    str := "Hello, Sailor!";
    new_context: Context;               // (2)
    push_context new_context {          // (3)
        // Do things within this new context.
        push_allocator(temp);           // (4)
    }
    log(str);   // (5) => Hello, Sailor!
}
```

The directive **#add_context** adds a declaration to a context.

## 25.1 push_context

The current context can be assigned to a variable like in (2), and then when can use the `push_context` proc like in (3) to do something within this new context.

For example you could just declare an arena (see § ??) and use push_context to use it. All code in the push_context block now allocates with the arena, and you can free the arena memory whenever you want.

## 25.2 push_allocator
The `push_allocator` proc changes the allocator in the current context in the current scope.
After the current scope exits, the previous allocator is restored. 
For example: to temporarily switch-over to Temporary Storage, do:
`push_allocator(temp);`

## 25.3 What does **#no_context** mean?
A lot of procs like write_string and debug_break defined in preload are marked with this directive: it tells the compiler that this proc does not use the context. 

## 25.4 Logging
The `log()` proc used in line (5) formats a message, then sends it to context.logger (it automatically does a newline).
You can pass flags, a source_identifier and data gets copied from context.
Here is its signature:  
`log :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0)`


