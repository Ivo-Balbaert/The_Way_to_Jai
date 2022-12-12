# 24 Operator overloading

Operators are in-built procedures like + (addition of numbers) or the index operator [] (array[i]).
It can be useful in certain cases when you need this kind of operations a lot to be able to define let's say a `+` and `*` operation for Vectors. In § 24.1 we show 2 overloaded operators for Vector3, which are in fact defined in module _Math_.
In a sense, it's like overloading a procedure (see § 17.7), but now you overload an operator. 
Jai even has a keyword **operator** specifically for that purpose.
It is used like this (note the resemblance with a procedure):  
`operator token :: (argument list) ->  (return-type list)`    
where: token can be:     +, -, *, /, +=, -=, *=, ==, !=, <<, >>, &, |, [], %, ^, <<<, >>> 
The following operators cannot be overloaded: = and New.

> Operator overloading allows the programmer to define implementations for the fundamental operators like +, -, and so on, that can be used on custom-defined data types.

## 24.1 Vector operators
See *24.1_overloading_vec.jai*:
```c++
#import "Basic";
#import "Math";

main :: () {
    a := Vector3.{1.0, 2.0, 3.0};
    b := Vector3.{3.0, 4.0, 2.5};
    c := a + b;             // (1)
    c += a;                 // (2)
    print("c = %\n", c);    // => c = {5, 8, 8.5}

    d := Vector3.{3.0, 4.0, 2.5};
    e := Vector3.{1.0, 2.0, 3.0};
    f := d - e;         
    print("f = %\n", f);    // => f = {2, 2, -0.5}
    print("%\n", operator -(d, e));    // (2B) => {2, 2, -0.5}

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
Line 2B shows that you can explicitly call an operator overload, like `operator-(a, b)` or `Basic.operator-(a, b)`.

In lines (3)-(4) we use * with a Vector3 and a float.
`*` for Vector3 and float is defined with this signature:    
`operator * :: (a: Vector3, k: float) -> Vector3  #symmetric`  
followed by how the returned Vector3 value is calculated.
(look it up in Math\module.jai)  
The **#symmetric** directive tells us that a Vector3 * a float (like in (3)) or a float * a Vector3 (like in (4)) both give the same result.

## 24.2 Object operators
In this section we make a few operator overloadings ourselves.

See *24.2_overloading_object.jai*:
```c++
#import "Basic";

Obj :: struct {     
    array: [10]int;
}

operator [] :: (obj: Obj, i: int) -> int {       // (1)
    return obj.array[i];
}

operator []= :: (obj: *Obj, i: int, item: int) { // (2)
    obj.array[i] = item;
}

operator *[] :: (obj: *Obj, i: int) -> *int {    // (3)
    return *obj.array[i];
}

operator *= :: (obj: *Obj, scalar: int) {        // (4) 
    for obj.array  obj.array[it] *= scalar;
// alternative:
//     for *a: obj.array  { <<a *= scalar; }
}

main :: () {
    o : Obj;
    print("o[0] = %\n", o[0]);  // (1B) => o[0] = 0
    o[0] = 10;                  // => o[0] = 10
    print("o[0] = %\n", o[0]);

    p : Obj;
    p.array = .[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    p *= 100;                  // (4B)
    print("p.array = %\n", p.array);  
    // => p.array = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900]

    ptr := *p[7];              // (3B)
    print("<<ptr is %\n", <<ptr); // => <<ptr is 700
    <<ptr *= 3;
    print("<<ptr is %\n", <<ptr); // => <<ptr is 2100
    print("p[7] is %\n", p[7]);   // => p[7] is 2100
}
```

Suppose we have an object obj which has an `array` field. Instead of doing `obj.array[i]` we would like to shorten this to `obj[i]`. We can do this by overloading the `[]` operator as in line (1), which is applied in line (1B).

In line (2) we overload the operator []= , which allows us to set each any member array item to a new value. This doesn't just enable the raw '=' operator; it enables all the assignment operators, like +=, *=, /=, ^=, and so on, to work.

In line (3) we overload the operator *[], which allows us to get a pointer to any member array item. This also allows to change these items, see line (3B) and following.

In line (4) we overload `*=` for an Object and a integer, to mean that every item of the array is multiplied by the integer. This is used in line (4B).

**Exercise** 
1) Define a struct type Complex for complex numbers, together with two operators for + and *. Test out (see complex_overload.jai).
2) Define a polymorphic `square` proc that works for all number types. Then define a Vector3 type as a struct with x, y, z: float. Verify that square doesn't work for Vector3. Now define an operator * for Vector3 so that it does!
(see poly_square.jai).

## 24.3 The #poke_name directive
This directive isn't exclusively used for operators, but the examples we'll show use operators, so that's why it is discussed here.
Here is a 1st example of its use:
```
using Hash_Table :: #import "Hash_Table";
#poke_name Hash_Table operator==;
```
The **#poke_name** directive here effectively injects a reference to your operator== into the Hash_Table module.

Here is a complete working example. See 24.3_poke_name.jai_:
```c++
#import "Basic";
Math :: #import "Math";

Vector4 :: struct { x, y, z, w : float; };

dot_product :: (a: Vector4, b: Vector4) -> float { 
    return a.x*b.x+a.y*b.y+a.z*b.z+a.w*b.w; 
}

#poke_name Math dot_product;        // (1)

main :: () {
    v1 := Vector4.{1, 2, 3, 4};
    v2 := Vector4.{6, 7, 8, 9};
    print("dot_product is: %", Math.dot(v1, v2));  // (2)
    // => dot_product is: 80
}
```

Module _Math_ is imported, and we define a new type Vector4 and a dot_product proc for this type (we could have used the Quaternion type from Math, Vector4 is used here to make an example). In line (1) we use the directive to inject our `dot_product` into _Math_.  
In line (2), we call Math.dot for two Vector4 instances. 
Module _Math_ defines dot as dot_product:
`dot :: dot_product;`  
_Math_ already had three overloads for `dot_product`, namely for types Vector2, Vector3 and Quaternion. Using #poke_name, we have supplied a 4th alternative, which can be used for Vector4 in our program.
