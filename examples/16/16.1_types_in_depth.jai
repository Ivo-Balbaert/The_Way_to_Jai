#import "Basic";
#import "Math";

Complex :: struct { real, imag: float; }

Operating_Systems :: enum u16 #specified {
        VMS      :: 1;
        ATT_UNIX :: 2;
        WINDOWS  :: 3;
        GNU_SLASH_LINUX :: 4;
}

Direction :: enum {
    NORTH;      
    SOUTH;      
    EAST;      
    WEST;         
}

Thing1 :: struct {
    #as using v: Vector3;
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
    // a variable can also contain a composite type:
    var := Vector3;
    print("% is of type %\n", var, type_of(var)); // => Vector3 is of type Type

    n : s32 = 5;
    a: Any = n;
    print("a's Type_Info is: %\n", << a.type); // (1) => a's Type_Info is: {INTEGER, 4}
    print("a's type is: %\n", a.type.type); // => a's type is: INTEGER
    print("a's value_pointer is: %\n", a.value_pointer); // => c3_2d9c_f844
    print("The value inside a's value_pointer is: %\n", << cast(*s32) a.value_pointer); 
    // => The value inside a's value_pointer is: 5

    if a.type.type == Type_Info_Tag.FLOAT // (2)
        print("a is a float\n");
    else if a.type.type == Type_Info_Tag.INTEGER
        print("a is an int\n"); // => a is an int

    infor := type_info(Vector3);
    print("Type of infor is: %\n", type_of(infor)); // => Type of infor is: *Type_Info_Struct
    for member: infor.members {   // (2B)
        print("%\n", member.name); // => x, y, z
    }
    print("\n");

    // type_info():
    typ1 := << type_info(float64); // (3)
    print("Type info of float64 is %\n", typ1); // => Type info of float64 is {{FLOAT, 8}}
    print("The type of typ1 is %\n", typ1.type); // => The type of typ1 is FLOAT

    typ2 := << type_info(Vector3);
    print("Type info of Vector3 is %\n", typ2); // => 
    // Type info of Vector3 is {info = {STRUCT, 12}; name = "Vector3"; 
    // specified_parameters = []; members = [{name = "x"; type = 7ff6_21db_41b0; offset_in_bytes = 0; 
    // flags = 0; notes = []; offset_into_constant_storage = 0; }, 
    // {name = "y"; type = 7ff6_21db_41b0; offset_in_bytes = 4; flags = 0; notes = []; 
    // offset_into_constant_storage = 0; }, 
    // {name = "z"; type = 7ff6_21db_41b0; offset_in_bytes = 8; flags = 0; notes = []; 
    // offset_into_constant_storage = 0; }]; status_flags = 0; nontextual_flags = 0; 
    // textual_flags = 0; polymorph_source_struct = null; initializer = null; 
    // constant_storage_size = 0; constant_storage_buffer = null; }
    print("The type of typ2 is %\n", typ2.type); // => The type of typ2 is STRUCT

    // (4) without using type_info():
    c1 := Complex.{3.14, 42.7};
    print("c1 is: % and has type %\n", c1, type_of(c1)); 
    // => c1 is: {3.14, 42.700001} and has type Complex
    TC := cast(*Type_Info) Complex;
    print("%\n", TC.type);  // => STRUCT
    if TC.type != .STRUCT then exit;
    SC := cast(*Type_Info_Struct) TC;
    print("%\n", SC.name); // => Complex
    if SC.name == "Complex" then print("This is type COMPLEX\n"); // => This is type COMPLEX
    print("c1 is of type: ");
    print("%\n", (cast(*Type_Info_Struct) type_of(c1)).name);
    // => c1 is of type: Complex

    info := type_info(Direction); // (5) this is a *Type_Info_Enum
    print("enum '%' is ", info.name); // => enum 'Direction' is
    if info.enum_type_flags & .SPECIFIED    print("specified.\n");
    else print("*NOT* specified.\n");       // => *NOT* specified.
    
    info = type_info(Operating_Systems); 
    print("enum '%' is ", info.name); // => enum 'Operating_Systems' is .
    if info.enum_type_flags & .SPECIFIED    print("specified.\n"); // => specified
    else print("*NOT* specified.\n");

    // (7) Checking whether a struct uses Vector3 with #as
    print("Thing1 uses #as with Vector3: %\n", uses_vector3_with_as(Thing1)); 
    // => Thing1 uses #as with Vector3: true
    print("Other uses #as with Vector3: %\n", uses_vector3_with_as(Other));   
    // => false 
    print("The type of main is %\n", type_of(main));  // (8)
    // => The type of main is procedure ()
}