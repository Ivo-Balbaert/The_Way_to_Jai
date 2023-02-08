#import "Basic";

FooStruct :: struct { value: int; }
BazStruct :: struct { value: int; }

submit_data :: (data: $T)    
#modify {
    ti := cast(*Type_Info) T;
    if ti.type == .ARRAY { 
        return false, "This overload is for non-arrays; use the array overload instead.";
    }
    return true;
} 
{   print("Inside the non-array overload.\n"); }

submit_data :: (data: [] $T) 
{   print("Inside the array overload.\n");     }

main :: () {
    submit_data(FooStruct.{ value = 123 });
    // => Inside the non-array overload.

    u8_arr: [] u8;
    submit_data(u8_arr);
    // => Inside the array overload.

    baz_arr: [] BazStruct;
    submit_data(baz_arr);
    // => Inside the array overload.
}

