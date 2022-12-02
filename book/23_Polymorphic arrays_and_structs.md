# 23 Polymorphic arrays and structs

Much like we did in § 22 to make the types of function arguments and return values generic, we can also do something similar for arrays and structs.

## 23.1 Polymorphic arrays
In § 22 we already used arguments of a generic array type [] $T. 
The following example shows that this can also be done for the size of the array with something like [$N]:  
`x: [$N] $T`

See *23.1_array_polymorph.jai*:
```c++
#import "Basic";

describe_array :: (x: [$N] $T) {                // (1)
    print("An array of % items of type %\n", N, T);
}

main :: () {
    x := int.[1,2,3,4];
    describe_array(x); // => An array of 4 items of type s64
}
```
N and T have to be known at compile-time.
Of course, $T can be replaced by a type like int, so that a parameter is only used for the size.

## 23.2 A more general map procedure
We can use this to generalize our earlier map example 22.7_map.jai:  
`map :: (array_a: [$N] $T, f: (T)-> T ) -> [N] T`

See *23.2_map2.jai*:
```c++
#import "Basic";

map :: (array_a: [$N] $T, f: (T)-> T ) -> [N] T {
  array_b: [N]T;
  for i: 0..N-1 {
    array_b[i] = f(array_a[i]);
  }
  return array_b;
}

main :: () {
  array_a := int.[1, 2, 3, 4, 5, 6, 7, 8];
  array_b := map(array_a, (x) => x + 100); 
  print("array_b is %\n", array_b);
  // => array_b is [101, 102, 103, 104, 105, 106, 107, 108]
}
```

This way we get the size passed as a generic parameter. If the applied lambda doesn't change the type T of the items, we can replace R by T as well.

## 23.3 Polymorphic structs
We can also use generic parameters to pass to a struct, in this case to define a 2D array as a struct field:

See *23.3_poly_struct.jai*:
```c++
import "Basic";

TwoD :: struct (M: int, N: int) {           // (1)
  array: [M][N] int;
}

TwoDb :: #bake_arguments TwoD(M = 5);       // (2)

main :: () {
  twod: TwoDb(N = 2);                        // (3)
  print("twod is %\n", twod);                // (4) 
  // => twod is {[[0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]}
  print("its dimensions are (%, %)\n", twod.M, twod.N);  // (5) 
  // => its dimensions are (5, 2)
}

```

The struct is defined in line (1). In line (2) we use #bake_arguments to bake in one of the dimensions. In line (3) the other dimension is passed when declaring a struct twod.
Line (4) shows the initial struct. Line (5) shows that we can access the passed parameters on the struct variable's name.
The polymorph arguments M and N have to be compile-time constants. They can have default values: `TwoD :: struct (M: int = 3, N: int = 3)`

## 23.4 Restricting the type of polymorphic proc arguments
In the following struct definition (see line (1)):

See *23.4_restrict_type.jai*:
```c++
#import "Basic";

PolyStruct :: struct(T: Type) {     // (1)
    data : T;
}

main :: () {
    ps: PolyStruct(int);            // (2)
    ps.data = 42;
    print("ps type = %\n", ps.T); // => ps type = s64
    print("ps is %\n", ps); // => ps is {42}

    // comparing types:              // (3)
    assert(type_of(ps) == PolyStruct(int));
    assert(ps.T == int);
    print("%\n", type_of(ps)); // => PolyStruct(T=s64)
    // assert(type_of(ps) == PolyStruct); // Assertion failed!
}
```

The  type T has to be declared when making an instance of the struct (in line (2), here T becomes int).
T is accessible via `ps.T` (see line (3)).
When comparing types in line (3) and following, you have to specify the complete type (struct type + concrete generic type).

If `PolyStruct` is a struct type with generic type T, you can tell the compiler that `proc1` can only accept PolyStruct instances by declaring it as:  
`proc1(x : PolyStruct($T))`

