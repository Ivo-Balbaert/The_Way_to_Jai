# Chapter 12 - Basics of structs

Every programming language needs a kind of data structure that can define some kind of entity, that has several characteristics, called **fields** (also called member variables), that can be of a different type. The solution to this is the **struct** type, that is common in many other languages, and is a kind of lightweight version of a class.

Also because composite types like arrays and strings are defined internally as a struct, we need to have a basic knowledge of that concept first.

## 12.1 Struct declarations
See _12.1_struct_declarations.jai_:

```c++
#import "Basic";
#import "Math"; // contains Vector2

// default values:
Vector2d :: struct {
  x : float = 1;
  y : float = 4;
}

//  Uninitialized struct
Vector2un :: struct {
    x: float = ---;
    y: float = ---;
}

//  Uninitialized member(s):
Vector3un :: struct {
    x: float = 1;
    y: float = ---; // uninitialized
    z: float = 3;
}

Entity :: struct {
    serial_number: int;
}

Person :: struct {
    name            : string;
    age             : int;
    location        : Vector2;
}

main :: () {
    v : Vector2;
    print("%\n", v); // (0) => {0, 0}
    print("% %\n", v.x, v.y); // (1) => 0 0
    v.x, v.y = 42, 108;       // (2)
    print("% %\n", v.x, v.y); // => 42 108

    v3 : Vector2d;
    print("% %\n", v3.x, v3.y); // (3) => 1 4

    v4 : Vector2un;
    print("% %\n", v4.x, v4.y); // => 0 0
    print("%\n", type_of(v4)); // => Vector2un
    // (4) Undefined behavior, could print anything, mostly "0 0"

    bob : Person;
    bob.name = "Robert";           // (5)
    bob.age = 42;
    bob.location.x = 64.14;        // (6)
    bob.location.y = -21.92;
    print("% is aged % and is currently at location %\n", bob.name, bob.age, bob.location); // (7)
    print("%\n", bob); // (8) => {"Robert", 42, {64.139999, -21.92}}
    assert(type_of(bob) == Person);

    // struct literals:
    vec2 := Vector2.{2.0, 6.28}; // (9)
    // same as:
    vec3 : Vector2;
    vec3 = .{2.0, 6.28};
    vec4:= Vector2.{y = 6.28, x= 2.0}; 
    print("%\n", vec2); // => {2, 6.28}
    bob2 := Person.{"Robert", 42, Vector2.{64.139999, -21.92}}; // (10)
    print("%\n", type_of(bob2)); // => Person
    print("%\n", size_of(Person)); // => 32 // (bytes)

    // formatting printout of structs:
    v3d := Vector3.{1.0, 2.0, 3.0};
    print("v3d = %\n", formatStruct(v3d,    // (10)
        use_long_form_if_more_than_this_many_members = 2, 
        use_newlines_if_long_form = true));
    // =>
    /*
    v3d = {
        x = 1;
        y = 2;
        z = 3;
    }
    */
}

/*
{0, 0}
0 0
42 108
1 4
0 0
Vector2un
Robert is aged 42 and is currently at location {64.139999, -21.92}
{"Robert", 42, {64.139999, -21.92}}
{2, 6.28}
Person
32
v3d = {
    x = 1;
    y = 2;
    z = 3;
}
*/
```

Here is an example of a declaration of a struct that represents a 2-dimensional point. It is called `Vector2`, and is defined in module _Math_ (as is the also common `Vector3`):

```c++
Vector2 :: struct {
    x: float;
    y: float;
}
```
A struct name starts with a capital letter. Use _ to separate multiple parts, such as: `Ice_Cream_Info`.   
The **struct** keyword is mandatory, and its body contains an enumeration of its **fields** in the form `field1: type1;`

When two or more fields have the same type, there is a shorter syntax: 

```c++
Vector3 :: struct {
    x, y, z: float;
}
```

Here is a struct which describes a Person entity:

```c++
Person :: struct {
    name            : string;
    age             : int;
    location        : Vector2;
}
```
All struct fields are _public_: they can be read and even changed everywhere! There is a convention to prefix fields which should be private by `_`, but the compiler does not enforce that. A struct field can be of type void (why ??).

> Unlike classes in other languages, Jai does NOT have member functions: there is no concept of functions "belonging" to a particular struct or datatype. So it's better to not define a procedure inside a struct.


