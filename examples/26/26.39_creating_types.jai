#import "Basic";

create_code_for_each_type :: (code: Code, $types: ..Type) #expand {
  #insert -> string {
    builder: String_Builder;
    for types {
      print_to_builder(*builder, "{\n");
      print_to_builder(*builder, "  T :: %1;\n", it);
      print_to_builder(*builder, "  #insert, scope() code;\n");
      print_to_builder(*builder, "}\n");
    }
    return builder_to_string(*builder);
  }
}

main :: () {
  // this code snippet creates a variable of type T, and prints its (default) value
  snippet :: #code {
    t: T;
    print("value: '%'\n", t);
  };

  create_code_for_each_type(snippet, float32, bool, int, string);
}

/*
value: '0'
value: 'false'
value: '0'
value: ''
*/