# Chapter 6 – Bool and number types
See _6.1_bools.jai_:

```
#import "Basic";

main :: () {
    b1 := true;
    print("b1 is of type %\n", type_of(b1)); // => b1 is of type bool

    // equality:
    print("Are 1 and 1.0 equal? %\n", 1 == 1.0); // => Are 1 and 1.0 equal? true
    print("Are Jai and Java different? %\n", "Jai" != "Java"); // => Are Jai and Java different? true

    n := 7;
    m := 42;
    print("%\n", n != m); // => true

    // operators:
    print("! changes to %\n", !b1); // => ! changes to false
    b2 := !b1;

    print("b1 and b2 is %\n", b1 && b2); // => b1 and b2 is false
    print("b1 or b2 is %\n", b1 || b2);  // => b1 or b2 is true
}
```

## 6.1 - Boolean values
bool values `true` and `false` were discussed in § 5.1

### 6.1.1 Equal values and boolean expressions
Two values a and b can be compared with the equality operator **==**:  `a == b`.
This is a _boolean expression_ or _condition_, resulting in a bool value:  
  - it is true when a and b have the same value  
  - it is false in all other cases.

For example:  true == true and 1 == 1.0 are both true
The inequality operator **!=** reverses this, it gives true when the values are different:    `"Jai" != "Java"` gives true

In Jai you cannot compare values of a different type, for example: 
`0 == false: // => Error: Type mismatch. Type wanted: s64; type given: bool.`
Number types are an exception to this rule:   `1 == 2.0`  is allowed and returns false.

_Question_ What is the value of `"3" == 3`, why?  
_Answer_ This gives an error! Error: Type mismatch. Type wanted: string; type given: s64.

### 6.1.2 Boolean operators
The negation operator **!** changes a true value to false and vice-versa.  
The **&&** (and) operator is true only when both operands are true. 
The **||** (or) operator is false only when both operands are false.  
They operate in a 'short-circuit' manner, meaning:
for && when the 1st operand is false, the 2nd operand is not evaluated, because we know the result is false.
for !! when the 1st operand is true, the 2nd operand is not evaluated, because we know the result is false.

