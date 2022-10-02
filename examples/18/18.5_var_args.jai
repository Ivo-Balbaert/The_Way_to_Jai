#import "Basic";

var_args :: (args: ..int) {  // (1)
  print("args = %\n", args); // (1B) => args = [1, 2, 3, 4, 5, 6, 7]
  print("The type of args is %\n", type_of(args));  // (1C) 
  // => The type of args is [] s64
  print("The number of variable arguments is %\n", args.count);  // (2)
  // => The number of variable arguments is 7
}

proc1 :: (s: string, args: ..Any) {  // (3)
    print(" s is %\n", s);           // => s is "Hello"
    for args {                       // (4)
        print("% - ", it);
    }
}

varargs_proc :: (s:= "Fred", f:= 2.5, v: ..string) { // (4B)
    print("v is %\n", v); // => v is ["are", "you", "tonight?"]

}


main :: () {
    var_args(1, 2, 3, 4, 5, 6, 7); // (5)
    proc1("Hello", "John", "Gertrude", "Olaf", 42);
    // => John - Gertrude - Olaf - 42 -

  	arr := int.[1, 2, 3, 4, 5, 6, 7]; // (6A) 
  	var_args(..arr);        // (6B) 
  	var_args(args = ..arr); // same as line above

    varargs_proc(f = 3.14, s = "How", v = "are", "you", "tonight?"); // (7A)
    arrs := string.["are", "you", "tonight?"];
    varargs_proc(f = 5, s = "How", v = ..arrs); // (7B)
}