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
The polymorph arguments M and N have to be compile-time constants.

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

## 23.5 The $T/Object syntax

However, often this is too restrictive. We can also indicate that x has to have the fields of PolyStruct. This you can do via the **/** notation:
`proc1(x : $T/PolyStruct)`  
This is similar to **traits** or **interfaces** in other languages 
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
`$T/interface Object` indicates that the $T must have the fields that struct Object has.
See this applied in module _Math/module.jai_ and _Math/matrix.jai_.

See also the use of a polymorphic struct when constructing an SOA data design in § 26.9.2

