#import "Basic";

#add_context this_is_the_way := true;   // (1)

my_allocator_proc :: (mode: Allocator_Mode, size: s64, old_size: s64, old_memory_pointer: *void, proc_data: *void) -> *void {
    // allocator specific code
    result := context.default_allocator.proc(mode, size, old_size, old_memory_pointer, proc_data);
    return result;
}

main :: () {
    str := "Hello, Sailor!";
//    print("The context is %\n", context); // => see below between /* */

    new_context: Context;               // (2)
    new_context.allocator.proc = my_allocator_proc; // (2B)
    new_context.allocator.data = null;  

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
