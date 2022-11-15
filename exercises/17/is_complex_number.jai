#import "Basic";

Complex :: struct { real, imag: float; }

is_complex_number :: (TC: *Type_Info) -> bool {
    if TC.type != .STRUCT return false;
    SC := cast(*Type_Info_Struct) TC;
    // print("%\n", SC.name); // => Complex
    if SC.name == "Complex" {
         return true;
    }
    return false;
}

main :: () {
    TC := cast(*Type_Info) Complex;
    // print("%\n", TC.type);  // => STRUCT
    c1 := Complex.{3.14, 42.7};
    print("c1 is of ");
    if is_complex_number(type_info(type_of(c1))) {
            print("type COMPLEX\n");
    } 
    // => c1 is of type COMPLEX
}
