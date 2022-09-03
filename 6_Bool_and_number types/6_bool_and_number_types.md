# Chapter 6 – Bool and number types
(See 6.1_bools.jai)

## 6.1 - Boolean values
bool values `true` and `false` were discussed in § 5.1

### 6.1.1 Equal values and boolean expressions
Two values a and b can be compared with the equality operator **==**:  `a == b`.
This is a _boolean expression_ or _condition_, resulting in a bool value:
    * it is true when a and b have the same value
    * it is false in all other cases.

For example:  true == true and 1 == 1.0 are both true
The inequality operator **!=** reverses this, it gives true when the values are different:    `"Jai" != "Java"` gives true

```
n := 7;
m := 42;
print("%\n", n != m); // => true
```
In Jai you cannot compare values of a different type, for example: 
`0 == false: // => Error: Type mismatch. Type wanted: s64; type given: bool.`
Number types are an exception to this rule:   `1 == 2.0`  is allowed and returns false.

_Question_ What is the value of `"3" == 3`, why?
_Answer_ This gives an error! Error: Type mismatch. Type wanted: string; type given: s64.

### 6.1.2 The assert statement
(See 6.1
b_assert.jai)
Instead of always printing out if a bool expression is true of false, there is a handy shortcut with the **assert** procedure, defined in module _Basic_.

When the expression is true, nothing happens. When the expression is false, an assert stops the programs execution with **Assertion failed** and the line where it happened, and prints out a stack trace. A message parameter after the expression is optional, but when there is one, it is also printed out. See the example below:

```
#import "Basic";

main :: () {
  assert(5 == 5.0);
  // assert(4 == 5, "4 does not equal 5");
  // print("This is not printed");

  n := 42;
  assert(type_of(n) == int);
}

// => With line 5:
/*
d:/Jai/The_Way_to_Jai/6_Bool_and_number types/examples/6.3_assert.jai:5,3: **Assertion failed: 4 does not equal 5**

Stack trace:
c:/jai/modules/Preload.jai:334: default_assertion_failed
c:/jai/modules/Basic/module.jai:74: assert
d:/Jai/The_Way_to_Jai/6_Bool_and_number types/examples/6.3_assert.jai:5: main*/
```

assert also works with complex expressions, procedure calls, and so on.

assert is a very useful tool to make sure your program is always in a correct state. It is also very handy during debugging.

> Basic has a module parameter defined for it: ENABLE_ASSERT := true
>To increase performance for a release build, you can disable asserts by changing the import to:
>	`#import "Basic"()(ENABLE_ASSERT=false);`
> That way you can leave the asserts in your code, without incurring a performance penalty.

### 6.1.3 Boolean operators
The negation operator **!** changes a true value to false and vice-versa.
The **&&** (and) operator is true only when both operands are true. 
The **||** (or) operator is false only when both operands are false.
They operate in a 'short-circuit' manner, meaning:
for && when the 1st operand is false, the 2nd operand is not evaluated, because we know the result is false.
for !! when the 1st operand is true, the 2nd operand is not evaluated, because we know the result is false.


When b1 == true and b2 == false:

```
print("b1 and b2 is %\n", b1 && b2); 
// => b1 and b2 is false
print("b1 or b2 is %\n", b1 || b2);  
// => b1 or b2 is true
```

You can find complete truth tables [here](https://en.wikipedia.org/wiki/Truth_table).


### 6.1.4 Complex expressions and precedence
Arbitrarily complex expressions can be formed with boolean (and other) operators, which can quickly become unreadable.
The same precedence rules as in C are followed, but you can override these by using parentheses to make the expression more readable.

## 6.2 - Number types
(See 6.2_numbers.jai)

