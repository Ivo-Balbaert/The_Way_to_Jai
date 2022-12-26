#import "Basic";

code_to_string :: (code: Code) -> string #expand {
  PP       :: #import "Program_Print";
  Compiler :: #import "Compiler";
  code_node := Compiler.compiler_get_nodes(code);
  builder: String_Builder;
  PP.print_expression(*builder, code_node);
  return builder_to_string(*builder, allocator=temp);
}

#run {
    code1 := #code a_constant :: 10;
    str := code_to_string(code1);
    print("This is the code: % of type: %\n", str, type_of(str) );
    // => This is the code:  a_constant :: 10 of type: string
}

main ::() {}



