# Chapter 12 - Basics of structs and enums

Every programming language needs a kind of data structure that can define some kind of entity, that has several characteristics (called **fields**) that can be of a different type. The solution to this is the **struct** type, that is common in many other languages, and is a kind of lightweight version of a class.

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
    print("% %\n", v.x, v.y); // (1) => 0 0
    v.x, v.y = 42, 108;       // (2)
    print("% %\n", v.x, v.y); // => 42 108

    v3 : Vector2d;
    print("% %\n", v3.x, v3.y); // (3) => 1 4

    v4 : Vector2un;
    print("% %\n", v4.x, v4.y); // => 0 0
    // (4) Undefined behavior, could print anything, mostly "0 0"

    bob : Person;
    bob.name = "Robert";           // (5)
    bob.age = 42;
    bob.location.x = 64.14;        // (6)
    bob.location.y = -21.92;
    print("% is aged % and is currently at location %\n", bob.name, bob.age, bob.location);
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
A struct name starts with a capital letter. The **struct** keyword is mandatory, and its body contains an enumeration of its **fields** in the form `field1: type1;`

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
This variable v is defined on the stack. 

How can we access the data in a field?  
Simply by using the dot (.) notation, as in `v.x` shown in line (1). Here we see that fields get default zero-values.
In lines (2) and (5) we see how field data can be changed, the field is written as left-hand-side of an assignment:   
`bob.name = Robert;`
(Note that a := is not needed, because the fields type has already been declared!)

What if you don't want default zero-values?  
1) You can give other default values, like in `Vector2d` (see line (3)).
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







- struct literals
- - recursive structs
- define struct on heap New
- the namespace of a struct