## 23.5 The $T/Base syntax
However, often this is too restrictive. We can also indicate that x has to be a subclass of PolyStruct. 
This you can do via the **/** notation:
`proc1(x : $T/PolyStruct)`  
Matching for $T will not work unless the target type matches PolyStruct, involving strongly-typed typechecking.
Important is that x doesn't have to be of the PolyStruct type!
It can simply incorporate a PolyStruct via e.g. `using ps: PolyStruct;` This enables also component based systems where each struct links via `using _c: SomeComponent;`

>Example:  
Given the following polymorphic struct:
```c++
Hash_Table :: struct (K: Type, V: Type, N: int) {
  keys: [N] K;
  values: [N] V;
}
```

all of the following procedure declarations are correct:
```c++
proc1 :: (table: Hash_Table($K, $V, $N), key: K, value: V) { } 
proc2 :: (table: $T/Hash_Table, key: T.K, value: T.V) { }
proc3 :: (table: $T, key: T.K, value: T.V) { }
proc4 :: (table: Hash_Table, key: table.K, value: table.V) { }
```

proc4 is called `implicit polymorphism`


## 23.6 The $T/interface Object syntax
`$T/interface Object` indicates that the $T must have the fields that struct Object has. This is similar to **traits**, **interfaces** or **concepts** in other languages. 
This allows you to do duck typing.

See *23.6_interface.jai*:
(Example from howto/160_type_restrictions)
```c++
#import "Basic";

Color :: enum u8 { RED; YELLOW; GREEN; ORANGE; MAUVE; };  
    
Matchable :: struct {
    name:   string;
    color:  Color;
}

Thing :: struct {
    duration: float64;
    tag:      string;
    name:     string;
    type:     Type;
    color:    Color;
}

discuss :: (x: $T/interface Matchable) {
    print("type_of(x) is %\n", type_of(x));
    print("x has a name '%' and has color %.\n", x.name, x.color);
    print("The entirety of x is %\n", x);
}
    
main :: () {
    match := Matchable.{"Nice", .ORANGE};
    discuss(match);
    // => type_of(x) is Matchable
    // => x has a name 'Nice' and has color ORANGE.

    thing: Thing;
    thing.name  = "Kurt Russell";
    thing.tag   = "Hello";
    thing.type  = void;
    thing.color = .RED;
    discuss(thing);
    // => type_of(x) is Thing
    // => x has a name 'Kurt Russell' and is the color RED.
    // => The entirety of x is {0, "Hello", "Kurt Russell", void, RED}
}
```
In the example above, we see that the procedure `discuss` Match structs, but also Thing structs, in general any struct that has a name and a type field.

See this applied in module _Math/module.jai_ and _Math/matrix.jai_.
See also the use of a polymorphic struct when constructing an SOA data design in § 26.9.2

## 23.7 The #bake_constants directive
We already discussed #this in § 17.9. In § 22.5 we talked about #bake_arguments, where you can bake in the value of a parameter at compile time. There is also  a **#bake_constants** directive, where you can bake in a polymorphic type with a concrete type.  

See *23.7_bake_constants.jai*:
```c++
#import "Basic";
#import "Math";

// Example 1:
display_xy :: (v: $T) {                             // (1)
   print("x coordinate is %\n", v.x); 
   print("y coordinate is %\n", v.y); 
}

baked1 :: #bake_constants display_xy(T = Vector2);  // (2)

// Example 2:
random :: () -> $T { 
    value := 0xcafe;  
    return cast(T) value;
}

random_s32 :: #bake_constants random(T = s32);   // (5)
random_u8  :: #bake_constants random(T = u8);    // (6)

// Example 3:
named_bake_test :: (a1: $A, a2: A, b1: $B, b2: B) -> A, B { // (9)
    a_sum := a1 + a2;
    b_product := b1 * b2;
    return a_sum, b_product;
}

nbt :: #bake_constants named_bake_test(A = float, B = int);  // (10)

main :: () {
    v2 := Vector2.{1, 2};
    baked1(v2); // (3)
    // => x coordinate is 1
    // => y coordinate is 2
    v3 := Vector3.{1, 2, 3};
    // baked1(v3); // Error: Type mismatch: incompatible structs (wanted 'Vector2', given 'Vector3').

    // random();  // (4) Error: Compile-time variable 'T' is needed but was not specified.
    print("%\n", random_s32() ); // (7) => 51966
    // print("%\n", random_u8() ); // (8) Cast bounds check failed.  Number must be in [0, 255]; it was 51966.

    sum, product := nbt(1, 2, 3, 4);  // (11)
    print("Sum is %, product is %\n", sum, product);
    // => Sum is 3, product is 12
}
```

In the example 1 above we have a polymorphic proc `display_xy` in line (1). Suppose we decide to restrict calls to `display_xy` to the argument type Vector2. We can do this by using the #bake_constants directive as in line (2).  
`baked1` is called a **baked method**: we have effectively created a proc with the signature like (using T: Vector2). Now the call baked1(v2) works fine (see (3)), but baked1(v3) won't compile because v3 is of a different type Vector3.
In example 2, we have a proc `random` that specifies a polymorphic return type $T. A call to it like random() as in line (4) doesn't specify T and gives an error. But baking in a type like in (5-6) works, as shown in line (7); (8) crashes because the value doesn't fit in a u8.  
In example 3 in lines (9-10), we bake in multiple types as named arguments, and call this baked proc in line (11).
 
#bake_constants makes the argument type fixed at compile-time, in other words: it bakes in the generic type(s) into a pre-compiled procedure, eliminating branches and optimizing the code path. It converts the polymorphic function into a non-polymorphic one.

## 23.8 Polymorphic struct using #this and #bake_constants
(Example taken from howto/050_this)

See *23.5_bake_constants_struct.jai*:
```c++
#import "Basic";

printer :: (x: $T) {                // (1)
    print("PRINTING!!! %\n", x);
}

Polymorphic_Struct :: struct (T: Type, N: int) { // (2)
    values:   [N] T;
    pointer: *#this;

    proc :: #bake_constants printer(T=#this);  // (3)
}

main :: () {
    p0: Polymorphic_Struct(float, 3);    //   (4)
    p1: Polymorphic_Struct(string, 2);   //   (5)

    print("p0 is %\n", p0); // (6) => p0 is {[0, 0, 0], null} 
    print("p1 is %\n", p1); // => p1 is {["", ""], null}

    p0.proc(p0);  // => PRINTING!!! {[0, 0, 0], null}  // (7)
    p1.proc(p1);  // => PRINTING!!! {["", ""], null}   // (8)

    assert(type_of(p0.pointer) == *type_of(p0));
    assert(type_of(p1.pointer) == *type_of(p1));
}
```

Line (1) presents a very simple polymorphic function `printer`. Line (2) defines a polymorphic struct with generic T and N. Field `pointer` points to itself with #this. What is new is that this struct contains a proc, which bakes in the #this (which is Polymorphic_Struct) into printer.  
In line (4), we declare an instance of Polymorphic_Struct, with T == float and N == 3; we do the same in (5) for T == string and N == 2. We print these out in line (6).  
In line (7), we call proc on p0 with p0.proc, and give it p0 as parameter; this means T becomes the type of #this, which is here p0. This call to printer prints out p0. The same goes for `p1.proc(p1);`

**Some wise words of Jon Blow about polymorphism:**
" If lots of procedures in your program are polymorphic, you pay for this in compile time, and possibly also in understandability of the program. Polymorphism is powerful, but historically, when people start writing code that is over-generic, it becomes hard to understand and modify. In general, don't get carried away making things polymorphic if they do not need to be. "
