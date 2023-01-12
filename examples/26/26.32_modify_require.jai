#import "Basic";

ModifyRequire :: (t: Type, kind: Type_Info_Tag) #expand {   // (1)
    `return (cast(*Type_Info)t).type == kind, tprint("T must be %", kind);
}

poly_proc :: (t: $T) #modify ModifyRequire(T, .ENUM) {}     // (2)

SomeEnum :: enum {
    ASD;
    DEF;
}

main :: () {
    poly_proc(SomeEnum.ASD);  // (3)
    // poly_proc(123); // (4)  Compile `Error: #modify returned false: T must be ENUM`
}