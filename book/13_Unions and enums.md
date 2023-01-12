# Chapter 13 - Unions and enums

An union is a special memory-saving kind of struct.  
An enum on the other hand is an enumeration of possible values a variable can take. Both enums and unions are types. The 'using' keyword to open up a namespace (see § 12.7) works also for enums and unions.

## 13.1 Working with unions
A union is kind of like a struct, because it is defined with different fields of possibly different sizes, like a C union. The great difference is that only one field can be active (filled with data) at any one time.

So what is its purpose? Using a union is data flexible and economizes on storage: it only takes up as much space as the largest type it contains. 

See *13.1_unions.jai*:

```c++
#import "Basic";

T :: union {                // (1)
  a: u16 = 0; 
  b: float64 = 5.0; 
  c: Type; 
}

// equivalent:
Ts :: struct {              // (2)
  a: u16; 
  #place a;
  b: float64;
  #place a;
  c: Type;
}

// void as a union member // (2B)
Object :: struct {
  member: void; 
  #place member;
  x: float;
  #place member;
  y: float;
  #place member;
  z: float;
}

main :: () {
  t: T;             // (3)
  t.a = 100;        // (4)
  print("t.a = %\n", t.a); // => 100
  t.b = 3.0;        // (5)
  print("t.b = %\n", t.b); // => 3.0
  print("t.a = %\n", t.a); // (6) prints out gibberish, since b has been assigned
  t.c = s64;
  print("t.c = %\n", t.c); // => s64
  print("t.a = %\n", t.a); // => same as (6)
  print("The size of the union T is %\n", size_of(T)); // => 8
}

/*
t.a = 100
t.b = 3
t.a = 4613937818241073152
t.c = s64
t.a = 140701717295104
The size of the union T is 8
*/
```