A struct definition must occur in a data scope (see § 7).

An **anonymous struct** can be defined as for example:
```c++
struct {
     x: int;
     y: int;
     z: int;
}
```
( example of use ??)
> Declaring a struct doesn't allocate memory, it just defines a kind of template or blue-print for a data structure to be defined in imperative scope.

> A struct cannot be casted to a bool.

## 12.2 Making struct variables
When defining a struct no variable is defined, so no memory is allocated yet.  
You have to define a struct variable, like this:  `v: Vector2;`
This variable v is defined on the stack, in § ?? we'll see how to make a struct on the heap.  
All data values are contiguous in memory, that is: they are packed together successively in the order in which they are defined.

How can we access the data in a field?  
Simply by using the dot (.) notation, as in `v.x` shown in line (1).  
> . dereferences by default, unlike in C/C++
Here we see that fields get default zero-values.
In lines (2) and (5) we see how field data can be changed, the field is written as left-hand-side of an assignment:   
`bob.name = Robert;`
(Note that a := is not needed, because the fields type has already been declared!)

What if you don't want default zero-values?  
1) You can give other default values, like in `Vector2d` (see line (3)).
(If a field has a default value, its type can be inferred by using := notation.)
2) You can leave the fields uninitialized with ---, like in `Vector2un` (see line (4)).
3) Or you can make a mix of default and uninitialized values, like in `Vector3un`.

## 12.3 Nested structs
The location field in Person is itself a Vector2 struct, that's why it is called a **nested struct**: a struct that contains another struct. Note how you can access and change the fields of a nested struct by 'drilling down' with the . notation, like:   `bob.location.x  
(But also see § 12.7 for how to shorten this notation.)

Here is another example of nested structs:

```c++
Node :: struct {           
    value: int = 0;
}

Super_Node :: struct {      
    node_a: Node;
    node_b: Node;
}
```

## 12.4 Struct literals
Look at the lines (0), (7) and (8): print knows how to print out a struct, and the result is of the form: `{field_value1, ..., field_valuen}`, like {"Robert", 42, {64.139999, -21.92}}. 

`print` can also make use of the `formatStruct` proc, which gives additional functionality for printing out structs (see line (10)).

This suggests that there is a much easier way to make a struct variable called **struct literals**. Instead of declaring it, and then assigning a value to each field, you can just do:  
```c++
vec2 := Vector2.{2.0, 6.28}; 
bob2 := Person.{"Robert", 42, Vector2.{64.139999, -21.92}}; 
```
The Struct_Name. prefix is needed to inform the compiler which struct type is defined here. Note that all values provided in a struct literal must be constant, you can't use variables.

In struct literals you can also name the fields, like `field = value`. This allows you give the values in a different order, and fields that have default values don't need to be specified. 

**Exercise:**
Make a Super_Node struct variable with values 42 and 108; use the long and literal notation(see _making_struct.jai_)

## 12.5 Making structs on the heap
See the code example _12.2_struct_heap.jai_:

```c++
#import "Basic";

Person :: struct {
    name            : string;
    age             : int;
}

main :: () {
    bob := New(Person);            // (1)
    print("%\n", type_of(bob));    // (2) => *Person
    defer free(bob);               // (6A)

    bob.name = "Robert";           
    bob.age = 42;
    print("%\n", bob);             // (3) => 2d1_e8d2_c100
    print("%\n", << bob);          // (4) => {"Robert", 42}

    bob2 := New(Person);
    defer free(bob2);              // (6B) 
    bob2 = *Person.{"Robert", 42}; // (5)
}
```
In line (1) we use New to create our struct variable on the heap. Line (2) says the variable is now a pointer to a location in the heap, of type *Person. That's why in line (3) an address is printed. To print out the values, now you have to dereference << the variable, see line (4).  
You can use a struct literal as in line (5), but note: it's now a Pointer type.
Also remember to free the memory as in lines (6A) and (6B), Jai doesn't warn you when you forget it!

Why would you use structs on the heap?  
The stack is limited in size. If your program needs a lot of structs, better use the heap.

## 12.6 Recursive structs
A recursive struct is a struct that has as one of its fields a struct of the same type. They can be used to build more complex data structures like linked-lists and trees.

In code example _12.3_linked_list.jai_, we see how we can build a simple linked list, where each node has a 'payload' field `data`, and a `next` field that points to the next node:

