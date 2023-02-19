# Chapter 5 – Constants, variables, types and operations

## 5.1 - Data, literals and types

### 5.1.1 Data and types
You've probably heard the saying that information (data) is one of the most valuable assets. But what is data really? 

Programs and applications are all about data value manipulation. _Data_ can come as input from diverse sources (user input, from files, from a database, from the network, and so on). It is temporarily stored in memory and modified, which then results in an output of some sort. This is printed, displayed on a screen, stored in a file or database, sent over the network to a client, and so on.  

If all data were the same, it would be a lot more difficult to make good use of it. Instead, data values have a _type_. Simple data values are often called _literals_. Literal values are the stuff data is made of; they are constant at compile-time.

Various types exist, like:  
    * _integers_, which are whole numbers (7, 42, 0, -3)  
    * _floats_, which are decimal numbers (3.14, 5.98e24)   
    * _strings_ ("Hello", "Tokyo", "世界!")  
    * _booleans_, which are yes/no, on/off, true/false (the only values are true and false)    
and so on.   
These are the **basic**, **fundamental** or **primitive** types in Jai, called respectively **int**, **float**, **string** and **bool**. 

Jai also has some mechanisms to create **composite** or **custom** types, like arrays (see § 18) and structs (see § 12).  

The type determines how a data value looks like and what can be done with it, that is: what _operations_ can be performed on these values.

Operations use special _operator_ characters, like + for addition.

In our programs, data is stored in **constants** or **variables** which also have some type, and take up memory in the computer. Each type prescribes how much memory it needs, which is a number of bytes (b) (As you probably know, 1 byte contains 8 bits, and a bit is either 0 or 1).  

Memory is for program performance like water is for life.
So it is important that we don't use (waste) too much memory. This also means that our program data values better be packed together in memory. This is done by storing values of composite data together in successive (_contiguous_) places in memory, so that reading in data from various caches will be much faster, or as it is phrased: _locality is maximized_.  

Values, constants and variables combined with operators form _expressions_, like `(a + b) * 3`. Expressions result in a value, which can be assigned to other variables, like `x = (a + b) * 3;`, forming a _statement_.  
Each statement in Jai ends with a semi-colon `;` and uses one code line for best readability.

Values of different types don't easily combine in operations, often the values of one type have to be _converted_ or _casted_ to another type. For example: in order to sum its value with another number, the string value `"42"` must first be converted to a number.    
_Question:_ How would you convert `"Hello"` to a number?  
Often these conversions won't work, and you'll get a compiler error.

Jai is a _strongly_ and _statically typed_ language: the compiler must know the types of all the program’s constants, variables and expressions at compile time, and a variable cannot change type, like from number to string as in dynamic languages. This allows Jai to run fast at runtime.
> Except when the variable has type Any (see § 9.5): variables of all types can be cast to Any.  
 
Conversion of the type of a variable is strictly controlled, and operations can only work on certain types. This all adds up to better error-checking by the compiler, and thus more robust, safer and much faster programs. 

You can and often must indicate the type explicitly, but the compiler can also _infer_ many types (see § 5.3.1 case 3) to ease the task of the programmer here.

### 5.1.2 The primitive types
Here are some examples for these types:

**bool** :	`true` and `false` values. They take up 8 bits (1 byte) of memory, and are used to test upon in conditions, so that program flow can be changed.

**int** : for example `42`, `0b10` (a binary 2), `0x10` (a hexadecimal with decimal value 16). Underscores can be optionally used to separate digit groups as in: `16_777_216` or `0b1010_0010_0101_1111` (a binary with decimal value 41567).  
Eight types exist according to their size (number of bytes) and whether they are positive or signed(these can have a negative sign):   

	`s8` or `u8`   - signed and unsigned 1 byte (or 8 bit) integers,  
        range:  -127 to 128 or 0 to 255
	`s16` or `u16` - signed and unsigned 2 byte integers,  
        range: -32768 to +32767 or 0 to 65,535
	`s32` or `u32` - signed and unsigned 4 byte bit integers,  
        range: -2,147,483,648 to +2,147,483,647 or 0 to 4,294,967,295
	`s64` or `u64` - signed and unsigned 8 byte (or 64 bit) integers,  
        range: -9,223,372,036,854,775,808 to +9,223,372,036,854,775,807 or 0 to 18,446,744,073,709,551,615
    (Coming: `s128` and `u128`)

