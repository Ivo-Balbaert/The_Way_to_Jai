# 24 Operator overloading

Operators are in-built procedures like + (addition of numbers) or the index operator [] (array[i]).
It can be useful in certain cases when you need this kind of operations a lot to be able to define let's say a `+` and `*` operation for Vectors. In § 24.1 we show 2 overloaded operators for Vector3, which are in fact defined in module _Math_.
In a sense, it's like overloading a procedure (see § 17.7), but now you overload an operator. 
Jai even has a keyword **operator** specifically for that purpose.
It is used like this (note the resemblance with a procedure):  
`operator token :: (argument list) ->  (return-type list)`    
where: token = +, -, +, [], ...

## 24.1 Vector operators
See _24.1_overloading_vec.jai_:
```c++
#import "Basic";
#import "Math";

main :: () {
  a := Vector3.{1.0, 2.0, 3.0};
  b := Vector3.{3.0, 4.0, 2.5};
  c := a + b;             // (1)
  c += a;                 // (2)
  print("c = %\n", c);    // => c = {5, 8, 8.5}

  a2 := Vector3.{3.0, 4.0, 5.0};  
  c2 := a2 * 3;           // (3)
  print("c2 = %\n", c2);  // => c2 = {9, 12, 15}
  c3 := 3 * a2;           // (4)
  print("c3 = %\n", c3);  // => c3 = {9, 12, 15}
}
```

In this code we use the + and * overloaded operators for the Vector3 type from module _Math_.

In lines (1)-(2) we use + with two Vector3 arguments.
`+` for Vector3 is defined with this signature:    
`operator + :: (a: Vector3, b: Vector3) -> Vector3`  
followed by how the returned Vector3 value is calculated.
(look it up in Math\module.jai)

In lines (3)-(4) we use * with a Vector3 and a float.
`*` for Vector3 and float is defined with this signature:    
`operator * :: (a: Vector3, k: float) -> Vector3  #symmetric`  
followed by how the returned Vector3 value is calculated.
(look it up in Math\module.jai)  
The **#symmetric** directive tells us that a Vector3 * a float (like in (3)) or a float * a Vector3 (like in (4)) both give the same result.

## 24.2 Object operators
In this section we make a few operator overloadings ourselves.

See _24.2_overloading_object.jai_:
```c++
#import "Basic";

Obj :: struct {     
  array: [10]int;
}

operator [] :: (obj: Obj, i: int) -> int {  // (1)
  return obj.array[i];
}

operator *= :: (obj: *Obj, scalar: int) {   // (2) 
    for obj.array  obj.array[it] *= scalar;
// alternative:
//     for *a: obj.array  { <<a *= scalar; }
}

main :: () {
  o : Obj;
  print("o[0] = %\n", o[0]);  // (1B) => o[0] = 0

  o2 : Obj;
  o2.array = .[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  o2 *= 100;                  // (2B)
  print("o2.array = %\n", o2.array);  
  // => o2.array = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900]
}
```

Suppose we have an object obj which has an array field. Instead of doing `obj.array[i]` we would like to shorten this to `obj[i]`. We can do this by overloading the `[]` operator as in line (1), which is applied in line (1B).

In line (2) we overload `*=` for an Object and a integer, to mean that every item of the array is multiplied by the integer. This is used in line (2B).
