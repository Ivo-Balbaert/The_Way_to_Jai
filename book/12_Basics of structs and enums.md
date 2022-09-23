# Chapter 12 - Basics of structs and enums

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
}

/*
0 0
42 108
1 4
0 0
Robert is aged 42 and is currently at location {64.139999, -21.92}
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
All struct fields are public: they can be read and even changed everywhere! There is a convention to prefix fields which should be private by `_`, but the compiler does not enforce that.

A struct definition must occur in a data scope (see § 7).

> Declaring a struct doesn't allocate memory, it just defines a kind of template or blue-print for a data structure to be defined in imperative scope.

## 12.2 Making struct variables
When defining a struct no variable is defined, so no memory is allocated yet.  
You have to define a struct variable, like this:  `v: Vector2;`
This variable v is defined on the stack, in § ?? we'll see how to make a struct on the heap.  
All data values are contiguous in memory, that is: they are packed together successively in the order in which they are defined.

How can we access the data in a field?  
Simply by using the dot (.) notation, as in `v.x` shown in line (1). Here we see that fields get default zero-values.
In lines (2) and (5) we see how field data can be changed, the field is written as left-hand-side of an assignment:   
`bob.name = Robert;`
(Note that a := is not needed, because the fields type has already been declared!)

What if you don't want default zero-values?  
1) You can give other default values, like in `Vector2d` (see line (3)).
(If a field has a default value, its type can be inferred by using := notation.)
2) You can leave the fields uninitialized with ---, like in `Vector2un` (see line (4)).
3) Or you can make a mix of default and uninitialized values, like in `Vector3un`.

## 12.3 Nested structs
The location field in Person is itself a Vector2 struct, that's why it is called a **nested struct**: a struct that contains another struct. Note how you can access and change the fields of a nested struct by 'drilling down' with the . notation, like:   `bob.location.x`

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

## 12.7 A struct's namespace
(see nested_structs)









