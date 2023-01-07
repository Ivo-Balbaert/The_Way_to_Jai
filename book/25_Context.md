# 25 Context

A central concept in Jai is the **context**.  
The context is specifically made to guide different parts of your program to use whatever services you desire. It helps programs and modules to coordinate, by establishing conventions they can use to perform various tasks.

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

The context is available at runtime and is globally known in the code. In most cases it will be contained completely in cache memory.
It contains memory allocation ((5)) (so it is also a common shared piece of memory), logging functionality (2), assertion handler (what procedure you will call on a failed assert), thread index, maintains the indexes in dynamic arrays, hashes, and so on.   
It also contains temporary storage (3), so you can add things yourself to it.

In Jai, each procedure takes a context-based allocation scheme in which the memory allocator is implicitly passed to all procs (unless otherwise specified with **#c_call**). The basic `alloc` procedure calls `context.allocator` to get its memory. The context can be overloaded with a custom allocator: this allows memory management to be coordinated between the compiler and the developer.
You change the way memory is allocated by passing a different context to the function. 

See *25.1_context.jai*:
```c++
#import "Basic";

#add_context this_is_the_way := true;   // (1)

my_allocator_proc :: (mode: Allocator_Mode, size: s64, old_size: s64, old_memory_pointer: *void, proc_data: *void) -> *void {
    // allocator specific code
    result := context.default_allocator.proc(mode, size, old_size, old_memory_pointer, proc_data);
    return result;
}                                                                   
main :: () {
    str := "Hello, Sailor!";
    print("The context is %\n", context); // => see below between /* */
    
    new_context: Context;               // (2)
    new_context.allocator.proc = my_allocator_proc; // (2B)
    new_context.allocator.data = null;  

    push_context new_context {          // (3)
        // Do things within this new context.
        push_allocator(temp);           // (4)
    } // (4B)
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

In the same way, you can plug in your own assertion_handler and logger (see modules/Basic/examples/basic.jai)

The directive **#add_context** adds a declaration to a context.

## 25.1 push_context
The current context can be assigned to a variable like in (2). If you want you can change the procedure used for allocating memory, like in line (2B). Then we can use the `push_context` proc like in (3) to do something within this new context. `push_context lets you push an entire fresh Context.

For example you could just declare a memory arena (see § ??) and use push_context to use it. All code in the push_context block now allocates with the arena, and you can free the arena memory whenever you want.  
The new context stops after the closing } (line (4B)), and the initial context is restored.

## 25.2 push_allocator
The `push_allocator` macro changes the allocator in the current context in the current scope.
After the current scope exits, the previous allocator is restored. 
For example: to temporarily switch-over to Temporary Storage, do:
`push_allocator(temp);` as done in line (4). This is especially useful in a `push_context` block, but it can be done always. 

## 25.3 What does **#no_context** mean?
A lot of procs like write_string() and debug_break() defined in _Preload_ are marked with this directive: it tells the compiler that this proc does not use the context. 

## 25.4 Logging
The `log()` proc from module _Basic_ used in line (5) formats a message, then sends it to `context.logger` (it automatically does a newline).
You can pass flags, a source_identifier and data gets copied from context.
Here is its signature:  
`log :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0)`
Log_Flags is an enum defined in module _Preload_

A full example of defining and using a custom logger can be found in howto/350_logging.

## 25.5 Temporary storage
Back in § 21.3.3 we saw that Temporary storage characteristics are stored in the context, namely in `context.temporary_storage`  
In line (6) we print out a number of its properties: its size = 32 Kb,

## 25.6 The stack trace
In line (4) of the code of `Context_Base`, we see a field called `stack_trace`. What is its purpose?  
The stack trace is also called the program's **function call stack**, which is a better description, namely: it is a report of the active stack frames at a certain point in time during the execution of a program. It works cross-platform and contains a logging of all function calls, and where they occurred in the program. You'll often see stack traces in the output of program crashes, and they are used for debugging purposes.

