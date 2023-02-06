# 19 Working with Strings

We encountered strings first in § 5.1 and we've used them ever since. Here we'll go deeper into: 
- what is a string?
- how to work with a string builder for best performance
- what are common operations for strings?  
But you can be assured that strings in Jai are simple and performant, unlike in C++.

## 19.1 What are strings?
(See *19.1_strings.jai*)

```c++
#import "Basic";

main :: ()  {
    str: string = "Hello."; // (0) same as: str := "Hello.";
    a := "Happy";
    print("a's length is %\n", a.count); // (1) => a's length is 5
    print("a's data starts at % with value %\n", a.data, << a.data); // (2)
    // => a's data starts at 7ff7_d2ed_2007 with value 72
    
    ch := "世界"; // (3)
    print("ch's length is %\n", ch.count); // => ch's length is 6
    print("ch's data starts at % with value %\n", ch.data, << ch.data); //
    // (4) => ch's data starts at 7ff7_fceb_6409 with value 228

    print(str); // => Hello.
    print("The 5th character of str is: % \n", str[5]); // (5)
    // => The 5th character of str is: 46
    // str[5] = #char "!"; // (6) run-time crash of program
    /*
     The program crashed. Printing the stack trace:
     handle_exception      c:\jai\modules\Runtime_Support_Crash_Handler.jai:211
     ... (skipping OS-internal procedures)
     main                  d:\Jai\The_Way_to_Jai\examples\19\19.1_strings.jai:18  
    */
    // str[5] = "!"; // Error: Type mismatch. Type wanted: u8; type given: string.
    // str[5] = '!'; // Error: Unable to parse an expression to the right of this binary operator.

    // Bounds checking:
    // print("The 99th character of str is: % \n", str[99]); // (7) => 
    /*
    Panic.
    The program crashed. Printing the stack trace:
    handle_exception                  c:\jai\modules\Runtime_Support_Crash_Handler.jai:211
    ... (skipping OS-internal procedures)
    debug_break                       c:\jai\modules\Runtime_Support.jai:8
    my_panic                          c:\jai\modules\Runtime_Support.jai:136
    __array_bounds_check_fail         c:\jai\modules\Runtime_Support.jai:185
    main                              d:\Jai\The_Way_to_Jai\examples\19\19.1_strings.jai:23
    */

    // implicit cast of string to bool:
    if str {            // (8)
        print("string is not empty!"); // => string is not empty!
    } else {
        print("string is empty!");
    }

    // (9)
    multi_line_string := #string END
    This
        is
      a
            multi-line
    string.
    END;

    print(multi_line_string);
    /*
    This
        is
      a
            multi-line
    string.
    */

    // Looping over the characters in a string:
    for i: 0..str.count-1 {             // (10)
            print("% -", str[i]);
    } // => 72 -101 -108 -108 -111 -46 -
    print("\n");
    for i: 0..ch.count-1 {
            print("% -", ch[i]);
    } // => 228 -184 -150 -231 -149 -140
    print("\n");
    for cast([] u8) str {             // (10B)
        print("% -", it);
    } // => 72 -101 -108 -108 -111 -46 -
    
    // sprint:
    b := "Resounding ";
    newstr := sprint("% %!\n", b, ch); // (11)
    print("%\n", newstr); // => Resounding 世界!
    free(newstr);  // (12)

    // Changing string data:
    // with sprint:
    chg_str := sprint("%", str);      // (12B)
    print("chg_str is %\n", chg_str); // => chg_str is Hello.
    for i: 0..chg_str.count - 1 {
       if chg_str[i] == #char "."  chg_str[i] = #char "?";
    }
    print("chg_str after for is %\n", chg_str); // => chg_str is Hello?
    free(chg_str);
    // in stack memory:
    SIZE :: "Hello.".count;
    mem : [SIZE]u8;
    memcpy (mem.data, str.data, str.count);  // (12C)
    chg_str2 := to_string (mem.data, mem.count);
    print("chg_str2 is %\n", chg_str2); // => chg_str2 is Hello.
    for i: 0..chg_str2.count - 1 {
       if chg_str2[i] == #char "."  chg_str2[i] = #char "?";
    }
    print("chg_str2 after for is %\n", chg_str2); // => chg_str2 is Hello?
    // allocate on the heap:
    chg_str3 := copy_string (str);          // (12D)
    defer(free(chg_str3));
    print("chg_str3 is %\n", chg_str3); // => chg_str3 is Hello.
    for i: 0..chg_str3.count - 1 {
       if chg_str3[i] == #char "."  chg_str3[i] = #char "?";
    }
    print("chg_str3 after for is %\n", chg_str3); // => chg_str3 is Hello?

    // strings are array views:
    x := "Sailor";  // (13)
    x.count = 4;
    print("x is: '%'\n", x);    // => x is: 'Sail'
    x.count -= 1;
    x.data += 1; // <-- pointer advances 1 byte, and now points to 'a'
    print("x is: '%'\n", x);    // => x is: 'ail'

    buffer := cast(*u8) alloc(length);     // (14)
    // fill up buffer in some way or other, 
    data2: string;           
    data2.data = buffer;
    data2.count = length;

}
```