`int` defaults to `s64`

**float** : literals are of the form `3.141592` or `5.98e24`, with a `.` for separating the decimal part, and an `e` for indicating the power of 10 (exponent).  
Two floating point number types exist according to their size, they are both signed:

	`float32` - 4 byte (32 bit), single-precision
	`float64` - 8 byte (64 bit), double-precision 

`float` defaults to `float32`  
Use the `0h` prefix to specify floats in hex, in IEEE-754 format. 

Module _Math_ contains the minimum and maximum range values for integer and float types as constants: FLOAT32_MIN, FLOAT32_MAX, S16_MIN, S16_MAX, and so on.


**string** : the most common data type, which we have already used, for example: `"Hello from Jai!"`.   
_Question_: Why are these values strings?  "42", "false" or "0b10".  
Indeed all types can disguise as string when surrounded by "".

**void** : this is a special type of size 0, with no values. It is used when a variable has no value. Other types cannot cast to it.

Jai has no explicit character type. The **#char** directive on a single character string gives the numeric value of the ASCII character, inferred as type s64; for example:		
    `#char "1"; // this is 49`  
(consult an [ASCII table](https://www.rapidtables.com/code/text/ascii-table.html))

### 5.1.3 Using print to display a value
See *5.1_literals.jai*:

```c++
#import "Basic";

main :: () {
    print("Hello, Sailor!\n"); // => Hello, Sailor!
    // This doesn't work:
    // print(42);  // (1) =>  Error: Type mismatch. Type wanted: string; type given: s64.
    // print(false); // =>  Error: Type mismatch. Type wanted: string; type given: bool.

    // But these do work:
    print("%\n", 42);    // => 42
    print("%\n", false); // => false

    print("The type of % is %\n", "Hello, Sailor!", type_of("Hello, Sailor!"));
    // (2) => The type of Hello Sailor! is string
    print("The type of % is %\n", 42, type_of(42)); 
	// => The type of 42 is s64
    print("The type of % is %\n", false, type_of(false)); 
	// => The type of false is bool
}
```

Try to print out a number (line (1)); you'll see that this doesn't work. But printing a string is no problem, why is this?    
The print procedure only accepts   
- a string, 
- or a format string with arguments to be substituted in the % placeholders.    
If you use the print procedure with only 1 parameter, then this parameter must be of type string. If not, you for example in `print(1);` get the **Error: Type mismatch. Type wanted: string; type given: s64.**

    print(1);

    c:/jai/modules/Basic/Print.jai:386,10: Info: ... in checking argument 1 of call to print.
    print :: (format_string: string, args: .. Any, to_standard_error := false) -> bytes_printed: s64 { 

The error text shows that the 1st argument needs to be a string, or that it is meant to be a format string, so that you can specify what you want to print.

```c++
 	print ("I greet you: %\n", "Hello, Sailor!");  // => I greet you: Hello, Sailor!
```

The print procedure uses **%** to indicate insertion points for values: the value is substituted for % in the format string.   Unlike many other languages, you don't need to specify what kind of thing (which type) is being printed, and it handles complex types too. There is no need for any indication of the type as is done in C (e.g. %d for an integer, or %s for a string) because the Jai compiler knows the types of all print arguments. However, if you want any special formatting of the thing to be printed, you must handle that separately.   
To make the print-out more readable, place a new-line (\n) at the end of the format string.

### 5.1.4 type_of()
All things in Jai have a type, which we can find out with the **type_of()** procedure. In program 5_1_literals.jai we applied this to a number of literals, starting from line (2).

## 5.2 - Constants
### 5.2.1 _Problem_: What if we need the same literal many times in code?
Suppose your program needs to calculate a lot of results using the mass of the earth, which is approximately 5.97219e24 (expressed in kg), a value that doesn't change. Would you rather write this number many times in your program, perhaps making copy mistakes? What if you later want to change this number to a more accurate one, you would have to change it in perhaps 10 or more places!  

### 5.2.2 _Solution_: Constants
The solution is to give such a **constant** a meaningful name, like:  
    `MASS_EARTH :: 5.97219e24;     // in kg`
and the :: syntax to indicate a declaration of a constant.   
Do this in only one place, and then use that name in all places in code where that value is needed. At compile-time, the compiler will substitute the value for the constant's name everywhere.

Here is an example program: See *5.2_constants.jai*

```c++
#import "Basic";

// global scope:
MASS_EARTH0 : float : 5.97219e24;  // (1) in kg
MASS_EARTH :: 5.97219e24;          // (2)
COMP_CALC :: #run (234 * 15);      // (2B)

main :: () {
  MASS_MARS :: MASS_EARTH * 0.15;  // (3)
  print("The earth mass is %\n", MASS_EARTH);
  // => The earth mass is 5972189887017193070000000

  print("I was computed at compile time: %\n", COMP_CALC); 
  // => I was computed at compile time: 3510

  // MASS_EARTH = 5.98e24; // => (4) Error: Attempt to assign to a constant.

  print("%\n", type_of(MASS_EARTH));     // (5) => float32
  print("%\n", is_constant(MASS_EARTH)); // (6) => true
  print("%\n", is_constant("Hello"));  // => true
}
```
By convention, the name of a constant is all uppercase, and as with numbers, multiple parts can be separated by an _.  
Constants declared out of the main() procedure are defined in a _global scope_, meaning that they are known in the whole program (see § 7).  
Line (1) shows that you can declare the type of a constant. But this isn't necessary: in line (2) the constant is declared without type, and the compiler infers the type.   
Notice that by omitting the type, we get the typical **::**  
`MASS_EARTH :: 5.97219e24;`  
No let, imm or const (as used in other languages) is necessary before the constant's name.

Needless to say that you can't define two or more constants with the same name. Test out what error you get! The same goes for variables, procedure names, and so on (see § 5.4 2)).  
In line (2B) we use `#run` to calculate an expression at compile-time, so that `COMP_CALC` is really a constant.   
In line (3), we use MASS_EARTH to calculate the mass of planet Mars, which is also declared as a constant. Because MASS_MARS is declared inside main(), it is only known in that _local scope_.

A constant cannot be changed, see what happens by uncommenting line (4).  

In line (5) we use type_of() procedure to show the type of MASS_EARTH, which is float32.   
In line (6) we use the **is_constant** procedure to check that MASS_EARTH is a constant.
> Why do you want to know if something is constant? Jai is very good at meta-programming, which happens at compile-time. During meta-programming you often want to be sure if an expression is a compile-time constant or not.

Constants in Jai include: static values, enums, structs and procedures.
main (and any other procedure) also has the `::` indicator. This is because main is a procedure, and all procedures are constant values: they will not rebind (get a different value) at run-time.

## 5.3 - Variables

For most values in programs, you want to be able to change their value, that's why you need **variables**. A variable is a name (identifier) given to a memory location that contains a data value which can change (is _mutable_). Again no var or mut is necessary before the variable name to indicate this. The value of a variable has a type, which cannot be changed.  
Examples of variable names are:   
`counter`, `valid_date`, `first_name`  
The names start with a lowercase letter, and multiple parts of a name are connected with _ .  

### 5.3.1 - How to declare variables
See *5.3_variable_declarations.jai*:

```c++
#import "Basic";

global_var := 108;  // (1)

main :: () {
    // Case 1: full type declaration and initialization: 
    counter : int = 100;
    pi : float = 3.14159;
    valid : bool = false;
    first_name : string = "Jon";
    print("counter: %\n", counter);   // => 100

    // Case 2: only type declaration, no explicit initialization 
    // (the variables have a default value of zero):
    counter2 : int;   
    print("counter2: %\n", counter2);       // => 0
    pi2 : float;     
    print("pi2: %\n", pi2);                 // => 0
    valid2 : bool; 
    print("valid2: %\n", valid2);           // => false
    first_name2 : string;   
    print("first_name2: %\n", first_name2); // => ""

    // change default value afterwards:
    counter2 = 100;
    first_name2 = "Jon";
    print("counter2: %\n", counter2);       // => 100
    print("first_name2: %\n", first_name2); // => "Jon"
  
    // Case 3: only initialization (type is inferred):
    counter3 := 100;         // an int
    pi3 := 3.14159;          // a float
    valid3 := false;         // a bool
    first_name3 := "Jon";    // a string
    print("pi3 is of type %, value %.\n", type_of(pi3), pi3); // => pi3 is of type float32, value 3.14159.
    print("counter3: %\n", counter3); // => 100
  
    // Case 4: uninitialized declaration (no default value is given):
    counter4 : int = ---;
    average : float = ---;
    print("counter4 contains the value %\n", counter4); // => 31525674139189348
    print("average contains the value %\n", average);  // => 0

    print("the global var is %\n", global_var); // => the global var is 108

    // char literal
    f := #char "1";     // (2) Inferred as s64. f has the value of the ASCII character '1'
    print("f is % and has type %\n", f, type_of(f)); 
    // => f is 49 and has type s64

    varv: void;
    print("varv is %\n", varv); // (2B) => varv is void
}
```

**Case 1:** type and value  
The full format for declaring a variable is: 
    name : type = value,  like in:
  	
`first_name : string = "Jon";`

The : type is called the _type declaration_, and the = value the  _initialization_.  

**Case 2:** only type  
However you don't need to provide both type and value: 
if you do only a type declaration and skip the value, you'll get a _default zero value_: 					

`counter : int;  	// default value of 0`

This default value is 0 for numbers, false for bool, the empty string "" for strings.

>In C such variables have a random value, because they get assigned a random free location in memory. This can cause errors later on, so C programmers are advised to initialize their variables immediately. This problem cannot occur in Jai: here variables are by default initialized to a "zero" value, which reduces the mental load for the developer ("have I already initialized these variables or not?"). 

Changing a value from a previously declared variable is done with the assignment operator **=**  
		    `counter = 100;`

**Case 3:** only value  
We've already seen that the compiler often can infer the type from the given value. If you skip the type - notice that you then get the := , then the type will be inferred from the value:
		    `first_name := "Jon";`  
In practice, this will be the format mostly used.

**Case 4:** no default value is given - explicit un-initialization with **---**   
Giving variables a default zero value (Case 3) is sometimes unnecessary, because you will supply (or calculate) the values yourself later in the program. In such a case you can skip the default zero initialization (and so gain some performance) by leaving the variable uninitialized with the **---** symbol as in: 
		    `varname : type = ---;`

Example:    `average : float = ---;`

This way you get the same behavior as in C. This could cause undefined behavior: the variables can contain any value that was left over from previous use at the assigned memory location, but it will contain mostly zeros. Don’t forget to initialize the variable afterwards with a normal assignment!

`global_var` in line (1) is defined in _global scope_, known and mutable throughout the entire program, so handle it carefully!.  
In line (2) we see a #char literal in a variable f, which has type s64.  
In line (2B) we see a variable varv of type void, which also prints out void.  

>Schematically:  
>  ::	defines a constant, it is a compile-time assignment 
>  :=	defines a variable, it is a run-time assignment

## 5.4 - Errors when defining variables
Here are the errors that can occur when defining a variable incorrectly:  

1] When a variable hasn't been given a type:  
   `counter5 = 101;` // => **Error: Undeclared identifier 'counter5'.**  
    _Reason_:
    = doesn't do type inference, only := does  
    _Solution_: 
    Write `counter5 := 101;` or `counter5 : u8; counter5 = 101`;

2] When a variable with the same name has already been used:  
  `counter := 42;` // => **Error: Redeclaration of variable 'counter'.**  
  _Reason_:
    duplicate variable (or function, structs, ...) names are not allowed  
  _Solution_: 
    Change the name like `counter1 := 42;`

3] When a variable `counter` has previously been declared with type int:  
  `counter = "France";` // => **Error: Type mismatch. Type wanted: int; type given: string.**  
  _Reason_:
    A variable can't contain a value with a type different than its declared type.  
  _Solution_: 
    Change the value like `counter1 := 43;`  
