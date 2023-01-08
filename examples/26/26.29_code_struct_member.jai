#import "Basic";

for_each_member :: ($T: Type, format: string) -> string
{
    builder: String_Builder;
    defer free_buffers(*builder);

    struct_info := cast(*Type_Info_Struct) T;
    assert(struct_info.type == Type_Info_Tag.STRUCT);

    for struct_info.members 
    {
        if it.flags & .CONSTANT continue;
        print_to_builder(*builder, format, it.name);
    }

    return builder_to_string(*builder);
}

serialize_structure :: (s: $T, builder: *String_Builder) -> success: bool
{
    #insert #run for_each_member(T, "if !serialize(s.%1, builder) return false;\n" );  // (1)
    // %1          = member name;  type_of(%1) = member type
    // The following code will be inserted before compiling (see .build/.added_strings_w2.jai)
    // if !serialize(s.status, builder) return false;
    // if !serialize(s.health, builder) return false;
    return true;
}

serialize  :: (to_serialize: $T, builder: *String_Builder) -> success: bool { 
    print_to_builder(builder, "%-", to_serialize);
    return true; 
} 

main :: ()
{
    Player :: struct
    {
        status: u16;
        health: int;
    }
    p := Player.{7, 75};
    
    builder: String_Builder;
    defer free_buffers(*builder);

    success := serialize_structure(p, *builder);
    if !success { 
        print("Serializing error");
        exit(-1);
    }
    str := builder_to_string(*builder);
    print("The result of serializing is: '%'.\n", str);
    // => The result of serializing is: '7-75-'.
}

// .build/.added_strings_w2.jai contains:
// Workspace: Target Program
//
// #insert text. Generated from d:/Jai/testing/test2.jai:25.
//
/*
if !serialize(s.status, builder) return false;
if !serialize(s.health, builder) return false;
*/