You can find complete truth tables [here](https://en.wikipedia.org/wiki/Truth_table).

### 6.1.3 The assert statement
See _6.2_assert.jai_:

```
#import "Basic";

main :: () {
    assert(5 == 5.0);
    assert(4 == 5, "4 does not equal 5"); // (1)
    // print("This is not printed when assert (false)");

    n := 42;
    assert(type_of(n) == int);
}

// => With line (1) uncommented:
/*
d:/Jai/The_Way_to_Jai/6_Bool_and_number types/examples/6.3_assert.jai:5,3: Assertion failed: 4 does not equal 5

Stack trace:
c:/jai/modules/Preload.jai:334: default_assertion_failed
c:/jai/modules/Basic/module.jai:74: assert
d:/Jai/The_Way_to_Jai/6_Bool_and_number types/examples/6.3_assert.jai:5: main
*/
```

Instead of always printing out if a bool expression is true of false, there is a handy shortcut with the **assert** procedure, defined in module _Basic_.

When the expression is true, nothing happens. When the expression is false, an assert stops the programs execution with **Assertion failed** and the line where it happened, and prints out a stack trace. A message parameter after the expression is optional, but when there is one, it is also printed out (see the example in line (1)).

assert also works with complex expressions, procedure calls, and so on. It is a very useful tool to make sure your program is always in a correct state. It is also very handy during debugging.
Also you can leave important assert statements in production code and disable them as described below. That way, when a problem occurs you can quickly enable them in development/test to try to find the cause.

> Basic has a module parameter defined for it: ENABLE_ASSERT := true
>To increase performance for a release build, you can disable asserts by changing the import to:
>	`#import "Basic"()(ENABLE_ASSERT=false);`
> That way you can leave the asserts in your code, without incurring a performance penalty.

## 6.2 - Number types
See _6.3_numbers.jai_:

```
#import "Basic";

main :: () {
    // 6.2.2 - arithmetic operations:
    score1 := 42;
    score2 := 13;
    total_score := score1 + score2;
    print("total_score is %\n", total_score); // => total_score is 55

    print("8 / 3 is %\n", 8 / 3); // => 8 / 3 is 2
    print("8.0 / 3 is %\n", 8.0 / 3); // => 8.0 / 3 is 2.666667
    print("8 %% 3 is %\n", 8 % 3); // => 8 % 3 is 2
    
    // (1) Dividing by zero
    // print("8 / 0 is %\n", 8 / 0); // => Error: Division by zero.
    // print("8.0 / 0 is %\n", 8.0 / 0); // => Error: Division by zero.
    z := 0;
    // print("8 / z is %\n", 8 / z); // => Runtime error, program stops after this line

    // Mixing of different types:
    a: s32 = -5_069_105;
    b: u8  = 10;
    c: u16 = 50;
    d := a + b; // => d is -5068898
    print("d is %\n", d); // => 
    // total_score *= 3.14; // Error: Number mismatch. Type wanted: s64; type given: float32.
    message := "YOU WON!";
    // score3 := total_score + message; 
    // => Error: Type mismatch between the arguments of binary operator + (left type: s64; right type: string).

    // Size of integers:
    // This number won't fit into 16 bits
    // i: s16 = 80000;  // => Error: Loss of information (trying to fit 64 bits into 16 bits). Can't do this without an explicit cast. Type wanted: s16; type given: s64.
    // -1 is signed, so it is out of range of what a u32 can store. 
    // j: u32 = -1; // => Error: Number signed-ness mismatch. Type wanted: u32; type given: s64.    
    // b = c; // Error: Loss of information (trying to fit 16 bits into 8 bits). Can't do this without an explicit cast. Type wanted: u8; type given: u16.

    // Casting:
    b = cast(u8) c;
    b = xx c;
    // cast u8 to float works:
    f: float;
    g: u8 = 74;
    f = cast(float) g;
    print("%\n", f); // => 74
    // cast error at runtime:
    // b = cast(u8) a;
    // => Cast bounds check failed.  Number must be in [0, 255]; it was -5069105.  Site is D:/Jai/The Book of Jai/3_Constants_Variables_Types_Operations/code/5_numbers.jai:19. Panic.
    // b = xx a; // => Error
    b = cast, no_check(u8) a;
    print("a is % and b is %\n", a, b); // => a is -5069105 and b is 207
    a, b += 1;
    print("a is % and b is %\n", a, b); // =>  is -5069104 and b is 208
 
    // Casting float to integer type truncates:
    pi := 3.14; 
    e: u8;
    e = cast(u8) pi;
    e = xx pi;
    print("e is %\n", e); // => e is 3

    // Precedence
    count := 10;
    print("%\n", count/2 - 1);   // => 4
    print("%\n", (count/2) - 1); // => 4
    print("%\n", count/(2 - 1)); // => 10
}
```

We talked about the different number types in § 5.1.2

### 6.2.1 - Comparison operators
We encountered == and != in § 6.1.1.
Numbers have a natural ordering, so they can also be compared with <, <=, > and >=.  
An expression formed with these also results in a bool value:   
`-1 < 42;  // equals true`

### 6.2.2 - Arithmetic operators
The usual +, -, * and /, % operators are defined for numbers, with abbreviations +=, -=, *= and /=:  `a *= 5;` is the same as `a = a * 5;`.  
Integer division truncates. Modulo operator % doesn't work for floats.

Division by zero results in a compile-time error if the compiler can see it, but in most cases you get a runtime panic with a stack strace; see line (1) and following.

### 6.2.3 - Mixing of different types
Different int types can be mixed, int and float types cannot: see line (2).

Addition (+) is only defined for numbers, not for strings, as we see in line (3).

Line (4) and following: Any number literal or variable can be assigned to a variable if the variable has a ‘bigger’ type than the literal (widening), that is: if it can accommodate the literal; this is _implicit conversion_.
For example, s8, s16, u32 will automatically cast to s64.
But in many cases, Jai blocks the conversion, when the receiving type is too small, or when you want to put a signed integer into an unsigned type.

Conversions cause a lot of bugs in C/C++, that’s why Jai only allows implicit type conversions that make sense.

### 6.2.4 - Casting of values
Line (5) and following: In cases where the compiler indicates an assignment is not possible (for example: to put a bigger type into a smaller type), you can try to force an explicit cast (conversion) with :    **n = cast(type) m;**

Casting will not always work as you can see in line (6). Cast operations check the range of the value they are casting; if information is lost, that's an error, but it's a runtime error:  

Explicit cast of a float to an int works, but the value is truncated, as you see in line (7):

If you're rally sure what you're doing, you can turn off the check at runtime with:  **cast, no_check(type)**
`b = cast, no_check(u8) a;`
This gives an added performance bonus. 

If there is information loss, you can _truncate_ the bits you don't care about, when you are very sure nothing wrong will happen with:
**cast, trunc(type)** 

### 6.2.5 - Autocasting with xx
Automatic casting can be used when the compiler can infer what casting has to take place at a certain moment, this is indicated with **xx**:  
xx variable;   	// autocast variable to whatever type is needed  
Example:   
`b = xx c;`

But with xx the run-time casting checks are still in place.  
`b = xx a;`    
fails with the same previous error as when doing a cast(u8) a;

In the float to int example, this works but truncates:  
`e = xx pi;`

### 6.2.6 Complex expressions and precedence
Arbitrarily complex expressions can be formed with boolean and other operators, which can quickly become unreadable.
The same [precedence rules as in C](https://www.tutorialspoint.com/cprogramming/c_operators_precedence.htm) are followed, but you can override these by using parentheses to make the expression more readable, as the code in line (7) shows.

### 6.2.7 Bitwise operators


### 6.2.8 Formatting

### 6.2.9 Random numbers