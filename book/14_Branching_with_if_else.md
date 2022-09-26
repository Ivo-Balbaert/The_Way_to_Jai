# Chapter 14 - Branching with if else

In order to make our code more flexible, we need to have control structures that allow us to branch code or repeat code on whether or not a condition is true. This condition can be any boolean or boolean expression.  
The condition after an if, while or other code after for doesn’t need to be surrounded by parentheses (), as is the case in C or many other languages..  
All constructs we discuss here define their own scope in their code blocks, so they can contain local variables.   
In this section we discover the branching, in the next section the looping capabilities.

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
    
    if dead {       // (2)
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

In line (1) we see a simple if testing a bool (note that we don't have to write if dead == true). In line (2) we provide two branches, one for the true case, the other for the false case.  
Line (3) shows all expressions with ==, !=, <= and so on, as well as all bool operators can be used to make conditions.  

### 14.1.1 One-liners
Lines (4) and (5) show one-line if statements; a `then` can be used for clarity, but is optional, unless needed to make parsing unambiguous. When the body of the if contains only one statement, { } can be left out. It is recommended to use ( ) around the condition in one-liners for readability.	  

Lines (6) and (7) show multi-line or nested if-else if-else statements. The else if and else are optional.

### 14.1.2 The classical C error 
A common C error using = instead of == by error like
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
ifx returns a value, which can be used to make or assign to a variable.

## 14.3 Case branching
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
Following line (2) the **#through** directive is used in an if-case statement. This directive ensures that a fall_through to the next case occurs, so that this branch is also executed. So this is the exact opposite behavior as in C, where you have to write `break` in order not to fall-through.  

If-case statements work on integers, strings, enums, bools, arrays, and floats (but be very careful when using if-case statements with floats since floating point numbers approximate values). 

## 14.3.1 Using if-case with enums and #complete
Starting in line (3), we see an if-case used to select on an enum value. In this case you most probably would like to test all possible enum values. This can be done by using the **#complete** directive after the if:  
`if #complete var ==`  
If a possible enum case is missing while specifying #complete, you get the compiler error:  
`Error: This 'if' was marked #complete...
... but the following enum value was missing:`

If you want a multiple lines to be executed in a case, just write them one after the other (see case 1). For readability, you could enclose the block in {}, and also in general indent the if-case statement as in the code example.

## 14.4 Test on empty variables
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

As you can see this makes for easy tests on 0 numbers, empty strings and null pointers:   
`if !ptr`  return; // ptr is a null pointer, return 


## 14.5 Other useful if tests
See _14.5_if_tests.jai_:

```c++
#import "Basic";

main :: () {
    // Test if n is an even or uneven number:
    n := 108;
    if n % 2 == 0 print("% is an even number\n", n); // (1)
    // => 108 is an even number
    if (n & 1) == 0 print ("even\n"); // (2) => even, can also be written as if n & 1
    n = 109;
    if n % 2    print("uneven\n"); // (3) => uneven
}
```

- Test if n is an even or uneven number: 
    see line (1) and (2), so if n % 2, n is uneven.
    




