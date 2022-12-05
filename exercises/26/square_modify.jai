#import "Basic";

square :: (t : $T) -> T
#modify { return is_numeric_type(T); }
{ return t * t; }

is_numeric_type :: (T: Type) -> bool {
    ti := cast(*Type_Info) T;  
    if ti.type == .INTEGER  || ti.type == .FLOAT 
        return true;
    return false;
}; 

main :: () {
    print("%\n", square(5));     // => 25
    print("%\n", square(3.14));  // => 9.859601
    // print("%\n", square("Hello!"));  // => Error: #modify returned false.
}