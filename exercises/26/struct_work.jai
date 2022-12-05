#import "Basic";
#import "String";

struct_work :: (x: $T)
#modify {
    ti := cast(*Type_Info) T;
    if ti.type != .STRUCT return false;

    tis := cast(*Type_Info_Struct) ti;
    return starts_with(tis.name, "XYZ"), "This proc only takes XYZs.";
} {
    // body of struct_work
}

XYZStruct :: struct {
    name:    string;
    address: string;
    favorite_fruits: [..] string;
}


SomethingElse :: struct {
    name: string;
    favorite_vegetables: [..] string;
}

main :: () {
    p: XYZStruct;
    struct_work(p);
    e: SomethingElse;
    // struct_work(e); // => Error: #modify returned false: This proc only takes XYZs.
}