In line (1) and (2) we see that a simple string a has fields count and data, just as all the array types!

Indeed, a string is defined in module _Preload_ as:

```c++
Newstring    :: struct {
    count     : s64;  
    data      : *u8;
}
```

The count is the length (number of bytes) in the string, data is a pointer to a u8 (byte), namely to the first byte in the string. When we dereference this (<<a.data), we get 72, which is the decimal value of the ASCII 'H'. A variable of type string is always 16 bytes in size. The actual characters are stored elsewhere, for example constant strings and string literals are stored in a read-only segment of the binary executable file.  
The empty string `""` is the default value, it has count 0 and data 0x0.

When we declare a Unicode string such as ch in line (3), we see that the number of bytes is 6, which does not correspond to the number of characters (2).Looking up the first character ['世'](https://www.compart.com/en/unicode/U+4E16#:~:text=Unicode%20Character%20%E2%80%9C,%E4%B8%96%20%E2%80%9D%20%28U%2B4E16%29) tells us that in **UTF-8 Encoding** it consists of 3 bytes, in order: 	0xE4 0xB8 0x96. The first byte 0xE4 is hexadecimal for 228, the dereferenced data of the first pointer (see line (4)). So Jai strings are UTF-8 encoded.

Also notice that `Newstring` is the exact same definition as `Array_View_64`. 
A variable of type string is in fact an _array view_, where the data is an array of u8  (written as []u8), which is NOT '0'-terminated. A string can always be casted to [] u8 (see (10B)).

Another way to create a string strdata when you have a buffer with length bytes in it is shown in line (14) and following:
```
strdata: string;
strdata.count = length;
strdata.data = buffer;
```
String constants are zero-terminated, and can be implicitly cast to *u8 or *s8, but `y := "Hello"` cannot be cast implicitly to *u8.

## 19.2 Some basic operations on bytes
As we know there is no char type in Jai; strings are []u8.
The following operations on bytes, defined in _Basic_, can be useful on occasion:

See *19.2_bytes.jai*:

```c++
#import "Basic";
#import "String"; // for is_any

main :: () {
    print("%\n", to_upper(#char "a")); // => 65 - ASCII value of 'A'
    print("%\n", to_lower(#char "A")); // => 97 - ASCII value of 'a'
    print("%\n", is_digit(#char "7")); // => true
    print("%\n", is_digit(#char "X")); // => false
    print("%\n", is_alpha(#char "i")); // => true
    print("%\n", is_alnum(#char "9")); // => true
    print("%\n", is_space(#char " ")); // => true
    print("%\n", is_space(#char "\t")); // => true
    print("%\n", is_any(#char "l", "Hello!")); // => true
}
```

`is_any :: (c: u8, chars: string) -> bool` can check if string chars contains byte c.

## 19.3 Backslash codes, escape characters and Unicode characters
The backslash characters (also called escape sequences) use the backslash to indicate a special character:

```c++
    \e    Escape
    \n     Newline    
    \r     Carriage Return
    \t     Tab

    \"     The character "
    \\     The character \
    \0     The byte with value 0.

    \xAB   The byte with the value designated by hexadecimal digits AB (these can be any digit from 0-9 or A-F, upper or lower case.)

    \d123  The byte with the decimal digits 123 (these can be any digit from 0-9).       (Since it's a byte, the maximum valid value is 255.)

    \uABCD The 16-bit Unicode character U+ABCD (where ABCD is any hex number), in UTF-8.
			Example: print("\u03C0");  // => π  (see 5.9_printing_unicode.jai)

    \UABCDEF12   The 32-bit Unicode character U+ABCDEF12, in UTF-8.
```

To write a backslash, use "\\"
Using backslashes gets unreadable very quickly.

## 19.4 Some string characteristics
(see _19.1_strings.jai_)
### 19.4.1 String literals are immutable and bounds-checked
String literals like str, a or ch can (because they are array views) also be accessed via index, like in line (5): `str[5]` (46 is the ASCII value for '.')
But string literals are **immutable** (they are stored in read-only memory): you can access a string byte via indexing [], but not change it. For example line (6) crashes the program, see output within code snippet.
(Also try out str[5] = "!" or str[5] = '!' and explain the compiler error messages)    
**Ways to change the data from string literals**
To be able to modify the string, you must copy its data into allocated memory on the stack or the heap.
You can use sprint to make that change as in line (12B): make an `sprint` string out of the original string. Because this resides in memory, you can change it like in the for-loop shown here.  
(12C) shows how to copy the string to a stack memory array, making a new string out of it with to_string.  
(12D) shows how to use copy_string to make a copy on the heap, which you can then change.   

String literals are also **bounds-checked** at run-time, see line (7) and the output in the code snippet. We get a clear indication of the cause with *array_bounds_check_fail*

### 19.4.2 Strings as boolean values
All non-empty strings are implicitly converted to true when used in a condition (see line (8)); the empty string converts to false.

### 19.4.3 Multi-line strings
A multi-line string (also called here or doc string) is defined as in line (9) with the **#string** directive preceding the token that delineates the string (start-end). In our case this is `END` which is a freely chosen token. There may be no characters between the start token END and the string itself, except for a new-line. Notice how all space characters (tabs, newlines, and so on) are also preserved in the string.  
The lines following (9B) show how a multi-line string can contain % markers, which can later be substituted with values using sprint or a string builder.

### 19.4.4 Looping over the characters in a string str with for
Line (10) shows this is done as follows:  ` for i: 0..str.count-1`  
You can print out or process each byte, but not change them in the string itself.  
( `for str   print("% -", str[it]);` does NOT work. )  
Another way of looping over a string is shown in line (10B): `for cast([] u8) str  { }`
Simply cast the string to an array of bytes, and then you can use `it` in the loop.

### 19.4.5 The sprint procedure
`sprint` is just like `print`, but allocates and returns the result as a string instead of printing it out. It has the following signature:  
`sprint :: (format_string: string, args: .. Any) -> string;`
It can be used to build strings dynamically, as shown in line (11).

### 19.4.6 Releasing a string's memory
Strings that have been built dynamically have to be de-allocated. This can be done with `free()`, as shown in line (12). An elegant alternative approach is to use the `tprint` twin proc of `sprint` (see § 21.4.1).

### 19.4.7 Storing code in strings
In § 26.4.1 we'll see that _Code_ is a type on its own. One of Jai's fortes is meta-programming, that is: manipulating code at compile-time.  
Code can be stored in a string, but because code can contain lots of backslashes and quotes this can become very difficult to read.  
A better solution is to store code as a constant string (::) or for many code lines as a multi-line string (see § 19.4.3).

### 19.4.8 Strings as array views
Because strings are essentially array views, you can manipulate .count and .data just as with array views, like in line (13) and following.

### 19.4.9 Relative strings
(See *19.6_relative_strings.jai*)

```c++
#import "Basic";

Package :: struct {             
    strings: [3] string~s8;   // (1) 
    string_data: [100] u8;
}

S :: struct {
    str : string~s8;
    utf8 : [5]u8;
}

main :: ()  {
    s : S;                    // (2)
    s.utf8 = .[0xE3, 0x8B, 0xA1, 0, 0];
    write_relative_pointer(s8, *s.str.data, *s.utf8);
    s.str.count = 3;
    print("'%'\n", s.str);    // => '㋡'
}
```

Just like relative pointers (see § 10.6), we can define strings in an array field of a struct relative to each other, see line (1). The options are: string ~s8, string ~s16, string ~s32, string ~s64. Lines (2) and following show how to make a Unicode character string (containing 3 characters) from a []u8 (example taken from Jai-Community Wiki - Snippets).
(For other examples, see how_to 300_relative pointers.)

## 19.5 String builder
See *19.3_string_builder.jai*:

```c++
#import "Basic";

main :: () {
  builder: String_Builder;       // (1)
  defer free_buffers(*builder);  // (2) 
  init_string_builder(*builder); // (3)

  append(*builder, "One!");      // (4)
  append(*builder, "Two!");
  append(*builder, "Three!");

  n := 69105;
  exclamation := "For sure!!";
  print_to_builder(*builder, " ... number %, exclamation %.", n, exclamation); // (5)

  print("The length of the builder buffer is %\n", builder_string_length(*builder)); // (6)
  // => The length of the builder buffer is 56

  s := builder_to_string(*builder); // (7)
  print("The result string that came out of the builder is % bytes long.\n", s.count);
  // => The result string that came out of the builder is 56 bytes long.
  print("It is: '%'.\n", s);
  // => It is: 'One!Two!Three! ... number 69105, exclamation For sure!!.'.
}
```

The most efficient way to build larger strings from several other strings is to use a **String_Builder** (defined in module _Basic_ ). A string builder works in an incremental, buffered way.

After declaring a variable builder of that type in line (1), call the `init_string_builder(*builder)` in line (3). 
Then use append(*builder, str) whenever you want to add a string str to the builders’ buffer, like in line (4) and following. Also `print_to_builder` can be used to add a formatted string to the string builder (see line (5)).
It has the following signature:

`print_to_builder :: (builder : *String_Builder, format_string : string, args: .. Any) -> bool;`

Other available `append` procs are:
```
append(*builder, s: *u8, length: s64)
append(*builder, byte: u8)
```

You can check the builder's length at any time with `builder_string_length(*builder)` (see line (6)).  

When the builder is complete, use `builder_to_string(*builder)` as in line (7) to convert the buffer to a normal string. This proc has the following signature:

`builder_to_string :: (builder: *String_Builder, allocator := context.allocator, allocator_data := context.allocator_data, extra_bytes_to_prepend := 0) -> string;`

To free the memory used by the string builder, use `free_buffers(*builder);` usually used with a `defer` right after the string builder declaration like this (see line (2)):  `defer free_buffers(*builder);`


## 19.6 String operations
These operations are defined in the _Basic_ and in the _String_ module. Here we give some examples of the most used procedures.

See *19.4_string_operations.jai*:

```c++
#import "Basic";
#import "String";

main :: ()  {
    str1 := "London";
    str2 := "Antwerp";

    copy := copy_string(str1);
    print("copy is: %\n", copy); // => copy is: London

    // Conversions to and from numbers:
    // string to numbers
    i, ok := string_to_int("42");     // (1)
    if ok print("the integer is %\n", i); // => the integer is 42
    j, ok2 := string_to_int("abc");
    if ok2 print("the integer is %\n", j); 
    else print("this is not an integer!\n"); // => this is not an integer!
    f, ok3 := string_to_float("3.1415"); // (2)
    if ok3 print("the float is %\n", f); // => the float is 3.1415

    str3 := "108";
    i, ok = parse_int(*str3);
    print("i is % and ok is %\n", i, ok); // => i is 108 and ok is true

    str3 = "108";  // parse_int empties str3
    i, ok = to_integer(str3);             // (2B)  
    print("i is % and ok is %\n", i, ok); // => i is 108 and ok is true
    if !ok {
        print("Expected to read an integer, but got '%'!\n", i);
        // for str3 == "abc"
        // => Expected to read an integer, but got '0'!
        exit(-1);
    }

    a := 4;
    str := sprint("%", a);                  // (2C)
    print("a is %, str is -%-\n", a, str);  // => a is 4, str is -4-
    print("str is type %\n", type_of(str)); // => str is type string
    
    // Comparison functions:
    n := compare(str1, str2); // (3) 
    print("n is %\n", n);       // => 1
    if n > 0  print("str1 comes after str2\n"); // => str1 comes after str2
    who := "Ant";
    if contains(str2, who)  print("%s are living in %\n", who, str2); // => Ants are living in Antwerp
    if begins_with(str2, who) {
        print("Antwerp is a city of ants!\n"); // => Antwerp is a city of ants!
    }

    // (4) Concatenating strings and splitting strings:
    print(join("a","b","c","d")); // => abcd
    print("\n");
    print(join(.. .["One", "Two", "Three"], separator = "::")); // => One::Two::Three
    print("\n");
    print(join(.. .["One", "Two", "Three"], separator = "::", before_first = true, after_last = false)); 
    // => ::One::Two::Three
    print("\n");
    print(join(.. .["One", "Two", "Three"], separator = "::", before_first = true, after_last = true)); 
    // => ::One::Two::Three::
    print("\n");
    s := join(.. .["foo", "bar", "puf"], ", ");
    print("s is '%'\n", s); // => s is 'foo, bar, puf'
    s2 := "Hello, Sailor! How are you?";
    print("s2 splitted: %\n", split(s2, " ")); // => s2 splitted: ["Hello,", "Sailor!", "How", "are", "you?"]

    // search:
    print("'on' is found at position % in %\n",find_index_from_left(str1, "on"), str1); // (5)
    // => 'on' is found at position 1 in London
    print("'on' is found at position % in %\n",find_index_from_right(str1, "on"), str1);
    // => 'on' is found at position 4 in London

    // (6) changing:
    print("+"); print(trim("\t   Hello, Sailor!          \t")); print("+"); // => +Hello, Sailor!+
    print("\n");
    print(replace("Antwerpen", "n", "m")); // => Amtwerpem
    print("\n");
    print(slice("London", 2, 3)); // => ndo
    print("\n");
}
```

### 19.6.1 Conversions to and from numbers

#### 19.6.1.1 string to numbers
`string_to_int :: (str: string) -> int, bool;`
> This is a multi return-value proc, when str can be converted to an int, this value is returned together with a true; if not, the value 0 is returned together with false (see line (1)).
`string_to_float :: (str: string) -> float, bool;` (see line (2)).

The `to_integer` procedure with signature   
`to_integer :: (s: string) -> result: int, success: bool, remainder: string` 
is shown in line (2B); it also shows a check for the `success` value. 
uses `string_to_int` for the conversion.

The `parse_int` and `parse_float` procs use `parse_token` and are more robust than the string_to variants.

#### 19.6.1.2 numbers to string
To accomplish this use `sprint` or `tprint` (see line 2C), or work with a String Builder in more complex cases.   

### 19.6.2 String comparisons
Here are the signatures of the most important ones:
```c++
equal :: (a: string, b: string) -> bool #must; // comparison is case sensitive
equal_nocase :: (a: string, b: string) -> bool #must;
compare :: (a: string, b: string) -> int #must;   // works like strcmp in C
compare_nocase :: (a: string, b: string) -> int #must;
contains :: (str: string, substring: string) -> bool #must;
contains :: (s: string, char: u8) -> bool;
begins_with :: (str: string, prefix: string) -> bool #must;
ends_with :: (str: string, suffix: string) -> bool #must;
```
See some of them in action in lines (3) and following.

### 19.6.3 Joining and splitting
Here are the signatures of the most important ones:
```c++
join :: (inputs: .. string, separator := "", before_first := false, after_last := false) -> string;
split :: (str: string, separator: string) -> [] string;
split_from_left  :: (s: string, byte: u8) -> (found: bool, left: string, right: string);
```

`join` takes a variable number of strings and joins them in one string, separated by a token if needed.
`split` does the inverse: it takes a string and a separator and splits the 'words' into an array of strings. 
See some of them in action in lines (4) and following.

#### 19.6.3.1 Looping over the result of a split
Because split always returns an [] string, you can always loop over it with for, and process each result of the split, as in line (4B). Just splitting/looping/printing would be a one-liner!

A number of path routines also exist (like path_decomp, path_filename, path_extension, and so on) which come in handy when working with filenames.

### 19.6.4 Searching
Here are some important signatures:
```c++
find_index_from_left  :: (s: string, byte: u8) -> s64;
find_index_from_left  :: (s: string, substring: string) -> s64;
+ versions _from_right
```

### 19.6.5 Changing
Some important procs are:
```c++
trim_left, trim_right, trim
replace_chars :: (s: string, chars: string, replacement: u8);
replace :: (s: string, old: string, new: string) -> (result: string, occurrences: int);
to_lower_in_place :: (s: string);
to_upper_in_place :: (s: string);
slice :: inline (s: string, index: s64, count: s64) -> string;
```

## 19.7 C strings
Jai strings do NOT end with a zero byte \0.  This is in contrast to a C-string, which is '0' terminated, and has the Jai type *u8. 
Jai strings are much more safe than C strings, because they store their length (count), so manipulations of the string can be bounds-checked (see § 19.4.1).

On the other hand Jai programs will have to work together with C programs/libraries, so Jai needs to be able to interact well with C strings.
To make it easier to communicate with C, constant Jai strings like `greeting :: "Hello"` are constructed by the compiler with a '0'-termination.

Here are the most important C string manipulation procs:
```c++
to_c_string :: (str: string) -> *u8; // NOTE: This function heap allocates memory
to_string :: takes a *u8 (a C string) or a []u8 and returns a Jai string
c_style_strlen :: (ptr: *u8) -> int; 
```

And here are some examples of usage:

See *19.5_cstrings.jai*:

```c++
#import "Basic";
#import "String";

main :: ()  {
    str1 := "London";
    c_string := to_c_string(str1); // c_string is 0 terminated
    defer free(c_string); // (1)
    print("the C string is %\n", c_string); // => the C string is 1ad_d867_56f0
    print("the C string is %\n", << c_string); // => the C string is 76 // ASCII value of 'L'
    print("Its length is %\n", c_style_strlen(c_string)); // => Its length is 6
    // alternative way:
    len := 0;
    while << c_string {
        len += 1;
        c_string += 1; // (2) pointer arithmetic
    }
    print("The length of c_string is %\n", len); // => The length of c_string is 6
    print("the original string is %\n", to_string(c_string)); 
    // => the original string is London
}
```
The memory of C strings has to be freed, as shown in line (1) with `free`.
The while loop around line (2) shows how to get the length of a C string by dereferencing and incrementing the pointer. When c_string points to the ending 0 value, its value is evaluated as false and the while loop terminates.


[19B - Get command-line arguments](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/19B_Get%20command-line%20arguments.md)  
[19C - Get console input](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/19B_Get%20command-line%20arguments.md)   
[19D - Comparing field names of structs](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/19D_Comparing%20field%20names%20of%20structs.md)  


