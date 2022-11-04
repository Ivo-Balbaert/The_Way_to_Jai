# import "Basic";
# import "Compiler";
# import "Program_Print";                   // (1)

code :: #code a := Vector3.{1,2,3};

#run {
    builder: String_Builder;
    root, exprs := compiler_get_nodes(code);  // (2)
    print_expression(*builder, root);         // (3)
    s := builder_to_string(*builder);
    print("The code is: %\n", s);
    print("Here are the types of all expressions in this syntax tree:\n");
    for expr, i: exprs {                      // (4)
        print("[%] % %\n", i, expr.kind, expr.node_flags);
    }
}

main :: () {}

/* => during compile-time
The code is: a := Vector3.{1, 2, 3}
Here are the types of all expressions in this syntax tree:
[0] IDENT 0
[1] TYPE_INSTANTIATION 0
[2] LITERAL 0
[3] LITERAL 0
[4] LITERAL 0
[5] LITERAL 0
[6] DECLARATION ALLOWED_BY_CONTEXT
*/

