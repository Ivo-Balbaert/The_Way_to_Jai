# Chapter 5 – Constants, variables, types and operations

## 5.1 - Data, literals and types

### 5.1.1 Data and types
You've probably heard the saying that information (data) is one of the most valuable assets. But what is data really? 

Programs and applications are all about data value manipulation. _Data_ can come as input from diverse sources (user input, from files, from a database, from the network, and so on). It is temporarily stored in memory and modified, which then results in an output of some sort. This is printed, displayed on a screen, stored in a file or database, sent over the network to a client, and so on.  

If all data where the same, it would be a lot more difficult to make good use of it. Instead, data values have a _type_. Simple data values are often called _literals_. Literal values are the stuff data is made of; they are constant at compile-time.
  

Various types exist, like:  
    * _integers_, which are whole numbers (7, 42, 0, -3)  
    * _floats_, which are decimal numbers (3.14, )   
    * _strings_ ("Hello", "Tokyo")  
    * _booleans_, which are yes/no, on/off, true/false (the only values are true and false)    
and so on.   
These are the **basic** or **primitive** types in Jai, called respectively **int**, **float**, **string** and **bool**. 

Jai also has some mechanisms to create **composite** or **custom** types, like arrays (see ??) and structs (see ??).  

The type determines how a data value looks like and what can be done with it, that is: what _operations_ can be performed on these values.

Operations use special _operator_ characters, like + for addition.

In our programs, data is stored in **constants** or **variables** which also have some type, and take up memory in the computer. Each type prescribes how much memory it needs, which is a number of bytes (b) (As you probably know, 1 byte contains 8 bits, and a bit is either 0 or 1).  

Memory is for program performance like water is for life.
So it is important that we don't use (waste) too much memory. This also means that our program data values better be packed together in memory. This is done by storing values of composite data together in successive (_contiguous_) places in memory, so that reading in data from various caches will be much faster, or as we say: _locality is maximized_.  

Values, constants and variables combined with operators form _expressions_, like `(a + b) * 3`. Expressions result in a value, which can be assigned to other variables, like `x = (a + b) * 3;`, forming a _statement_.  
Each statement in Jai ends with a semi-colon `;` and uses one code line for best readability.

Values of different types don't easily combine in operations, often the values of one type have to be _converted_ or _casted_ to another type. For example: in order to sum its value with another number, the string value `"42"` must first be converted to a number.    
_Question:_ How would you convert `"Hello"` to a number?  
Often these conversions won't work, and you'll get a compiler error.

Jai is a _strongly_ and _statically typed_ language: the compiler must know the types of all the program’s constants and variables at compile time, and a variable cannot change type, like from number to string as in dynamic languages.
> Except when the variable has type Any (see ??).  
 
Conversion of the type of a variable is strictly controlled, and operations can only work on certain types. This all adds up to better error-checking by the compiler, and thus more robust, safer and much faster programs. 

You can and often must indicate the type explicitly, but the compiler can also _infer_ many types (see ??) to ease the task of the programmer here.

### 5.1.2 The primitive types
Here are some examples for these types:

**bool** :	`true` and `false` values. They take up 8 bits (1 byte) of memory, and are used to test upon in conditions, so that program flow can be changed.

**int** : for example `42`, `0b10` (a binary 2), `0x10` (a hexadecimal 16). Underscores can be optionally used to separate digit groups as in: `16_777_216` or `0b1010_0010_0101_1111`.  
Eight types exist according to their size (number of bytes) and whether they are positive or signed(can have a negative sign):   

	`s8` or `u8`   - signed and unsigned 1 byte (or 8 bit) integers,  
        range:  -127 to 128 or 0 to 255
	`s16` or `u16` - signed and unsigned 2 byte integers,  
        range: -32768 to +32767 or 0 to 65,535
	`s32` or `u32` - signed and unsigned 4 byte bit integers,  
        range: -2,147,483,648 to +2,147,483,647 or 0 to 4,294,967,295
	`s64` or `u64` - signed and unsigned 8 byte (or 64 bit) integers,  
        range: -9,223,372,036,854,775,808 to +9,223,372,036,854,775,807 or 0 to 18,446,744,073,709,551,615
	