```c++
#import "Basic";

ListNode :: struct {
    data: s64; 
    next:  *ListNode;
}

main :: () {
    lst := New(ListNode); // lst is of type *ListNode
    lst.data = 0;

    a :=  New(ListNode);  // a is of type *ListNode
    a.data = 12;
    lst.next = a;
    
    b  := New(ListNode);
    b.data = 24;
    a.next = b;
    
    c  := New(ListNode);
    c.data = 36;
    b.next = c;

    c.next = null; // the list ends here for the time being

    print("Our list is: %\n", lst); // => Our list is: 2ba_b8c6_6d70
    print("List data is % -> % -> % -> % \n", lst.data, a.data, b.data, c.data); 
    // => List data is 0 -> 12 -> 24 -> 36

    // free memory:
    free(a); free(b); free(c); free(lst);
}
```

Later on we'll see (§ ??) how to read/print/process such structs out, node by node. 

## 12.7 A structs namespace
(see nested_structs)

Wouldn't it be nice if you could use the fields of a struct without having to prefix them with their struct name? That's possible! A struct defines a **namespace**, which you can locally create with the **using** keyword. Then you don't need to use the struct name anymore.

See __12.4_using.jai_:
```c++
#import "Basic";

Person :: struct {
    name: string;
}

Patient :: struct {
    using pe: Person;      // (1)
    disease: string;   
}

main :: () {
    pat1 : Patient;  
    pat1.name = "Johnson"; // (2)
    print("Patient is: %\n", pat1); // => Patient is: {{"Johnson"}, "Bronchitis"}

    using pat1;            // (3)
    print("Patient has name: %\n", name); // => Patient has name: Johnson
}
```
Line (1) tells us Patient can use the namespace of Person. That's why in line (2) we don't need to use Person in order to access the `name` field. Line (3) shows us that we can even use pat1 as a namespace.  
The keyword using lets you import namespaces, as we did with enums. `pe` is not a keyword here, it can be replaced by any other word, for example `using person: Person`.
**using** allows us to refer to a contained struct's members without referencing that struct. It allows you to bring the member variables of a struct into the scope of another struct (like sub-classing but no methods/overriding) or a proc (like a method but more flexible, see ??).   
This mimics a kind of _inheritance_: Patient is like a subtype of the supertype Person.  
We use _composition_ instead of a subclass and can reference the fields of the ‘parent’ struct directly. Jai doesn't have classes and inheritance, but as we see here: first class composition works like inheritance!
(see ?? for a more complete example).

> The `using` keyword allows you to bring the member variables of a struct into the scope of a function (like a method but more flexible) or another struct (like subclassing but no methods/overriding).

> Favor composition over inheritance.

