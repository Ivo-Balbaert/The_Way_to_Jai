# Chapter 14 - Branching with if else

In order to make our code more flexible, we need to have control structures that allow us to branch code or repeat code on whether or not a condition is true. This condition can be any boolean or boolean expression.  
The condition after an if, while or other code after for doesn’t need to be surrounded by parentheses (), as is the case in C or many other languages..  
All constructs we discuss here define their own scope in their code blocks, so they can contain local variables.   
In this section we discover the branching, in the next section the looping capabilities. There is no `goto` in Jai.

## 14.1 The if-else statement
See example `14.1_if_else.jai`:

```c++
#import "Basic";

main :: () {
    dead := false;
    health := 48;

    if dead {       // (1)
        print("Game over!");
        exit;
    }
    
    if dead /* then */ {       // (2)
        print("Game over!");
        exit;
    } else {  // we are still alive!
        print("You still have a chance to win!\n");
    }

    a1 := 7;
    b1 := 8;
    if a1 == b1  // (3)
        print("They're equal!\n"); 
    else
        print("They're not equal!\n");

    b1 = 7;
    if a1 == b1 print("They're equal!\n");  // (4)
    // if (a1 == b1) print("They're equal!\n");  
    if dead then exit;                           // (5)
    
    if health >= 50 {                       // (6)
        print("Continue to fight!");
    } else if health >= 20 {
        print("Stop the battle and regain health!\n");
    } else {
        print("Hide and try to recover!");
    }

    grade := 100;                           // (7)
    if grade >= 97 {
        print("Your grade is an A+\n");
    } else if grade >= 90 {
        print("Your grade is an A\n");
    } else if grade >= 80 {
        print("Your grade is a B\n");
    } else if grade >= 70 {
        print("Your grade is a C\n");
    } else if grade >= 60 {
        print("Your grade is a D\n");
    } else {
        print("You grade is a F\n");
    }
}

/*
You still have a chance to win!
They're not equal!
They're equal!
Stop the battle and regain health!
Your grade is an A+
*/
```

