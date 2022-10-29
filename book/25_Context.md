# 25 Context

A central concept in Jai is the **context**.

The `context` struct is defined in module _Preload_ as:  
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

In Jai, each procedure takes a context-based allocation scheme in which the memory allocator is implicitly passed to all procs (unless otherwise specified with **#c_call**). The context can be overloaded with a custom allocator: this allows memory management to be coordinated between the compiler and the developer.
You change the way memory is allocated by passing a different context to the function. 

See _25.1_context.jai_:
```c++
#import "Basic";

#add_context this_is_the_way := true;   // (1)

main :: () {
    str := "Hello, Sailor!";
    print("The context is %\n", context); // => see below between /* */
    
    new_context: Context;               // (2)
    push_context new_context {          // (3)
        // Do things within this new context.
        push_allocator(temp);           // (4)
    }
    log(str);   // (5) => Hello, Sailor!

    print("Temp storage is %\n", context.temporary_storage); 
    // => Temp storage is 7ff7_b9b3_b000
    print("Temp storage is %\n", <<context.temporary_storage);  // (6)
    /* Temp storage is {data = 7ff6_5ef1_c080; size = 32768; occupied = 88; 
    high_water_mark = 88; overflow_allocator = {procedure 0x7ff6_5eee_8a50, null}; 
    overflow_pages = null; original_data = 7ff6_5ef1_c080; original_size = 32768; }
    */    

}
/*
The context is {{thread_index = 0; allocator = {procedure 0x7ff7_cb40_6420, null}; 
logger = procedure 0x7ff7_cb40_bbb0; logger_data = null; log_source_identifier = 0; 
log_level = NORMAL; temporary_storage = 7ff7_cb43_b000; 
dynamic_entries = [{(null), null}, {(null), null}, {(null), null}, {(null), null}, 
{(null), null}, {(null), null}, {(null), null}, {(null), null}, {(null), null}, 
{(null), null}, {(null), null}, {(null), null}, {(null), null}, {(null), null}, 
{(null), null}, {(null), null}]; num_dynamic_entries = 0; 
stack_trace = af_21af_cf40; assertion_failed = procedure 0x7ff7_cb41_2ea0; 
handling_assertion_failure = false; }, 
{default_format_int = {formatter = {(zero-initialized Any)}; base = 10; 
minimum_digits = 1; padding = 48; digits_per_comma = 0; comma_string = ""; }; 
default_format_float = {{(zero-initialized Any)}, -1, -1, YES, DECIMAL}; 
default_format_struct = {formatter = {(zero-initialized Any)}; 
draw_type_name = false; use_long_form_if_more_than_this_many_members = 5; 
separator_between_name_and_value = " = "; short_form_separator_between_fields = ", "; 
long_form_separator_between_fields = "; "; begin_string = "{"; end_string = "}"; 
indentation_width = 4; use_newlines_if_long_form = false; }; 
default_format_array = {formatter = {(zero-initialized Any)}; separator = ", "; 
begin_string = "["; end_string = "]"; printing_stopped_early_string = "..."; 
draw_separator_after_last_element = false; stop_printing_after_this_many_elements = 100; }; 
default_format_absolute_pointer = {formatter = {(zero-initialized Any)}; 
base = 16; minimum_digits = 1; padding = 48; digits_per_comma = 4; comma_string = "_"; }; 
indentation_depth = 2; log_runtime_errors = true; }, true}
*/
```

The directive **#add_context** adds a declaration to a context.

## 25.1 push_context

The current context can be assigned to a variable like in (2), and then when can use the `push_context` proc like in (3) to do something within this new context.

For example you could just declare a memory arena (see § ??) and use push_context to use it. All code in the push_context block now allocates with the arena, and you can free the arena memory whenever you want.

## 25.2 push_allocator
The `push_allocator` proc changes the allocator in the current context in the current scope.
After the current scope exits, the previous allocator is restored. 
For example: to temporarily switch-over to Temporary Storage, do:
`push_allocator(temp);`

## 25.3 What does **#no_context** mean?
A lot of procs like write_string() and debug_break() defined in _Preload_ are marked with this directive: it tells the compiler that this proc does not use the context. 

## 25.4 Logging
The `log()` proc used in line (5) formats a message, then sends it to `context.logger` (it automatically does a newline).
You can pass flags, a source_identifier and data gets copied from context.
Here is its signature:  
`log :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0)`

## 25.5 Temporary storage
Back in § 21.3.3 we saw that Temporary storage characteristics are stored in the context, namely in `context.temporary_storage`  
In line (6) we print out a number of its properties: its size = 32 Kb,
