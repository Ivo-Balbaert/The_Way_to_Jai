# 26C Applications of Metaprogramming


## 26.10 SOA (Struct of Arrays)
SOA is a special kind of data-design, which makes memory-use much faster, and so enhances performance.
It is done at compile-time using `#insert`. This mechanism automatically converts between SOA (Structure of Arrays) and AOS (Array of Structures), without breaking the supporting code. This means a completely different memory access pattern, and it allows for quickly changing data layouts with minor code edits.

### 26.10.1 Data-oriented design
Jai provides built-in support for data-oriented development: it’s a high-level language build for fast memory support. Good memory layout is important because if it is not well done, too many memory cache misses will occur, alongside too much allocator overhead. Moreover consoles and mobile devices tend to have more limited memory constraints. Jai helps you to set up things in memory the way you want, without loss of efficiency or high-level expressiveness.

### 26.10.2 Making a SOA struct using #insert
For some arrays we can get much better cache performance by changing the order of data. C++ encourages the use of arrays of structures (AOS), but most CPUs work faster when data is laid oud as structures of arrays (SOA). Object-oriented languages prefer AOS, but a data-oriented language should make it easy to lay out your data in SOA format.
With SOA, arrays are contiguous in memory, and even their member values are contiguous, instead of being scattered on the heap.

For example: updating a set of arrays usually happens coordinate by coordinate, first all x coordinates, and so on. Because in the SOA structure all the vector coordinates are adjacent to each other in memory, updates on them are very fast. This is in contrast with an AOS structure, where updates will have to jump over memory all the time.