See *25.2_stack_trace.jai*:
```c++
#import "Basic";

my_print_stack_trace :: (node: *Stack_Trace_Node) {     // (1)
    while node {
        if node.info {
        print("[%] at %:%. call depth %  hash 0x%\n", 
                        node.info.name, 
                        node.info.location.fully_pathed_filename, 
                        node.line_number, 
                        node.call_depth,
                        formatInt(node.hash, base=16));
        }
        node = node.next;
    }
}

proc1 :: (x: int) {         // (2)
    print("x is %\n", x);
    if x < 1 { 
        my_print_stack_trace(context.stack_trace);   // (2B)  
        // print_stack_trace(context.stack_trace);         // (2C)  
    }  
    else     {  proc1(x - 1); }
}

main :: () {
    proc1(3);               // (3)
}

/*
/* Calling line 2B: */
x is 3
x is 2
x is 1
x is 0
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:21. call depth 4
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:21. call depth 3
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:21. call depth 2
[main] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:25. call depth 1

/* Calling line 2C: */
x is 3
x is 2
x is 1
x is 0
'proc1' at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:22
'proc1' at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:22
'proc1' at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:22
'main' at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:26

/* with my_print_stack_trace: */
x is 3
x is 2
x is 1
x is 0
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:23. call depth 4  hash 0xb15659a3b1256905
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:23. call depth 3  hash 0x7f4c4427a7efb165
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:23. call depth 2  hash 0xda2a148d41461045
[main] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:27. call depth 1  hash 0xc1d0f3c6d9994ba5
*/
```

_25.2_stack_trace.jai* is an example of an example of a recursive procedure `proc1` (see line (2)), that calls itself 3 times, starting in line (3). When x gets the value 0, the proc `my_print_stack_trace` from line (1) is called, with the active `context.stack_trace` as argument. This iterates through the nodes of the stack trace, until node becomes `null`. When there is info, we print the procedure's name, the source file and line number where it is called, and the call depth, that is: how 'deep' the recursion is.  

This info is so useful that there is in fact a proc `print_stack_trace` in module _Basic_, which is almost identical and which we call in line (2C).

You can also get the address of the current proc through: `context.stack_trace.info.procedure_address`.  
There is also a proc called `pack_stack_trace()`, which makes a copy of the stack trace that you can store on a data structure for further examination/processing.

In § 30.4.5 we'll see that there is also a compile option called `build_options.stack_trace`, which is by default true to examine stack traces on program errors/crashes. With this option enabled, every time a procedure is called, code is generated to output a Stack_Trace_Node on the stack and link it up, and unlink it when the procedure returns. Use it as an aid in debugging if necessary.

Stack traces are useful for writing instrumentation code such as a profiler or memory debugger. `Stack_Trace_Node` and related code are defined in module _Preload_.


## 25.7 The print style
See *25.3_print_style.jai*:
```c++
#import "Basic";

main :: () {
    NUMBERS :: u32.[1, 69105, 1491625];
    
    new_context := context;
    push_context new_context {  
        format_int := *context.print_style.default_format_int;  // (1)
        // default is:  format_int.base = 10;
        for NUMBERS print("% / ", it); // => 1 / 69105 / 1491625 / 
        print("\n");
        format_int.base = 16;          // (2)
        for NUMBERS print("% / ", it); // => 1 / 10df1 / 16c2a9 /
        print("\n");
        format_int.base = 2;
        for NUMBERS print("% /", it); // => 1 /10000110111110001 /101101100001010101001 /
    }
    print("\n");
    for NUMBERS print("% /", it); // (3) => 1 / 69105 / 1491625 / 
}
```

Context also contains a member called `print_style`, which contains default Formatters (see § 6.2.8) that are used in combination with `print`. Print_Style is a struct defined in _Basic/Print.jai_ and, and a variable `print_style` pointing to it is added to the Context.  
In line (1) we take the `default_format_int` from the Context. In lines (2) and following we change the number base, and print some numbers out with that base in the new context working in a `push_context` block. As we see in line (3), once we leave that block we return to the normal defaults.
Analogous things can be done for formatting floats, structs and arrays in a specific context.