This shows that Jai is a **strongly typed** language.

## 5.5 - Multiple assignment
See *5.4_variable_declarations2.jai*:

```c++
#import "Basic";

main :: () {
// declaring and assigning in one code-line:
    n1: u8; m1: u8; n1 = 12; m1 = 13; // (1)
    print("% %\n", n1, m1); // => 12 13

// compound assignment is NOT allowed:
  // n1: u8;    m1: u8;     n1 = m1 = 13; // (2) => Error: Operator '=' can only be used at statement level.
  // but write it as:
    n2, m2 : u8 = 12, 13;   // (3) Full declaration and initialization: 	
    print("% %\n", n2, m2); // => 12 13
// or shorter with type inference:
    n3, m3 := 12, 13;
// works also for one value:
    p, q, r := 13;  
    print("% % %\n", p, q, r); // => 13 13 13

// values of different types or expressions:
    x, y := 1, "hello";      // an int and a string
    print("x is % and y is %\n", x, y);         // => x is 1 and y is hello
    s, t := 2 + 3, 2 * 3;
    print("s is % and t is %\n", s, t);
    s1, t1 := #run(2 + 3), #run(2 * 3);
    print("s1 is % and t1 is %\n", s1, t1);     // => s is 5 and t is 6

  // i, j : int;
  // i, j = n1 + 1, m1 + 1;
  // or shorter:
    i, j := n1 + 1, m1 + 1;

  // multiple declaration, default values, and subsequent assignment:
    n4, m4 : int;
    print("n4 is % and m4 is %\n", n4, m4);     // => n4 is 0 and m4 is 0
    n4, m4 = 1, 2; 
    print("n4 is % and m4 is %\n", n4, m4);     // => n4 is 1 and m4 is 2
}
```

