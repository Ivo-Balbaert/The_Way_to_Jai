#import "Basic";
#import "Math";

Person :: struct @Version9 {                  // (1)
    name            : string;
    age             : int;
    location        : Vector2;  @NoSerialize  // (2)
}

main :: ()  {
    pinfo := type_info(Person);
    print("The struct has name: %\n", (<<pinfo).name); 
    // => The struct has name: Person
    for member: pinfo.members {       // (3)
        print("% - ", member.name);  
        print("% - ", << member.type);  
        print("% - ", (<< member.type).runtime_size);  
        print("% - ", member.offset_in_bytes);
        print("% - ", member.notes);  // (4)
        print("% - \n", member.flags);  
    }
    print("\n");
    member, offset := get_field(pinfo, "age");  // (5)
    print("info age field: % and has offset %\n", << member, offset);
    print("\n");
}
/*
name - {STRING, 16} - 16 - 0 - [] - 0 -
age - {INTEGER, 8} - 8 - 16 - [] - 0 -
location - {STRUCT, 8} - 8 - 24 - ["NoSerialize"] - 0 -

info age field: {name = "age"; type = 7ff6_5021_4000; offset_in_bytes = 16; 
flags = 0; notes = []; offset_into_constant_storage = 0; } and has offset 16

*/    