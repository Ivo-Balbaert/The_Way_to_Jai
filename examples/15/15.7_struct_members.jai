#import "Basic";
#import "Math";

Person :: struct @Version9 {                  // (1)
    name            : string;
    age             : int;
    location        : Vector2;  @NoSerialize  // (2)
}

main :: ()  {
    pinfo := type_info(Person);
    print("Person notes: %\n", type_info(Person).notes);
    // => Person notes: ["Version9"]
    print("The struct has name: %\n", pinfo.name); 
    // => The struct has name: Person
    for pinfo.members {       // (3)
        print("% - ", it.name);  
        print("% - ", << it.type);
        print("% - ", (<< it.type).type);   
        print("% - ", type_to_string(it.type));  
        print("% - ", (<< it.type).runtime_size);  
        print("% - ", it.offset_in_bytes);
        print("% - ", it.notes);  // (4)
        print("% - \n", it.flags);  
    }
    print("\n");
    member, offset := get_field(pinfo, "age");  // (5)
    print("info age field: % and has offset %\n", << member, offset);
    print("\n");
}
/*
name - {STRING, 16} - STRING - string - 16 - 0 - [] - 0 -
age - {INTEGER, 8} - INTEGER - s64 - 8 - 16 - [] - 0 -
location - {STRUCT, 8} - STRUCT - Vector2 - 8 - 24 - ["NoSerialize"] - 0 - 

info age field: {name = "age"; type = 7ff6_5021_4000; offset_in_bytes = 16; 
flags = 0; notes = []; offset_into_constant_storage = 0; } and has offset 16

*/    