A **union* is defined like a struct, but replacing `struct` by `union`, see line (1). The possible fields are then enumerated, but remember: only one can be active at any time.
(An alternative definition is to write it as a kind of struct with a **#place** directive; read it as: "in place of a, you can have the following field".) A union field can be of type void (see line (2B), usage ??). 

A variable of the union type is declared in line (3), and one field is given a value in line (4). When another field gets assigned, the value from the previous field is lost and becomes undefined: see line (6).

## 13.2 Working with enums
An enum (enumerator) is useful when a property can only take as value one of a limited number of named values, like the compass points north, west, east and south.   
Why? Because it is much easier for a developer to work with names than with numbers.
In combination with if #complete (see ??) it can be checked that all possible values of an enum are used.
All names are constants, internally they are by default 64bit-integers starting from 0 for the 1st value and auto-incrementing by 1.
_13.2_enums.jai* shows a few examples:

```c++
#import "Basic";

Compass_Direction :: enum {
    NORTH;      // 0
    SOUTH;      // 1
    EAST;       // 2 
    WEST;       // 3   
}

Key_Code :: enum u32 {    // (1)
    UNKNOWN;
    ARROW_LEFT;
    ARROW_RIGHT;
    ARROW_UP;
    ARROW_DOWN;
    SHIFT;
    ESCAPE;
}

Log_Mode :: enum {
    NONE;           
    MINIMAL;        
    EVERYDAY;       
    VERBOSE;         
}

Log_Mode2 :: enum {
    NONE;            // 0
    MINIMAL;         // 1
    EVERYDAY :: 300; // (3) 300
    VERBOSE;         // 301
}

MIDDLE_VALUE :: 8; // this can come after the enum which uses it

Log_Mode3 :: enum {
    NONE;                      // 0
    MINIMAL :: NONE;           // 0
    EVERYDAY:: MIDDLE_VALUE;   // (4) 8
    VERBOSE;                   // 9
}

Values :: enum {        // (4B)
    ONE :: 1;
    TWO :: 2;
    FIVE :: 5;
}

main :: () {
    dir1: Compass_Direction = .EAST;
    print("dir1 is %\n", Compass_Direction.EAST);
    dir1 = .SOUTH;
    // dir2 := .WEST; // Error: This declaration is bound to a unary '.' dereference 
    // that was never resolved, so there is no way to know its type. 
    // dir3: Compass_Direction = .SOUTH_WEST; // (5) - Error: 'SOUTH_WEST' is not a member of Compass_Direction.

    print("MINIMAL is %.\n", Log_Mode.MINIMAL);
    logv := Log_Mode.VERBOSE;
    log1 := Log_Mode3.MINIMAL;  
    log1 = 10;   
   
    // namespace:
    print("The first direction is %\n", Compass_Direction.NORTH);
    using Compass_Direction; // (6)
    // if not: following line Error: Undeclared identifier 'NORTH'.
    print("The first direction is %\n", NORTH);
}

/*
dir1 is EAST
MINIMAL is MINIMAL.
The first direction is NORTH
The first direction is NORTH
*/

```

A variable of type Compass_Direction can only take the values NORTH, SOUTH, EAST and WEST (see line (5)), which are its **members**. A possible value is written with the dot (.) notation like `Compass_Direction.WEST` or simply `.WEST` when the enum type is known.
The member type is by default s64, but you can specify a shorter integer type, as in the `Key_Code :: enum u32` example in line (1).  
You can assign one of the values another integer value, and then subsequent values start incrementing from this value (see lines (3) and (4)).
As we see in line (4B), each member can be given its own constant integer value.
These enums are defined in the global data scope. 
Internally, an enum is defined as a struct in module _Preload_, containing its integer fields and number of items (??).

An **anonymous enum** can be defined like this:
```c++
enum {
    NONE;           // 0
    MINIMAL;        // 1
    EVERYDAY;       // 2    
    VERBOSE;        // 3
}
```
( example of use ??)


The Jai standard library makes heavy use of enums, for example in module _Preload_:  
Operating_System_Tag, Log_Level, Type_Info_Tag and so on.

## 13.3 Enum as a namespace
Just like with structs, we can do a `using` Enum_Type (see line (6) in the example code), and then we can use the different members of the enum without the `.`  


## 13.4 Enum as #specified
New member values added to an enum get auto-incremented automatically. But what happens when a member name is deleted? Then all subsequent members get new integer values! If our code depends on these values, this could be a source for bugs.  
To avoid this, we can annotate an enum with the directive **#specified**.  The author of the enum uses #specified in order to declare the intention of maintaining compatibility of enum values over time. This requires declaring each integer explicitly: an enum declared as #specified will no longer accept the auto-increment.

Here is an example: 
```c++
Operating_Systems :: enum u16 #specified {
        VMS      :: 1;
        ATT_UNIX :: 2;
        WINDOWS  :: 3;
        GNU_SLASH_LINUX :: 4;
}
```

If a struct has an enum marked as #specified, you know that it's safe just to serialize that enum member as an integer, or even to just serialize the whole struct as binary.

## 13.5 enum_flags and masking flags
A special version of an enum is a **enum_flags**. Here the integer values backing the member names are subsequent powers of 2, like in this example *13.3_enum_flags.jai*:

```c++
#import "Basic";

Direction :: enum_flags u8 {
    EAST;  // == 1 == 0b00_01
    NORTH; // == 2 == 0b00_10
    WEST;  // == 4 == 0b01_00
    SOUTH; // == 8 == 0b10_00
}

main :: () {
    d: Direction;
    using Direction;
    d = WEST;            
    print("d is %, of type %.\n", d, type_of(d)); // => d is WEST, of type Direction.
    d = EAST | WEST;
    print("d is %\n", d); // => d is EAST | WEST
    d = EAST | WEST | NORTH | SOUTH;
    print("d is %\n", d); // => d is EAST | NORTH | WEST | SOUTH
    d &= ~SOUTH;   // (1) mask the SOUTH flag
    print("d is %\n", d); // => d is EAST | NORTH | WEST

    e: Direction = Direction.WEST | .EAST;   // (1)
    f: Direction = .WEST;
    g: Direction = 1; 
    h: Direction = Direction.WEST + 1;
    print("e: % - f: % - g: % - h: %\n", e, f, g, h);
    // => e: EAST | WEST - f: WEST - g: EAST - h: EAST | WEST
}

/* Explanation:
0001
0010
0100
1000
| --> 1111
~ .SOUTH = ~ 1000 = 0111

  1111
& 0111
  0111 <--> EAST | NORTH | WEST
  */
```
In the program above, | is the bitwise or operation. In line (1) you see how we can mask out a flag by doing `d &= ~SOUTH;` (see the bit explanation in the comments above).

Lines (1) and following show ways to assign enum flags to variables.

## 13.6 Some useful enum methods
_13.4_enum_methods.jai* shows some useful methods on enums:

```c++
#import "Basic";

Direction :: enum {
    EAST;  
    NORTH; 
    WEST;  
    SOUTH; 
}

main :: () {
    low, high := enum_range(Direction);
    print("The values range from % to %\n", low, high); // 0 to 3

    print("Values:\n");
    values :=  enum_values_as_s64(Direction);
    for values  print("% - ", it); // => 0 - 1 - 2 - 3 -

    names := enum_names(Direction);
    print("\nThe values as strings are: %\n", names);

}
/*
The values range from 0 to 3
Values:
0 - 1 - 2 - 3 -
The values as strings are: ["EAST", "NORTH", "WEST", "SOUTH"]
*/
```

**enum_range** gives you the range in integer values from low to high.
**enum_values_as_s64** gives you the values as an array
**enum_names** gives you the member names as an array.