In line (1) we see a simple if testing a bool (note that we don't have to write if dead == true). In line (2) we provide two branches, one for the true case (then the if branch executes, with `then` being optional), the other for the false case (then the else branch executes): only one branch executes.  
Line (3) shows all expressions with ==, !=, <= and so on, as well as all bool operators can be used to make conditions.  

### 14.1.1 One-liners
Lines (4) and (5) show one-line if statements; a `then` can be used for clarity, but it is optional, unless needed to make parsing unambiguous (for example when using <<). When the body of the if contains only one statement, { } can be left out. It is recommended to use ( ) around the condition in one-liners for readability.	  

Lines (6) and (7) show multi-line or nested if-else if-else statements. The else if and else are optional.

### 14.1.2 The classical C error
It is easy to mistake a mathematical = for a computer ==: 
a common C error using = instead of == by error like
`if a = 5 { … }	`
is caught by the compiler with:  Error: Operator '=' can only be used at statement level (see line 3B).

## 14.2 Ternary operator ifx
See example `14.2_ifx.jai`:

```c++
#import "Basic";

main :: () {
    a2 := 0;
    b2 := 100;
    c := ifx a2 > b2 10 else 1000;
    print("ternary c is %\n", c); // => ternary c is 1000
}
```
This shows the ternary operator **ifx** at work:  
    `ifx cond stat1 else stat2;` 
This is the equivalent of cond ? stat1 : stat2 in other languages.
ifx returns a value, which can be used to make or assign to a variable. The compiler checks whether the type is the same in the 2 branches. stat1 and stat2 can also be blocks of statements. Here also, the last statement must return a value. This can be just a variable, or a proc call which returns a variable. Again like in the if, then and else are optional.

## 14.3 Case branching
If you need to compare a variable against a lot of values, you would have to write a long if-else-if sequence. Jai offers you an easier way with if-case.
See example `14.3_if_case.jai`:

```c++
#import "Basic";

main :: () {
    a3 := 0;
    if a3 == {                       // (1)
        case 0;
            print("case 0\n");       // => case 0
        case 1;
            print("case 1\n");       // because a is 0, this will be ignored
        case;
            print("default case\n"); // because a is 0, this will be ignored.
    }

    a4 := 0;
    if a4 == {                      // (2)
        case 0;
            print("case 0\n"); // => case 0
        #through;
        case 1;
    // because of the #through statement, this if-case statement will print out "case 1" 
    // in addition to "case 0". 
            print("case 1\n"); // => case 1
            print("This is also in case 1!"); 
        case;
            print("default case\n"); // because there is no #through statement, this will be ignored
    }

    // if-case with enums, #complete:
    Val :: enum { A; B; C; }        // (3)
    a5 := Val.A;
    if #complete a5 == {
        case Val.A;
            print("This is Val.A case\n"); // => This is Val.A case
        case Val.B;
            print("This is Val.B case\n");
        case Val.C;
            print("This is Val.C case\n");
    }

    // using enum namespace:
    using Val;
    e := A;
    if e == {       // (4)
        case A; print("e is A\n"); // => e is A
        case B; print("e is B\n");
        case C; print("e is C\n");
    }
}

/*
case 0
case 0
case 1
This is Val.A case
*/
```

This example illustrates Jai's switch statement equivalent, using if-case (instead of switch-case like in C), see line (1):
```
 if var == {
        case valA;
            ..;
        case valB;
            ..;
        case; // default case
            ..;
    }
```
Following line (2) the **#through** directive is used in an if-case statement. This directive ensures that a fall_through to the next case occurs, so that this branch is also executed. So this is the exact opposite behavior as in C, where you have to write `break` in order not to fall-through. A common use-case is where you want to perform the same code for multiple cases.
A case branch can have multiple statements, but they don't need { }. 

The case branch without a value is the default case, when no other values match. Only one case branch is ever executed.  
If-case statements work on integers, strings, enums, bools, arrays, and floats (but be very careful when using if-case statements with floats since floating point numbers approximate values). 

## 14.3.1 Using if-case with enums and #complete
Starting in line (3), we see an if-case used to select on an enum value. In this case you most probably would like to test all possible enum values. This can be done by using the **#complete** directive after the if:  
`if #complete var ==`  
If a possible enum case is missing while specifying #complete, you get the compiler error:  
`Error: This 'if' was marked #complete...
... but the following enum value was missing:`

Line (4) shows how a using can even shorten an if-case for an enum.

If you want a multiple lines to be executed in a case, just write them one after the other (see case 1). For readability, you could enclose the block in {}, and also in general indent the if-case statement as in the code example.

## 14.4 Test on empty variables
The truthiness of a value `var`, defined in § 6.2.5.2, will determine whether an `if var`takes the if-branch or the else-branch.

> `var` is true in this broad sense when it contains a real value, then an if executes the if-branch
> `var` is false when it is zero, false, empty, null, then an if executes the else-branch

Testing on zero/empty variables can be very useful!
Because a zero value is false and any non-zero value is true, you can easily test empty-ness of a variable  with an if-statement:

```
if var {
	// var is not zero, null, empty
}

if !var {
	// var is zero, null, empty
}
```

See example `14.4_test_empty.jai`:

```c++
#import "Basic";

main :: () {
  // Check if a value var is not 0:
    var := 3.14;
    print("%\n", !var); // => false
    if var {
        print("var is not 0\n"); // => var is not 0
	}

    count := 7;
	if !count exit;    // if count is 0, stop

  // test on empty string:
    str := "Jai";
    if str  print("str is not empty\n");  // => str is not empty
    str = "";   // empty string
    if !str  print("str is empty\n");  // => str is empty

  // pointers:
    ptr: *int;
    print("%\n", ptr); // => null
    if !ptr print("This is a null pointer\n"); // => This is a null pointer
}
```

As you can see this makes for easy tests on numbers with value 0, empty strings and null pointers:   
`if !ptr`  return; // ptr is a null pointer, return 


## 14.5 Other useful if tests
See *14.5_if_tests.jai*:

```c++
#import "Basic";

main :: () {
    // Test if n is an even or uneven number:
    n := 108;
    if n % 2 == 0 print("% is an even number\n", n); // (1)
    // => 108 is an even number
    if (n & 1) == 0 print ("even\n"); // (2) => even
    n = 109;
    if n & 1  print ("odd\n"); // => odd
    if n % 2  print("odd\n"); // (3) => odd
}```

- Test if n is an even or uneven number: 
    see line (1) and (2), so if n % 2 or n & 1, n is odd.
    