See this [Discussion about OOP](https://en.wikipedia.org/wiki/Entity%E2%80%93component%E2%80%93system)

## 12.8 The #as directive
What if we want the power of `using` from § 12.7 and the ability to implicitly cast a variable of the struct subtype to a variable of the struct supertype? This is accomplished with the **#as** directive:

See _12.6_#using_as.jai_:

```c++
#import "Basic";

Person :: struct {
    name: string;
}

Patient :: struct {    
    using as: Person;
    disease: string;   
}

Employee :: struct {    // (1)
    using #as p: Person;
    profession: string;   
}

main :: () {
    pat1 : Patient;  
    pat1.name = "Johnson"; 
   
    emp1: Employee;
    emp1.name = "Gates";
    emp1.profession = "software engineer";
    print("%\n", emp1); // => {{"Gates"}, "software engineer"}

    p1: Person;
    // p1 = pat1; // (3) Error: Type mismatch: incompatible structs (wanted 'Person', given 'Patient').
    p1 = emp1;
    print("%\n", p1); // (4) => {"Gates"}
}
```

In this example we have our Patient subtype from before, but in line (1) an Employee subtype is defined with #as: 
`#as using p: Person;`  
We see the difference when comparing lines (3) and (4):
- in (3) we attempt to assign a Patient to a Person variable, this errors out!
- in (4) we assign an Employee to a Person variable, this works, but of course only retains the name in p1.

So #as means we can implicitly cast from the subtype to the supertype!  
#as using p: Person;
   can also be written as:  
using #as p: Person;

#as is also used in the Type_Info_ types, discussed in § 16.2


**Exercise**
Declare a Point3D struct with 3 float coordinates x, y and z.
Make a pnt variable of type Point2D, initialize it as a struct literal. Then print out the coordinates without writing pnt.x, and so on (see exercises/12/using.jai).

## 12.9 Using a structs namespace for better storage management
Suppose our application uses a struct Entity, with a number of fields that our used very much, and the rest is used much less. We could then place the frequently needed fields in an Entity_Hot struct, to be placed on the stack. The less needed fields could be placed in an Entity_Cold struct, to be allocated on the heap.  
Our Entity struct could now be composed with pointers to these two parts as follows:

```c++
Entity_Hot :: struct {
    // most-used fields, stored in stack
}

Entity_Cold :: struct {
    // less-used fields, stored on heap
}

Entity :: struct {
    using hot:  *Entity_Hot;
    using cold: *Entity_Cold;
}
```

Now fields can even be switched from Hot to Cold or vice-versa without having to change the code! This can be decided based on the target platform.

## 12.10 Pointer to struct
See _12.5_pointer_to_struct.jai_:

```c++
#import "Basic";
#import "Math";

Person :: struct {
    name            : string;
    age             : int;
    location        : Vector2;
}

main :: () {
    bob := Person.{"Robert", 42, Vector2.{64.139999, -21.92}};
    rob := *bob;        // (1)
    print("rob is %\n", rob);   // => rob is 8d_425b_fe20
    print("The type of rob is %\n", type_of(rob)); // => The type of rob is *Person
    print("The value rob points to is %\n", << rob); 
    // => The value rob points to is {"Robert", 42, {64.139999, -21.92}}

    // 2nd example:
    Entity :: struct {
        serial_number: int;
    }

    e: Entity;              // e is a variable of type Entity
    e.serial_number = 0349825645;
//    ptr: *Entity;           // (3) ptr is a pointer to an Entity struct- a declaration
//    ptr = *e;               // (4) ptr is a pointer to e - initialization
    // shorter:
    ptr := *e;                // (5)
    print("e's value is: %\n", << ptr); // => e's value is: {349825645}
}
```

In line (1) we see how a pointer variable rob is created as a pointer to a struct variable. Its type us *Person.
In the 2nd example we note that a struct can also be declared in a local scope.
The short definition of a pointer to a struct:  ptr := *e;  
can be divided into:  
    ptr: *Entity;  // declaration
    ptr = *e;      // assignment

## 12.11 Struct alignment

By aligning certain member fields of structs to 64 bit, we can make memory allocation cache-aligned on 64 bit systems. This can also be done for global variables. This enhances memory efficiency and reduces cache misses. This is shown in the following example:

See _12.7_struct_align.jai_:
```c++
#import "Basic";

Accumulator :: struct {
  accumulation: [2][256] s16 #align 64;         // (1)
  computedAccumulation: s32;
}

Object :: struct { member: int #align 64; }

Thing :: struct {
   member1: u8  #align 1;                        // (2)
   member2: u32 #align 1;
}

global_var: [100] int #align 64;                 // (3) 

main :: () {
    assert(cast(int)(*global_var) % 64 == 0);    // (4)
    object := New(Object);                       // (5)
    free(object);
}
```

The `Accumulator.accumulation` field and `global_var` in lines (1) and (3) are 64 bit cache-aligned. Line (4) shows that indeed the address of `global_var` is divisible by 64. In line (5) a heap allocation is performed that is 64-bit aligned.
(2) #align 1 ??

## 12.12 Making definitions in an inner module visible with using
Create a module TestInside with this content:
```
Struct1 :: struct {
    number: int;
}
```
(You can do this by creating a TestInside.jai in c:\jai\modules or in d:\jai\my_modules and compiling with -import_dir "d:\jai\my_modules".)

Also create a module TestScope with this content:
```
#import "TestInside";
```

Now create a `test.jai` with as content=
```c++
#import "Basic";
#import "TestScope";

main :: () {
    s1 := Struct1.{number = 42}; // (1) Error: Undeclared identifier 'Str'.
    print("%", s1);     // => {42}
}
```

Compiling `test.jai` gives the Error: Undeclared identifier 'Str'. This is because the definition of Struct1 gets into #scope_module in module TestScope, and is not visible inside our test program.  

If you want `Struct1` to be visible inside the program, change the content of TestScope to:  
```
using TestInside :: #import "TestInside"; 
```

Then we can make an instance s1 of Struct1, and print out its value.