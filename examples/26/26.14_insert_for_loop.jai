#import "Basic";

unroll_for_loop :: (a: int, b: int, body: Code) #expand {
  #insert -> string {
    builder: String_Builder;
    print_to_builder(*builder, "{\n");
    print_to_builder(*builder, "`it: int;\n");
    for i: a..b {
      print_to_builder(*builder, "it = %;\n", i);
      print_to_builder(*builder, "#insert body;\n");  // (1)
    }
    print_to_builder(*builder, "}\n");
    return builder_to_string(*builder);
  }
}

main ::() {
  unroll_for_loop(0, 10, #code {
    print("% - ", it); // => 0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 
  });

}