#import "Basic";

Tag_Union :: struct(fields: [] string, types: []Type) {
  tag: Type;
  #insert -> string {
    builder: String_Builder;
    defer free_buffers(*builder);
    count := fields.count - 1;
    print_to_builder(*builder, "union {\n");
    for i: 0..count {
      print_to_builder(*builder, "  %1: %2;\n", fields[i], types[i]);
 
    }
    print_to_builder(*builder, "}\n");
    result := builder_to_string(*builder);
    return result;
  }
}

set :: (u: *$Tag/Tag_Union, value: $T) {        
  #insert -> string {
    count := u.fields.count - 1;
    for i: 0..count {
      if T == Tag.types[i] {
        code :: #string END
           u.tag = type_of(value);
           u.% = value;
        END
        return sprint(code, Tag.fields[i]);
      }
    }
    assert(false, "Invalid value: %\n", T);
  }
}

main :: () {
    fields :: string.["int_a", "float_b", "string_c"];
    types  :: Type.[int, float, string];

    tag_union: Tag_Union(fields, types); // (1)
    print("tag_union = %\n", tag_union); // => tag_union = {(null), (union)}
    set(*tag_union, 10);                 // (2A)
    print("tag_union = %\n", tag_union); // => tag_union = {s64, (union)}
    print("tag_union.int_a = % tag_union.tag = %\n", tag_union.int_a, tag_union.tag);

    set(*tag_union, 3.14);               // (2B)
    print("tag_union = %\n", tag_union); // => tag_union = {float32, (union)}
    print("tag_union.float_b = % tag_union.tag = %\n", tag_union.float_b, tag_union.tag);

    set(*tag_union, "James Bond");       // (2C)
    print("tag_union = %\n", tag_union); // => tag_union = {string, (union)}
    print("tag_union.string_c = % tag_union.tag = %\n", tag_union.string_c, tag_union.tag);

    // set(*tag_union, true);               // (2D)
    // => Assertion failed: Invalid value: bool
}

/*
tag_union = {s64, (union)}
tag_union.int_a = 10 tag_union.tag = s64
tag_union = {float32, (union)}
tag_union.float_b = 3.14 tag_union.tag = float32
tag_union = {string, (union)}
tag_union.string_c = James Bond tag_union.tag = string
*/