> There are two different ways of storing data here:
> Array of Structs:(AOS)  A list of objects (like marines) where objects are stored one after another.
> Struct of Arrays: (SOA) An object that contains lists of fields, so similar fields are stored together.  
> 
This is marvelously explained in the following article [SOA vs AOS](https://www.shamusyoung.com/twentysidedtale/?p=48683), which is part of a brilliant series of articles about game programming.

Suppose our program works with `Vec3 :: { x: float, y: float, z: float }` (defined in module _Math_).
An AOS with Vec3's would be like `[vec31, vec32, vec33, vec34, vec35]`, where vec31: Vec3, and so on, so basically: `[{x1, y1, z1}, {x2, y2, z2}, {x3, y3, z3}, {x4, y4, z4}, {x5, y5, z5}]`  

An SOA Vec3 struct would be like:  
```c++
    SOA_Vec3 :: struct {
       x: [5] float;
       y: [5] float;
       z: [5] float;
     }
```
Accessing all x's and so on will be much faster in the SOA configuration.

Now we discuss an example of how SOA is implemented in Jai as a polymorphic struct with #insert.

See *26.10_soa.jai*:
```c++
#import "Basic";

Person :: struct {                      // (1)
  name: string;
  age: int;
  is_cool: bool;
}

SOA :: struct(T: Type, count: int) {    // (2)
  #insert -> string {                   // (3)
    builder: String_Builder;            // (4)
    defer free_buffers(*builder);
    t_info := type_info(T);             // (5)
    for fields: t_info.members {        // (6)
      print_to_builder(*builder, "  %1: [%2] type_of(T.%1);\n", fields.name, count);  // (7)
    }
    result := builder_to_string(*builder);  // (8)
    return result;
  }
}

main :: () {
  soa_person: SOA(Person, 5);       // (9)
  print("soa_person is: %\n", soa_person);
  for i: 0..soa_person.count-1 {    // (10)
    print("Person[%]: name= %, age= %, is_cool= %\n", i, soa_person.name[i], 
    soa_person.age[i], soa_person.is_cool[i]);
  } // => see in /* */ after program
  print("soa_person is: %\n", soa_person);
  // => soa_person is: {["", "", "", "", ""], [0, 0, 0, 0, 0], [false, false, false, false, false]}

  // an aos example:
  // if you do: arrp := Person.[p1, p2, p3, p4, p5] , with for example: p1 := Person.{"Ivo", 66, true};
  // => Error: Attempt to use a non-literal element inside an array literal! (At index 4.)
  arrp := Person.[Person.{"Ivo", 66, true}, Person.{"Dolf", 42, false}, Person.{"Laura", 28, true}, 
                Person.{"Gabriel", 30, true}, Person.{"Denise", 63, false}];   // (11)
  // how to transform aos to soa: arrp --> soa_person
  for arrp {       // (12)
    soa_person.name[it_index] = it.name;
    soa_person.age[it_index] = it.age;
    soa_person.is_cool[it_index] = it.is_cool;
  }
  print("soa_person is: %", soa_person);  
  // => soa_person is: {["Ivo", "Dolf", "Laura", "Gabriel", "Denise"], [66, 42, 28, 30, 63], 
  //                    [true, false, true, true, false]}
}

/*
Person[0]: name= , age= 0, is_cool= false
Person[1]: name= , age= 0, is_cool= false
Person[2]: name= , age= 0, is_cool= false
Person[3]: name= , age= 0, is_cool= false
Person[4]: name= , age= 0, is_cool= false
*/
```

In line (1) we have a Person struct definition, and in line (2) we have the definition of the **SOA struct**. This takes a polymorphic type T, and an integer count, which is the number of objects.  
The #insert starts building  a string in line (3):  `#insert -> string { // building string }`  
In line (4) we define a string builder in which we'll construct our string (we immediately take care of its memory release).  
In line (5) we extract the type_info from our type T (see § 15.5). Then we loop over all its member fields (line (6)), and use print_to_builder (see § 19.5) to serialize the info into a struct definition.  
We get a string from the builder in (8) and return that as the SOA struct.

This gets called in line (9):  `soa_person: SOA(Person, 5);`
where the new SOA type is constructed with T equal to type Person and count equal to 5 and zero-initialized data as shown by printing it out in a for-loop ().
`soa_person` looks internally like this:
```
    soa_person {
        name[5];
        age[5];
        is_cool[5];
    }
```
**How to transform an AOS to an SOA?**  
In line (11) we define an array of Person objects. Line (12) shows that only a simple for loop over the AOS is needed to transfer the data to an SOA.

In § 27.2 we extend this example to work with Person data from a .csv file.

> Other references (videos on youtube):  
    • Noel Llopis: Data-oriented design  
    • Chandler Carruth: Efficiency with Algorithms, Performance with Data Structures  
    • Mike Acton: Data-oriented design in C++  

## 26.11 How to get the generated source files after the meta-program step?
The piece of source code that gets generated from a #insert can be retrieved from the hidden _.build_ folder. For example: program 26.10_soa.jai generates an additional source file called `.added_strings_w2.jai` in .build with this content:
```c++
// Workspace: Target Program
//
// #insert text. Generated from d:/Jai/The_Way_to_Jai/examples/26/26.10_soa.jai:10.
//
  name: [5] type_of(T.name);
  age: [5] type_of(T.age);
  is_cool: [5] type_of(T.is_cool);
```

Line (10) mentioned here is this line: #insert -> string.

## 26.12 How to get info on the nodes tree of a piece of code?
In § 26.4.5 we saw how #code can make something of type Code out of a piece of code. Another way is to call the proc `code_of` on a piece of code. For some examples of code_of, see jai/examples/here_string_detector.jai and self_inspect.jai

### 26.12.1 The compiler_get_nodes procedure
The helper procedure `compiler_get_nodes` can take the result of `#code` or `code_of` and get the AST nodes out of it:
```
compiler_get_nodes :: (code: Code) -> (root: *Code_Node, expressions: [] *Code_Node) #compiler;
```

(`Code_Node` is a struct defined in module _Compiler_)  
In the program below we analyze the nodes of the statement: `code :: #code a := Vector3.{1,2,3};`

See *26.11_code_nodes.jai*:
```c++
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
```

To print out the nodes, we need to import the module _Program_Print_ (line (1)). We call `compiler_get_nodes` on our code statement in line (2), to get the root node and the exprs. `print_expression` 'prints' the code to a String Builder (line (3)).  
In line (4) we can now iterate over `exprs` to show the `kind` of each sub-expression and their `node_flags` if any.

`compiler_get_nodes` converts the Code to a syntax tree (AST). As we see in line (2), it returns two values:  
- the first is the root expression of the Code, which you can navigate recursively.   
- the second is a flattened array of all expressions at all levels, just like you would get in a meta-program inside a Code_Type_Checked message. This makes it easy to iterate over all the expressions looking for what you want, without having to do some kind of recursive tree navigation.  

### 26.12.2 Changing the AST of code at compile-time
This example is taken from the article by forrestthewoods: [Learning Jai via Advent of Code](https://www.forrestthewoods.com/blog/learning-jai-via-advent-of-code/). It builds further upon exercise 'changer_macro1.jai', so you might want to try that first.  

We saw in § 26.12.1 that at compile-time, Code can be converted to Abstract Syntax Tree nodes, manipulated, and converted back.
Instead of simply inserting code at compile time, let's change it also!

See *26.36_changing_ast.jai*:
```c++
#import "Basic";
#import "Compiler";

factorial :: (x: int) -> int {
  if x <= 1 return 1;
  return x * factorial(x-1);
}
    
comptime_modify :: (code: Code) -> Code {
  root, expressions := compiler_get_nodes(code);  // (1)
  
  for expr : expressions {                        // (2)
    if expr.kind == .LITERAL {                    // (3)
      literal := cast(*Code_Literal) expr;
      if literal.value_type == .NUMBER {
        fac := factorial(literal._s64); // compute factorial
        literal._s64 *= fac;                      // (4)
      }
    }
  }
  modified : Code = compiler_get_code(root);      // (5)
  return modified;
}

// modify and duplicate code
do_stuff :: (code: Code) #expand {
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
```

Again we submit the code `x *= 3` as parameter to a `do_stuff` macro, that inserts it 4 times. But now we modify the `code` to `new_code` before inserting:  
`new_code :: #run comptime_modify(code);`  
`comptime_modify` is the procedure we're going to #run at compile-time; it takes Code and returns Code.

`compiler_get_nodes` is called upon `code` in line (1).  
We know that it converts the Code to AST nodes. Then in line (2), we are going to walk this AST tree. We only look for the literal values in line (3), and narrow this to only numbers.

We are going to multiply number literals by their factorial (in our example this is only the literal 3).  
This we do in line (4):  
3 becomes 3*factorial(3) which is 3*6 = 18,   
thereby effectively modifying the node in place.  
This has changed the AST `root` data. Now we must convert the  modified nodes in the AST back to Code, which is done with the 
`compiler_get_code` procedure.

To summarize, in this example we:
* declared the code x *= 3;
* compile-time modified the compiler parsed AST to x *= 18;
* inserted x *= 18; four times
All this in pure Jai code!

Here is a snippet of code that searches for string literals in code, (possibly) changing them, and writing the changes back with the proc `compiler_get_code`:
```c++
root, expressions := compiler_get_nodes(code);
for expressions {
    if it.kind != .LITERAL continue;  
    literal := cast(*Code_Literal) it;
    if literal.value_type != .STRING continue;  
    // do something with literal._string
    // literal._string = ...
}
modified := compiler_get_code(root);
```

(An example of this can be found in how_to/630, 2nd example)

## 26.13 The #type directive and type variants
This directive tells the compiler that the next following syntax is a type literal, useful for defining procedure types and variant types. Variant types are like alias types (see § 9.1), but differ in the casting behavior.

Here is a simple example:  
See *26.38_proc_type_pointer.jai*:
```c++
#import "Basic";

main :: () {
    my_proc :: (v: int) -> int { return v + 5; }
    my_proc_type :: #type (int) -> int;        // (1)
    assert(type_of(my_proc) == my_proc_type);  // (1B)

    an_int : int = 42;
    a_proc_ptr : my_proc_type = my_proc;       // (2)
    another_int := a_proc_ptr(an_int);         // (3)
    print("%", another_int); // => 47
}
```
`my_proc_type` is the type of `my_proc`, as indicated in line (1), and confirmed by the assert in line (1B). With this type, we can define a procedure pointer (line (2)), which can be used to call the proc (line (3)).

Here is a more complex example used in interaction with C code:  
```c++
IL_LoggingLevel :: u16;
IL_Logger_Callback :: #type (level: IL_LoggingLevel, text: *u8, ctx: *void) -> void #c_call;
```
The code above defines the procedure `IL_Logger_Callback` as a proc with as type the given signature.

#type is useful for resolving ambiguous type grammar, for example the following declaration does not compile: `proctest: Type : (s32) -> s32;`
but adding #type it does compile:     
`proctest: Type : #type (s32) -> s32;`
  
It can also be used to define **type variants**, as in the following example, with syntax `#type,distinct` or `#type,isa`:

See *26.21_type_variants.jai*:
```c++
#import "Basic";
#import "Math";

Handle       :: #type,distinct u32;     // (1)
Filename     :: #type,isa string;       // (2A)
Velocity3    :: #type,isa Vector3;      // (2B)

main :: () {
    a: Handle = 5;      // (3)
    print("Math on a yields: %\n", 3 * a + 2);  // => Math on a yields: 17
    b: u32 = 42;
    // a = b;           // (3B) Error: Type mismatch. Type wanted: Handle; type given: u32.
    a = cast(Handle) b; // (3C) 
    a = xx (b + 1);     // (3D) 

    hi := type_info(Handle);
    print("%\n", hi);                    // (4) => Type
    ti := cast(*Type_Info) Handle;
    print("%\n", ti.type);               // (5) => VARIANT
    print("hi is %\n", <<hi.variant_of); // (5B) => hi is {INTEGER, 4}

    fn: Filename = "/home/var/usr/etc/dev/cake";
    f := type_info(Filename);
    print("f is %\n", <<f.variant_of); // (6) => f is {STRING, 16}

    va: Velocity3 = .{1,2,3};
    print("va has type %\n", type_of(va));  // => va has type Velocity3
    g := type_info(Velocity3);
    print("g is %\n", <<g.variant_of); // (7) => g is {STRUCT, 12}
}
```

Line (1) defines a distinct variant type Handle, which is a u32, but distinct from it. You can do numerical operations on variables of type Handle.  
Trying to assign (implicitly cast) a u32 variable to a Handle variable fails (see line 3B): this is type safety and that's why it is a distinct type. However, an explicit cast or an auto-cast as in lines (3C-D) works.  

The type of Handle is Type (see (4)), but if we dig deeper in line (5) we see that it is a VARIANT type, the item with value 18 from the Type_Info_Tag enum (see § 16.2).  

Another variant of the isa type is shown in lines (2A-B). These types will implicitly cast to their isa type, but variants with the same isa type will not implicitly cast to each other.
Taking type_info(), and dereferencing the `variant_of` field shows the underlying type and size (lines 5B, 6 and 7).

The different possibilities and limits are nicely illustrated in the following example:

See *26.37_type_distinction.jai*:
```c++
#import "Basic";

// cpp: using HandleA = u32;
// rust: type HandleA = u32;
HandleA :: u32;

// cpp: no equivalent
// rust: no equivalent
HandleB :: #type,distinct u32;

// Functions
do_stuff_u :: (h: u32) { /* ... */ }
do_stuff_a :: (h: HandleA) { /* ... */ }
do_stuff_b :: (h: HandleB) { /* ... */ }

main :: () {
    // Variables
    u : u32 = 7;
    a : HandleA = 42;
    b : HandleB = 1776;

    // HandleA converts to u32, HandleB does not
    // Assignment
    u = a;
    a = u;
    // a = b; // compile error
    // b = a; // compile error
    // u = b; // compile error
    // b = u; // compile error

    // procedure takes u32, but also HandleA
    do_stuff_u(u);
    do_stuff_u(a);
    //do_stuff_u(b); // compile error

    // procedure takes HandleA, but also u32
    do_stuff_a(u);
    do_stuff_a(a);
    // do_stuff_a(b); // compile error

    // procedure takes HandleB only
    // do_stuff_b(u); // compile error
    // do_stuff_b(a); // compile error
    do_stuff_b(b);
}
```

## 26.14 Getting the name of a variable at compile time
See *26.23_get_variable_name.jai*:
```c++
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
    a_constant :: 10;
    #run print("%", get_variable_name(a_constant)); // => a_constant
}
```

The directive **#caller_code** when used as the default
value of a macro argument, will be set to the Code of the procedure call
that invoked the macro.  
`compiler_get_nodes()` from module _Compiler_ can then be called on this code to inspect and manipulate it. `print_expression` from module _Program_Print_ `prints` the 2nd argument in a string-format to the string builder.
With these kinds of techniques you manipulate code from a macro within the program itself (see how_to/497).
There is also a `print_type_to_builder` proc for printing type info to a string builder (see how_to/935).

## 26.15 Converting code to string
See *26.27_convert_code_string.jai*:
```c++
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
```

We again use compiler_get_nodes to get the AST, which is then `printed` to a string builder, and then converted to a string.

## 26.16 Creating code for each member in a structure
The following example is a quick (non recursive) helper to create some code for each member in a structure (it is derived and slightly changed from a Snippets example in the Jai Community Wiki): 

See *26.29_code_struct_member.jai*:
```c++
#import "Basic";

for_each_member :: ($T: Type, format: string) -> string
{
    builder: String_Builder;
    defer free_buffers(*builder);

    struct_info := cast(*Type_Info_Struct) T;
    assert(struct_info.type == Type_Info_Tag.STRUCT);

    for struct_info.members 
    {
        if it.flags & .CONSTANT continue;
        print_to_builder(*builder, format, it.name);
    }

    return builder_to_string(*builder);
}

serialize_structure :: (s: $T, builder: *String_Builder) -> success: bool
{
    #insert #run for_each_member(T, "if !serialize(s.%1, builder) return false;\n" );  // (1)
    // %1          = member name;  type_of(%1) = member type
    // The following code will be inserted before compiling (see .build/.added_strings_w2.jai)
    // if !serialize(s.status, builder) return false;
    // if !serialize(s.health, builder) return false;
    return true;
}

serialize  :: (to_serialize: $T, builder: *String_Builder) -> success: bool { 
    print_to_builder(builder, "%-", to_serialize);
    return true; 
} 

main :: ()
{
    Player :: struct
    {
        status: u16;
        health: int;
    }
    p := Player.{7, 75};
    
    builder: String_Builder;
    defer free_buffers(*builder);

    success := serialize_structure(p, *builder);
    if !success { 
        print("Serializing error");
        exit(-1);
    }
    str := builder_to_string(*builder);
    print("The result of serializing is: '%'.\n", str);
    // => The result of serializing is: '7-75-'.
}

// .build/.added_strings_w2.jai contains:
// Workspace: Target Program
//
// #insert text. Generated from d:/Jai/testing/test2.jai:25.
//
/*
if !serialize(s.status, builder) return false;
if !serialize(s.health, builder) return false;
*/
```

We want to store the field values of a (Player) struct in a string, possibly writing them to a file later on. 
All procedures in this example are polymorphic. In `serialize_structure` T becomes Player. In line (1) `for_each_member` is called before compiling and this inserts 2 lines of code (shown in .build/.added_strings_w2.jai):
```
if !serialize(s.status, builder) return false;
if !serialize(s.health, builder) return false;
```

`for_each_member` checks whether we have a struct, and then substitutes the field name into our format string, which goes into the string builder.
To compile this, a proc `serialize` has to exist, which is also polymorphic in our example and which writes the field's values in the string builder.

## 26.17 A type-tagged union
We discussed unions in § 13.2, where we saw that a union has only one field, but can take values of different types. It could be useful to know at any time which type the union value has. This could be done by enclosing the union within a struct, with a field containing the type.

See *26.31_tagged_union.jai*:
```c++
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
    return "";
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
```

In the above code a struct `Tag_Union` has a field `tag` that contains the current type, and struct parameters fields of type [] string and types of type []Type. The `fields` are the names of the possible union fields, and `types` are their corresponding types. 

The structs code is dynamically build with a `#insert -> string` using the structs parameters. You can find the code in .build/.added_strings_w2.jai:  
```
union {
  int_a: s64;
  float_b: float32;
  string_c: string;
}
```

`tag_union` is an instance of the struct. At its declaration in line (1), the parameters are passed and the structs definition is built. The `set :: (u: *$Tag/Tag_Union, value: $T)` proc changes the instance by supplying a value for the union.  

Its code also uses a `#insert -> string` which loops over the fields of the union. If the type of the supplied value matches one of the union types, that type is written to the `tag` field and the value is written to the union's field. The `/Tag_Union` in set's declaration checks that $Tag has the fields of Tag_Union (see § 23.6).

In line (2A), the `set` function is called with value 10, so tag becomes s64 and the int_a field becomes 10; the same goes for lines (2B-C).
If the type of the supplied value is not present in the types array, we get a compile-time error like: `Assertion failed: Invalid value: bool` (see line (2D)).

## 26.18 Create code for a list of types
The following program combines polymorphism, a macro, #insert -> string and #code to do something with each type from a list of types:

See *26.39_creating_types.jai*:
```c++
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
```

