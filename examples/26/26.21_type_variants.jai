#import "Basic";
#import "Math";

Handle       :: #type,distinct u32;     // (1)
Filename     :: #type,isa string;       // (2A)
Velocity3    :: #type,isa Vector3;      // (2B)

main :: () {
    a: Handle = 5;      // (3)
    print("Math on a yields: %\n", 3 * a + 2);  // => Math on a yields: 17
    b: u32 = 42;
    // a = b;           // (3B) Error: Type mismatch. Type wanted: Handle; type given: u32.
    a = cast(Handle) b; // (3C) 
    a = xx (b + 1);     // (3D) 

    hi := type_info(Handle);
    print("%\n", hi);                    // (4) => Type
    ti := cast(*Type_Info) Handle;
    print("%\n", ti.type);               // (5) => VARIANT
    print("hi is %\n", <<hi.variant_of); // (5B) => hi is {INTEGER, 4}

    fn: Filename = "/home/var/usr/etc/dev/cake";
    f := type_info(Filename);
    print("f is %\n", <<f.variant_of); // (6) => f is {STRING, 16}

    va: Velocity3 = .{1,2,3};
    print("va has type %\n", type_of(va));  // => va has type Velocity3
    g := type_info(Velocity3);
    print("g is %\n", <<g.variant_of); // (7) => g is {STRUCT, 12}
}

/*

*/