In line (1) we see how several variables are declared and initialized on one line:   `n1: u8; m1: u8; n1 = 12; m1 = 13;`
This can of course be shortened.   
A compound assignment like in line (2)
is not allowed, but you can write: `n3, m3 := 12, 13;`  
The right-hand sides in such a _multiple assignment_ can also contain expressions, even calculated at compile-time with #run.  
If wanted, declaration and assignment can be on separate lines.

## 5.6 - Swapping values
See *5.5_swapping.jai*:

```c++
#import "Basic";

main :: () {
    n := 2;
    m := 3;
  // n, m = m, n;                        
    print("n is % and m is %\n", n, m); // (1) => n is 3 and m is 3

    s, p := "abc", 13;
  // this gives an error:
  // s, p = p, s; // => Error: Type mismatch. Type wanted: string; type given: s64.  
}
```

A swap like n, m = m, n; is allowed, but doesn't work in Jai like you would expect (see line (1)): both variables get the same value. It works like this: `x, y = y, x` does `x = y; y = x;` and not like in Python for example. The reason is when one gets too picky about what order things happen in, this causes problems for compiler optimizations.    
Also when n and m are of different types an error results, because then the variables would have to change type, which is not allowed.
But see § 17.10 for a swap procedure and § 22.2.3 for built-in versions.  

