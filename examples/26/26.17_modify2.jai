#import "Basic";

do_something :: (T: Type) -> bool {
    t := cast(*Type_Info) T;  
    if t.type == .INTEGER  return true;
    if t.type == .ENUM     return true;
    if t.type == .POINTER  return true;
    return false;
}

proc :: (dest: *$T, value: T)
#modify { return do_something(T); }
{     
    dest := value;
    print("dest is %", dest); // => dest is 42
}

main :: () {
    a : *int;
    proc(a, 42);   
}
