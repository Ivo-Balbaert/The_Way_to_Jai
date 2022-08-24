# Chapter 5 – Constants, variables, types and operations

## 5.1 - Data, literals and types

### 5.1.1 Data and types
You've probably heard that information (data) is one of the most valuable assets. But what is data really? 

Programs and applications are all about data value manipulation. _Data_ can come as input from diverse sources (user input, from files, from a database, from the network, and so on). It is temporarily stored in memory and modified, which then results in an output of some sort. This is printed, displayed on a screen, stored in a file or database, sent over the network to a client, and so on.  

If all data where the same, it would be a lot more difficult to make good use of it. Instead, data values have a _type_. Simple data values are often called _literals_. Literal values are the stuff data is made of; they are constant at compile-time.
  

Various types exist, like:  
    * integers, which are whole numbers (7, 42, 0, -3)  
    * strings ("Hello", "Tokyo")  
    * floats, which are decimal numbers (3.14, )  
    * booleans, which are yes/no, on/off, true/false (the only values are true and false)    
and so on.   
These are the **basic** or **primitive** types in Jai, indicated respectively as **int**, **float**, **string** and **bool**. 

Jai also has some mechanisms to create **composite** or **custom** types, like arrays (see ??) and structs (see ??).  

The type determines how a data value looks like and what can be done with it, that is: what _operations_ can be performed on these values.

Operations use special _operator_ characters, like + and *.

In our programs, data is stored in **constants** or **variables** which also have some type, which take up memory in the computer. Each type prescribes how much memory it needs, which is a number of bytes (b) (As you probably know, 1 byte contains 8 bits, and a bit is either 0 or 1).  

Memory is for program performance like water is for life.
So it is important that we don't use (waste) too much memory. This also means that our program data values better be packed together in memory. This also implies that values of composite data are stored together in successive (contiguous) places in memory, so that _locality is maximized_. This means that reading in data from various caches will be much faster.

Values, constants and variables combined with operators form _expressions_, like `(a + b) * 3`. Expressions result in a value, which can be assigned to other variables, like `x = (a + b) * 3`, forming a _statement_.  
Each statement in Jai ends with a semi-colon `;` and uses one code line for best readability.

Values of different types don't easily combine in operations, often the values of one type have to be _converted_ or _casted_ to another type. For example: in order to sum its value with another number, the string value `"42"` must first be converted to a number.
Often these conversions don't work, like how would you convert `"Hello"` to a number?

Jai is a _strongly_ and _statically typed_ language: the compiler must know the types of all the program’s constants and variables at compile time, and a variable cannot change type, like from number to string as in dynamic languages.
> Except when the variable has type Any (see ??).  
 
Conversion of the type of a variable is strictly controlled, and operations can only work on certain types. This all adds up to better error-checking by the compiler, and thus more robust, safer and much faster programs. 

You can and often must indicate the type explicitly, but the compiler can also _infer_ many types (see ??) to ease the task of the programmer here.

### 5.1.2 The primitive types
Here are some examples for the basic types:

**bool** :	`true` and `false` values. They take up 8 bits (1 byte) of memory, and are used to test upon in conditions, so that program flow can be changed.

**int** : for example `42`, `0b10` (a binary 2), `0x10` (a hexadecimal 16). Underscores can be optionally used to separate digit groups as in: `16_777_216` or `0b1010_0010_0101_1111`.  
8 types exist according to their size (number of bytes) and whether they are positive or signed(can have a negative sign):   

	`s8` or `u8` - signed and unsigned 1 byte (or 8 bit) integers, range:  -127 to 128 or 0 to 255
	`s16` or `u16` - signed and unsigned 2 byte integers, range: -32768 to +32767 or 0 to 65,535
	`s32` or `u32` - signed and unsigned 4 byte bit integers, range: -2,147,483,648 to +2,147,483,647 or 0 to 4,294,967,295
	`s64` or `u64` - signed and unsigned 8 byte (or 64 bit) integers, range: -9,223,372,036,854,775,808 to +9,223,372,036,854,775,807 or 0 to 18,446,744,073,709,551,615
	
	int defaults to s64

**float** : literals are of the form `3.141592` or `5.98e24`, with a `.` for separating the decimal part, and an `e` for indicating the power of 10 (exponent)
2 floating point number types exist according to their size, they are both signed:

	`float32` - 4 byte (32 bit) 
	`float64` - 8 byte (64 bit) 

	float defaults to float32  
	Use the `0h` prefix to specify floats in hex, in IEEE-754 format. 

**string** : the most common data type, which we have already used, for example: `"Hello from Jai!"`. 
_Question_: Why are these values strings?  "42", "false" or "0b10".
Indeed all types can be disguised as string.

**void** : this is a special type of size 0, with no values. It is used when a variable has no value.

Jai has no explicit character type. The **#char** directive on a single character string gives the numeric value of the ASCII character, inferred as of type s64; for example:		
    `#char "1"`; // this is 49  
(see for example this [ASCII table](https://www.rapidtables.com/code/text/ascii-table.html))