## 5.7 - More about printing
print is a native routine.                                                              
### 5.7.1 - Printing more than one value
See *5.6_printing.jai*:

```c++
#import "Basic";

main :: () {
    n := 7;
    m := 42;
    // print("m is", m); // =>  Warning: Incorrect number of arguments supplied to 'print': The format string requires 0 arguments, but 1 argument is given.
    print("n is % and m is %\n", n, m);   // (1) => n is 7 and m is 42
    print("n is %1 and m is %2\n", n, m); // (2) => n is 7 and m is 42
    print("m is %2 and n is %1\n", n, m); // (3) => m is 42 and n is 7
    print("%2 %1 %2\n", n, m); // => 42 7 42
    // print("% %", n, m, counter); // =>  Warning: Incorrect number of arguments supplied to 'print': The format string requires 2 arguments, but 3 arguments are given.

    // printing % with %%:
    value := 50;
    print("Everything is on sale for %1%% off!\n", value); // (4)
    // => Everything is on sale for 50% off!
    bytes_printed := print("Everything is on sale for %1%% off!\n", value); // (4B)
    // => Everything is on sale for 50% off!
    print("%", bytes_printed); // => 35
}
```

`print` can take two or more arguments: the first is a format string containing text and % substitution symbols. `print` displays the text where each of the % symbols is replaced by an argument, in the order the arguments appear. 
`print` can also be used to display two or more values as is shown in line (1):  
`print("n is % and m is %\n", n, m);   // (1) => n is 7 and m is 42`

