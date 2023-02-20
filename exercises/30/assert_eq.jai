#import "Basic";

factorial :: (x: int) -> int {
  if x <= 1 return 1;
  return x * factorial(x-1);
}

code_to_string :: (code: Code) -> string #expand {
  PP       :: #import "Program_Print";
  Compiler :: #import "Compiler";
  code_node := Compiler.compiler_get_nodes(code);
  builder: String_Builder;
  PP.print_expression(*builder, code_node);
  return builder_to_string(*builder, allocator=temp);
}

assert_eq :: (a: Code, b: Code) #expand {
  sa := #run code_to_string(a);
  va := #insert a;
  
  sb := #run code_to_string(b);
  vb := #insert b;
  assert(va == vb, 
    "(left == right)\n  left: %  expr: %\n  right: %  expr: %\n  loc: %\n",
    va, sa, vb, sb,
    #location(a));
}

main :: () {
    assert_eq(42, factorial(3));
}

/*
d:/Jai/testing/assert_eq.jai:23,3: Assertion failed: (left == right)
  left: 42  expr: 42
  right: 6  expr: factorial(3)
  loc: {"d:/Jai/testing/assert_eq.jai", 30, 15}


Stack trace:
c:/jai/modules/Preload.jai:384: default_assertion_failed        
c:/jai/modules/Basic/module.jai:83: assert
d:/Jai/testing/assert_eq.jai:23: main
A breakpoint was hit, but no debugger is attached.
*/