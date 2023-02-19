#import "Basic";
#import "Compiler";

factorial :: (x: int) -> int {
  if x <= 1 return 1;
  return x * factorial(x-1);
}
    
// function we're going to #run at compile-time
comptime_modify :: (code: Code) -> Code {
  // covert Code to AST nodes
  root, expressions := compiler_get_nodes(code);
  
  // walk AST
  // multiply number literals by their factorial
  // 3 -> 3*factorial(3) -> 3*6 -> 18
  for expr : expressions {
    if expr.kind == .LITERAL {
      literal := cast(*Code_Literal) expr;
      if literal.value_type == .NUMBER {
        // Compute factorial
        fac := factorial(literal._s64);
        
        // Modify node in place
        literal._s64 *= fac;
      }
    }
  }
  
  // convert modified nodes back to Code
  modified : Code = compiler_get_code(root);
  return modified;
}

// modify and duplicate code
do_stuff :: (code: Code) #expand {
  // modify the code at compile-time
  // new_code :: code;
  new_code :: #run comptime_modify(code);
  
  #insert new_code;
  #insert new_code;
  #insert new_code;
  #insert new_code;
}

x := 3;

main :: () {
    c :: #code { x *= 3; };
    do_stuff(c);

    // prints 3*18*18*18*18 = 314,928
    print("%\n", x); // => 314928
}