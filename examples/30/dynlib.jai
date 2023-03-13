#import "Basic";

#program_export dll_func :: () #c_call {
    new_context: Context;  
    push_context new_context {
        print("Hello Sailor");
    }
}