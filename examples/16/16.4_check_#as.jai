#import "Basic";
#import "Math";

Thing1 :: struct {
    using #as v: Vector3;
    name: string;
}

Other :: struct {
    y:           float;
    temperature: float64;
    time:        Apollo_Time;
    x:           float;
}

uses_vector3_with_as :: (T: Type) -> bool {    // (6)
    ti := cast(*Type_Info) T;
    if ti.type != .STRUCT return false;

    tis := cast(*Type_Info_Struct) ti;
    for tis.members {
        if !(it.flags & .AS)             continue;
        if it.type != type_info(Vector3) continue;
        // We found a relevant member!
        return true;
    }
    return false;
}

main :: () {
    // Checking whether a struct uses Vector3 with #as
    print("Other uses #as with Vector3: %\n", uses_vector3_with_as(Other));   
    // => "Other uses #as with Vector3: false 
    print("Thing1 uses #as with Vector3: %\n", uses_vector3_with_as(Thing1)); 
    // => Thing1 uses #as with Vector3: true
}