int defaults to s64

**float** : literals are of the form `3.141592` or `5.98e24`, with a `.` for separating the decimal part, and an `e` for indicating the power of 10 (exponent).  
Two floating point number types exist according to their size, they are both signed:

	`float32` - 4 byte (32 bit) 
	`float64` - 8 byte (64 bit) 

float defaults to float32  
Use the `0h` prefix to specify floats in hex, in IEEE-754 format. 

**string** : the most common data type, which we have already used, for example: `"Hello from Jai!"`. 
_Question_: Why are these values strings?  "42", "false" or "0b10".
Indeed all types can be disguised as string.

**void** : this is a special type of size 0, with no values. It is used when a variable has no value.

Jai has no explicit character type. The **#char** directive on a single character string gives the numeric value of the ASCII character, inferred as of type s64; for example:		
    `#char "1"; // this is 49`  
(see for example this [ASCII table](https://www.rapidtables.com/code/text/ascii-table.html))

### 5.1.3 Using print to display a value
(See program 5_1_literals.jai)

Try to print out a number; you'll see that this doesn't work. But printing a string is no problem, why is this?    
The print procedure only accepts a string, or a format string with arguments to be substituted in the % placeholders.  
If you use the print procedure with only 1 parameter, then this parameter must be of type string. If not, you get the **Error: Type mismatch. Type wanted: string; type given: s64.**

    print(GREETING);         // => Hello, Sailor!
    print(1);

    c:/jai/modules/Basic/Print.jai:386,10: Info: ... in checking argument 1 of call to print.
    print :: (format_string: string, args: .. Any, to_standard_error := false) -> bytes_printed: s64 { 

The error text shows that the 1st argument needs to be a string, but that in fact it is meant to be a format string, so that you can specify what you want to print.

```
 	print ("I greet you: %\n", GREETING);  // => I greet you: Hello, Sailor!
```

The print procedure uses **%** to indicate insertion points for values: the value is substituted for % in the format string. Unlike many other languages, you don't need to specify what kind of thing is being printed, and it handles complex types too. There is no need for any indication of the type as is done in C (e.g. %d for an integer, or %s for a string) because the Jai compiler knows the types of all print arguments. However, if you want any special formatting of the thing to be printed, you must handle that separately.   
To make the print-out more readable, place a new-line \n at the end of the format string.

```
#import "Basic";

main :: () {
    print("Hello, Sailor!\n"); // => Hello, Sailor!
    // This doesn't work:
    // print(42);  // =>  Error: Type mismatch. Type wanted: string; type given: s64.
    // print(false);

    // But these do:
    print("%\n", 42);    // => 42
    print("%\n", false); // => false

    print("The type of % is %\n", "Hello, Sailor!", type_of("Hello, Sailor!"));
    // => The type of Hello Sailor! is string
    print("The type of % is %\n", 42, type_of(42)); 
	// => The type of 42 is s64
    print("The type of % is %\n", false, type_of(false)); 
	// => The type of false is bool
}
```
### 5.1.4 type_of()
All things in Jai have a type, which we can find out with the **type_of()** procedure. In program 5_1_literals.jai we applied this to a number of literals.

## 5.2 - Constants
### 5.2.1 _Problem_: What if we need the same literal many times?
Suppose your program needs to calculate a lot of results using the mass of the earth, which is approximately 5.97219e24 (expressed in kg). Would you rather write this number 10 or more times in your program, perhaps making copy mistakes? What if you later want to change this number to a more accurate one, you would have to change it in 10 or more places!  

### 5.2.2 _Solution_: Constants
The solution is to give such a constant a meaningful name, like:  
    `MASS_EARTH :: 5.97219e24;     // in kg`  
Do this in only one place, and then use that name in all places in code where that value is needed. At compile-time, the compiler will substitute the value for the name everywhere.

Here is our solution program: see **5_1.constant.jai**

```
#import "Basic";

// global scope:
MASS_EARTH0 : float : 5.97219e24;  // (1) in kg
MASS_EARTH :: 5.97219e24;          // (2)
COMP_CALC :: #run (234 * 15);      // (2B)

main :: () {
  MASS_MARS :: MASS_EARTH * 0.15;  // (3)
  print("The earth mass is %\n", MASS_EARTH);
  // (4) => The earth mass is 5972189887017193070000000

  print("I was computed at compile time: %\n", COMP_CALC); 
  // => I was computed at compile time: 3510

  print("%\n", type_of(MASS_EARTH));     // (5) => float32
  print("%\n", is_constant(MASS_EARTH)); // (6) => true
}
```

By convention, the name is all uppercase, and as with numbers, multiple parts can be separated by an _.  
Constants declared out of the main() procedure are defined in a _global scope_, meaning that they are known in the whole program.  
Line (1) shows that you can declare the type of a constant. But this isn't necessary: in line (2) the constant is declared without type, here the compiler infers the type.   
Notice that by omitting the type, we get the typical **::**		`MASS_EARTH :: 5.97219e24;`  which indicates a constant value.
No let or imm is necessary before the constant's name.

Needless to say that you can't define two or more constants with the same name. Test out what error you get! The same goes for variables, procedure names, and so on.  
In line (2B) we use `#run` to calculate an expression at compile-time, so that `COMP_CALC` is really a constant.   
In line (3), we use MASS_EARTH to calculate the mass of planet Mars, which is also declared as a constant. Because MASS_MARS is declared inside main(), it is only known in that _local scope_.

A constant cannot be changed, see what happens by uncommenting line (4).  

In line (5) we use the **type_of** procedure to show the type of MASS_EARTH, which is float32. type_of() works on nearly everything, because all things have a type.  
In line (6) we use the **is_constant** procedure to check that MASS_EARTH is a constant.
> Why do you want to know if something is constant? Jai is very good at meta-programming, which happens at compile-time. During meta-programming you often want to be sure if an expression is a compile-time constant or not.

main (and any other procedure) also has the `::` indicator. This is because main is a procedure, and all procedures are constant values: they will not rebind (get a different value) at run-time.

## 5.3 - Variables

For most values in programs, you want to be able to change their value, that's why you need **variables**. A variable is a name (identifier) given to a memory location that contains a data value which can change (is _mutable_); no var or mut is necessary before the variable name. This value has a type, which cannot be changed.  
Examples: `counter`, `valid_date`, `first_name`, and so on.
The names start with a lowercase letter, and multiple parts of a name are connected with _ .  

### 5.3.1 - How to declare variables
(See 5_3_variable_declarations.jai)  

**Case 1:** type and value  
The full format for declaring a variable is: 
    name : type = value,  like in:
  	
`first_name : string = "Jon";`

The : type is called the _type declaration_, and the = value the  _initialization_.  

**Case 2:** only type  
However you don't need to provide both type and value: 
if you do only a type declaration and skip the value, you'll get a _default zero value_: 					

`counter : int;  	// default value of 0`

This default value is 0 for numbers, false for bool, the empty string "" for strings, null for pointer types.

>Remark: 
>In C such variables have a random value, because they get assigned a random free location in memory. This can cause errors later on, so C programmers are advised to initialize their variables immediately. This problem cannot occur in Jai: here variables are by default initialized to a "zero" value, which reduces the mental load for the developer (have I already initialized these variables or not?). 

**Case 3:** only value  
We've already seen that the compiler often can infer the type from the given value. If you skip the type -- notice that you then get the := , then the type will be inferred from the value:
		    `first_name := "Jon";`  
In practice this will be the format mostly used.

Changing a value from a previously declared variable is done with the assignment operator **=**  
		    `counter = 100;`

**Case 4:** no default value is given - explicit un-initialization with **---**   
Giving variables a default zero value (Case 3) is sometimes unnecessary, because you will supply (or calculate) the values yourself later in the program. In such a case you can skip the default zero initialization (and so gain some performance!) by leaving the variable uninitialized with the **---** symbol as in: 
		    `varname : type = ---;`

Example:    `average : float = ---;`

This way you get the same behavior as in C. This could cause undefined behavior: the variables can contain any value that was left over from previous use at the assigned memory location, but it will contain mostly zeros. Don’t forget to initialize the variable afterwards with a normal assignment!

>Schematically:  
>  ::	defines a constant  
>  :=	defines a variable


## 5.4 - Errors when defining variables:



