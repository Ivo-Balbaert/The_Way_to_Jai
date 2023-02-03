#import "Basic";
#import "Math";

main :: () {
    // type_info():
    typ1 := << type_info(float64); // (3)
    print("Type info of float64 is %\n", typ1); // => Type info of float64 is {{FLOAT, 8}}
    print("The type of typ1 is %\n", typ1.type); // => The type of typ1 is FLOAT
   
    print("%", type_info(Any).type); // => ANY

    // a variable can also contain a composite type:
    var := Vector3;             // (1)
    print("The value of var is %, and it is of type %\n", var, type_of(var)); 
    // => The value of var is Vector3 and it is of type Type

    ti := type_info(Vector3);      // (2)
    print("Type of ti is: %\n", type_of(ti)); // => Type of infor is: *Type_Info_Struct
    for member: ti.members      print("% - ", member.name);       // (2B)
    // => x - y - z - xy - yz - component -

    print("\n");
    z_info :=  get_field(type_info(Vector3), "z");   // (3)
    print("Type_Info_Struct_Member for z: %\n", <<z_info);
    // => Type_Info_Struct_Member for z: {name = "z"; 
    // type = 7ff7_1e05_1b18; offset_in_bytes = 8; flags = 0; notes = []; offset_into_constant_storage = 0; }

    typ2 := << type_info(Vector3);      // (4)
    print("Type info of Vector3 is %\n", typ2); // => 
    // => Type info of Vector3 is {info = {STRUCT, 12}; name = "Vector3"; 
    // specified_parameters = []; members = [{name = "x"; type = 7ff6_21db_41b0; offset_in_bytes = 0; 
    // flags = 0; notes = []; offset_into_constant_storage = 0; }, 
    // {name = "y"; type = 7ff6_21db_41b0; offset_in_bytes = 4; flags = 0; notes = []; 
    // offset_into_constant_storage = 0; }, 
    // {name = "z"; type = 7ff6_21db_41b0; offset_in_bytes = 8; flags = 0; notes = []; 
    // offset_into_constant_storage = 0; }]; status_flags = 0; nontextual_flags = 0; 
    // textual_flags = 0; polymorph_source_struct = null; initializer = null; 
    // constant_storage_size = 0; constant_storage_buffer = null; }
    print("The type of typ2 is %\n", typ2.type); // => The type of typ2 is STRUCT
    tis := << cast(*Type_Info_Struct) Vector3;   // (5)
    print("Info from tis: %\n", tis);
    // => Info from tis: {info = {STRUCT, 12}; name = "Vector3"; ...
}