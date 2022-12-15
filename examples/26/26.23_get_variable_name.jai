#import "Compiler";
#import "Program_Print";
#import "Basic";

get_variable_name :: (thing: int, call := #caller_code) -> string #expand {
    node := cast(*Code_Procedure_Call) compiler_get_nodes(call);
    builder: String_Builder;
    print_expression(*builder, node.arguments_unsorted[0].expression);
    return builder_to_string(*builder);
}

main :: () {
    a_variable :: 10;
    #run print("%", get_variable_name(a_variable)); // => a_variable
}