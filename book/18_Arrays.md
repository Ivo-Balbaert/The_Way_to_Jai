# Chapter 18 - Arrays




## 18. Variable number of arguments ..
See _18.5_var_args.jai_:

```c++
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

main :: () {
    var_args(1, 2, 3, 4, 5, 6, 7); // (5)
    proc1("Hello", "John", "Gertrude", "Olaf", 42);
    // => John - Gertrude - Olaf - 42 -

  	arr := int.[1, 2, 3, 4, 5, 6, 7]; // (6A) 
  	var_args(..arr);        // (6B) 
  	var_args(args = ..arr); // same as line above
}
```

A variable number of arguments for a procedure can be specified  in the proc header's parameter-list with `..` like in line (1).  
In general:  `(arg1 = type1, arg2 = type2, ..., args: ..type )`  
Use a normal parameter list to pass arguments to a variable arguments function, as in line (5).
Printing out the args argument in line (1B), we see that it is in fact an array: all variable arguments are stored in an array, here with type [] s64.  

The definition above seems to imply that all variable arguments have to be of the same type. You can specify this, but you can also use the Any type as in line (3):  `args: ..Any`  
so that in fact any type is allowed.  

In order to avoid ambiguity, the variable number argument must be the last in the argument list.

Because args is an array, the exact number of arguments is given by `args.count` (line(2)) and you can loop over them with `for args` (line(4)).

### 18.1 Passing an array as a variable argument
In line (6B) we pass the array arr defined in line (6A) to proc var_args like this:  
`var_args(..arr);` or `var_args(args = ..arr);`
This is in fact the same as calling `var_args(1,2,3,4,5,6,7);`; we say that the array items are _spread_ over args.

### 18.2 Named variable arguments proc
A named variable and (some) default arguments proc would be defined like:
`varargs_proc :: (s:= "Fred", f:= 2.5, v: ..string) { }`

called as for example in line (7A):
`varargs_proc(f = 3.14, s = "How", v = "are", "you", "tonight?");`

After the varargs name v is used, all parameters are going into the variable argument.
You can spread parameters with a name as well as in line (7B): 
`varargs_proc(f = 5, 3.14 = "How", v = ..array);`

### 18.3 The print procedure uses ..
See _18.6_print_proc.jai_:

```c++
#import "Basic";

main :: () {
    x, y, z, w := 1, 2, 3, 4;
    print("Hello!\n"); // (1) => Hello!
    print("x=%\n", x); // => x=1
    print("x=%, y=%, z=%, w=%\n", x, y, z, w); // => x=1, y=2, z=3, w=4
}
```

In the above example as well as in § 5.7, we see that `print` can accept a variable number of arguments.
This is because `print` is defined in module _Basic_ file _Print.jai_ as:  
`print :: (format_string: string, args: .. Any, to_standard_error := false) -> bytes_printed: s64 {...}` 

We see it has a variable number argument `args`, which makes this possible.


