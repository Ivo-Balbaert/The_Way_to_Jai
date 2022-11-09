# 23 Polymorphic arrays and structs

Much like we did in § 22 to make the types of function arguments and return values generic, we can also do something similar for arrays and structs.

## 23.1 Polymorphic arrays
In § 22 we already used arguments of a generic array type [] $T. 
The following example shows that this can also be done for the size of the array with something like [$N]:  
`x: [$N] $T`

See _23.1_array_polymorph.jai_:
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

Of course, $T can be replaced by a type like int, so that a parameter is only used for the size.

## 23.2 A more general map procedure
We can use this to generalize our earlier map example 22.7_map.jai:  
`map :: (array_a: [$N] $T, f: (T)-> T ) -> [N] T`

See _23.2_map2.jai_:
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

See _23.3_poly_struct.jai_:
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