The substitution % symbols can also take a number to indicate the position. In this way, you can change the order in which values are displayed in the format string, or use the same value more than once (see lines (2) and (3)).
	
The number of %'s and supplied values must be the same. If not you get a warning:

```c++
 print("% %", n, m, counter); // =>  Warning: Incorrect number of arguments supplied to 'print':  
```

The format string requires 2 arguments, but 3 arguments are given.
In this case only the first two values are displayed.
If you want to print a literal %, replace the second % with %% as in line (4). Although it is nearly always discarded, print returns the number of bytes printed, as shown in line (4B).

### 5.7.2 - The write procedures
See *5.8_write.jai*:

```c++
main :: () {
  write_string("Hello, World!\n");               // => Hello, World!
  write_strings("Hello", ",", " World!", "\n");  // => Hello, World!
  write_number(-42);            // => -42
  write_nonnegative_number(42); // => 42
}

/*
Hello, World!
Hello, World!
-4242
*/
```

Jai has some lower-level write procedures which are defined in modules _Preload_ and *Runtime_Support.jai*, so they don’t need the _Basic_ module. Use these when you don't want to import the _Basic_ module.

### 5.7.3 - Printing Unicode
See *5.9_printing_unicode.jai*:

```c++
#import "Basic";

main :: () {
  print("Hello world!\n");
  print("Bonjour tout le monde!\n");
  print("Hallo Wereld!\n");
  print("¡Hola, mundo!\n"); // (4)
  print("Καλημέρα κόσμε!\n");
  print("你好！\n"); // prints "hello" in Chinese.
  print("こんにちは 世界!\n"); 
  print("!ہیلو ، دنیا\n");
  print("ສະ​ບາຍ​ດີ​ຊາວ​ໂລກ\n");
  print("👋🌍❗\n");

  print("\u03C0");  // => π
}

/*
Hello world!
Bonjour tout le monde!
Hallo Wereld!
¡Hola, mundo!
Καλημέρα κόσμε!
你好！
こんにちは 世界!
!ہیلو ، دنیا
ສະ​ບາຍ​ດີ​ຊາວ​ໂລກ
👋🌍❗
π
*/
```
As we see from line (4) onward, we can print any Unicode string.
In general, print out any Unicode character like this: `print("\u03C0");`

## 5.8 - General naming conventions
The following naming conventions are more or less standard:
- snake_case for identifiers (procedures, variables, macros, ...): birth_date, is_constant()
- Capitalized_Snake_Case for types and imports: Entity, Enemy_Entity, Command_Line
- Full Capitalized_Snake_Case for constants and enum members: MASS_EARTH, .SOUTH

Note that these conventions are not enforced in the language, and you'll find exceptions to these rules in the standard library distribution. 

[5B - Identifier Backslashes](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/5B_Identifier_Backslashes.md)   
[5C - ASCII table](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/5C_Ascii_table.pdf)   
