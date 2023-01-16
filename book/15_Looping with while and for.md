# Chapter 15 - Looping with while and for

Often we need to repeat a block of code a number of times (a for-loop) or as long as a condition is true (a while-loop). Looping is also often called _iterating_.

## 15.1 While loop
See *15.1_while.jai*:

```c++
#import "Basic";

main :: () {
    n := 0;
    while n < 10 {          // (1)
        n += 1;
    }
    print("n is: %\n", n);  // => n is: 10
    // one-line:
    while n < 10  n += 1;   // (2) => n is: 10
    print("n is: %\n", n);

    count := 10;
    lift_off := 0;
    print("Counting down\n");
    while count > lift_off {
        print("% - ", count);
        count-=1;
    }
    print("Lift off!\n");

    // while on non-zero values:
    str := "Jai";   // (3)
    while str {
        print(str); // => Jai
        str = "";   // this stops the loop
    }
    n1 := 5;        //  (4)
    while n1 {
        print(" % - ", n1); 
        n1 -=1; // loop stops when n1 reaches 0
    } // => 5 - 4 - 3 - 2 - 1 -

    ptr: *int;      // (5)
    print("%\n", ptr); // => null
    a : int = 42; 
    while !ptr {
        count += 1;
        print("This is a null pointer\n"); // => This is printed out 3 times
        if count == 3 then ptr = *a; // then or {} are necessary here!
    }
    print("ptr now is %\n", ptr);

    // Nested while loop:	
    i, j: int;
    while j < 4 {    // (6)
        defer j += 1;
        i = 0;
        while i < 4 {
            defer i += 1;
            print("(%, %) - ", i, j);
        }
        print("\n");
    }

    // Named while-loop:
    count2 := 10;
    lift_off2 := 0;
    print("Counting down 2\n");
    while counting := count2 > lift_off2 { // (7)
        print("% - ", count2);
        count2-=1;
    }
    print("Lift off!\n");

    // while with defer:
    x := 0;
    while x < 10 {
        defer x += 1;        // (8)
        if x & 1  continue;  // don't print if x is odd.
        print("% - ", x); // => 0 - 2 - 4 - 6 - 8 -
    }
}

/*
n is: 10
n is: 10
Counting down
10 - 9 - 8 - 7 - 6 - 5 - 4 - 3 - 2 - 1 - Lift off!
Jai 5 -  4 -  3 -  2 -  1 - null
This is a null pointer
This is a null pointer
This is a null pointer
ptr now is 41_b68f_fba0
(0, 0) - (1, 0) - (2, 0) - (3, 0) -
(0, 1) - (1, 1) - (2, 1) - (3, 1) -
(0, 2) - (1, 2) - (2, 2) - (3, 2) -
(0, 3) - (1, 3) - (2, 3) - (3, 3) - 
Counting down 2
10 - 9 - 8 - 7 - 6 - 5 - 4 - 3 - 2 - 1 - Lift off!
*/
```

In line (1) we see the typical while condition { } loop. The one-line while in line (2) shows that ( ) around the condition and { } are optional.  
The while block is executed as long as condition is true, which is checked at the beginning of each new iteration of the loop.

Like with if (see § 14.4) the 'condition' can simply be a variable: as long as the variable is not zero, empty or null the loop can continue. We see this in action in lines (3)-(5).
Line (6) shows an if inside a while, which is used to terminate the loop.  
In line (8) we change the loop variable after a `defer`. Such a defer at the start of the loop ensures that the loop-variable will always change, even with a break or continue.

### 15.1.1 Nested while loops
Starting in line (6), we see a loop over counter i which is enclosed with a loop over counter j. At the end of the respective loops, we must increment the counter. Using `defer` we can code this at the start of the loop to achieve that.

> If a while loop uses a counter, change the counter by prefixing with defer. But  be careful in combination with break and continue (put defer after these).

### 15.1.2 Named while-loops
In line (7) you see the same while loop as used for the counting down, but now the condition has been given a name (`counting`). This name can be used to break out of the loop when you have nested while loops (see § 15.3).

### 15.1.3 Printing out a recursive list
In § 12.6 we constructed a linked-list with a recursive struct LinkedList. To print out its data, now we can do this through a loop mechanism, See *15.2_while_looping_through_a_linked_list.jai*. This has the same definition of LinkedList and variable lst as in example 13.3_linked_list.jai, so we omit this code here; the following code is used between c.next = null and the free statements:

```c++
    print("List printed in a while loop: \n");
    print("% -> ", lst.data);
    r := lst.next;              //   (1)
    while r {                   //   (2) 
        print("% -> ", r.data);
        r = r.next;             //   (3) 
    }
    print("\n");
    // => List printed in a while loop:
    // => 0 -> 12 -> 24 -> 36 ->
```
We declare a variable r of type *LinkedList in line (1). As long as r is not a null pointer, the while loop in (2) will keep on going. Line (2) is shorthand for:   `while r != null`
We print out the data of the loop and point to the next node in line (3). In our example r becomes null for c, which stops the loop. In § 26 ?? we'll see how we can print this list out in a kind of for-loop, which we'll discuss next.

## 15.2 For loop
When you want to iterate over a range of things, `for` is your best tool.

See *15.3_for.jai*:

```c++
#import "Basic";

main :: () {
// for loop over a range:
    for 1..5 print("Number % - ", it);              // (1)
    print("\n");
    for number: 1..5 print("Number % - ", number);  // (2)
    print("\n");
    
    count := 5;           // (3)
    for n: 1..count {
        print("Number % - ", n);
    }
    print("\n");

// Reverse for loop: 
    for < i: 5..0 { // (4) => 5 4 3 2 1 0
        print("% - ", i); 
    }
    print("\n");

// Nested for loops:
    for i: 1..5 {   // (5)
        for j: 10..15 {
            print("%, % / ", i, j);
        }
        print("\n");
    }
// Casting the index:
    for i: 0..cast(u8)255 { // (6) // casts i to u8.
       print("% - ", i);
    }
    // => 0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - ...
}

/*
Number 1 - Number 2 - Number 3 - Number 4 - Number 5 - 
Number 1 - Number 2 - Number 3 - Number 4 - Number 5 -
Number 1 - Number 2 - Number 3 - Number 4 - Number 5 -
5 - 4 - 3 - 2 - 1 - 0 -
1, 10 / 1, 11 / 1, 12 / 1, 13 / 1, 14 / 1, 15 /
2, 10 / 2, 11 / 2, 12 / 2, 13 / 2, 14 / 2, 15 /
3, 10 / 3, 11 / 3, 12 / 3, 13 / 3, 14 / 3, 15 /
4, 10 / 4, 11 / 4, 12 / 4, 13 / 4, 14 / 4, 15 /
5, 10 / 5, 11 / 5, 12 / 5, 13 / 5, 14 / 5, 15 /
0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - ...
*/
```

Jai knows the concept of a **range** like 1..100, which means all successive integers starting from 1 to 100 included (so like [1, 100] in mathematics).
In general `for start..end { }`; for an exclusive range write end–1. start and end can be variables, expressions, even procedure calls.
If there is no name for the loop variable, Jai has its own implicit iteration variable called `it`, see line (1). In line (2) we give the loop variable a name like `number`. This is the same as naming the condition variable in a while. 
In that case `it` is no longer defined. 

(1) and (2) are one-line for-loops. (3) shows that we need { } to write a for with a code block; end here is a variable.  
In line (4) we see a reversed for-loop indicated with **<**. Note that you still have to write the range as end..start, or put it in another way, as : `for < i: max..0 { ... }`.  
You can also add a boolean to indicate whether the looping should be reversed or not: `for <= bool_var arr print("%\n", it);`  
When bool_var is false, the looping is not reversed.

Like with while we can nest for-loops, as shown in line (5). Line (6) shows that we can cast the index (normally type s64) to a smaller integer type (but the cast bounds are checked!) .
A for-loop over a string does not work.

**Exercises**
1) Try out that a for-loop like:
		for < x..y { } 
where x < y doesn't run at all (see exercises/15.1_reversed_for.jai).

2) Print theinfinite squares of all integers from 10 to 20 (see  15.2_squares.jai) with and without a loop counter.

3) Write a program that produces a typical FizzBuzz output: see [Explanation of FizzBuzz](https://imranontech.com/2007/01/24/using-fizzbuzz-to-find-developers-who-grok-coding/). Use a for loop, an if-else if statement, and the modulo % operator (see 15.3_fizzbuzz.jai).

## 15.3 Breaking out or continuing a loop
With `while true { }` you can make an infinite loop that could crash your machine. In this as well as in normal while or for-loops you should be able to:

i) break out of a loop at a certain condition (that is: leave the loop and continue with the statement next after the loop): use the **break** keyword.

ii) break out of the current loop iteration at a certain condition, and continue with the next loop iteration: use the **continue** keyword.

Here are examples of these situations:
See *15.4_break.jai*:

```c++
#import "Basic";

main :: () {
    for i: 0..5 {  // This loop prints out 0, 1, 2 then breaks out of the loop
        if i == 3 break; // (1)
        print("%, ", i);
    }
    print("\n");  // => 0, 1, 2,

  // equivalent while-loop:
    i := 0;
    while i <= 5 {  // (2) This loop prints out 0, 1, 2 then breaks out of the loop
        if i == 3 break; // 
        print("%, ", i);
        i += 1;
    }
    print("\n"); // => 0, 1, 2,

    for i: 0..5 {    // (3)
        for j: 0..5 {
            if i == 3 break i; // breaks out of the outer loop for i:
            print("(%, %) - ", i, j);
        }
    }
    print("\n");

    x := 0;
  	while cond := x < 6 {   // (4)
        defer x += 1;
        if x == 3 break cond;
        print("%, ", x);
  	} // => 0, 1, 2,
}

/*
0, 1, 2,
0, 1, 2,
(0, 0) - (0, 1) - (0, 2) - (0, 3) - (0, 4) - (0, 5) - 
(1, 0) - (1, 1) - (1, 2) - (1, 3) - (1, 4) - (1, 5) - 
(2, 0) - (2, 1) - (2, 2) - (2, 3) - (2, 4) - (2, 5) - 
0, 1, 2,
*/
```
In line (1), we break out of the for loop when i gets the value 3. Note that the variable i is known only inside the for loop.  
In line (2), we see the same logic written as a while loop. The nested loop in line (3) does a `break i`, it stops looping when i becomes 3.
In line (4) we see how you can break out of a while-loop using the condition variable.
So normally a `break` terminates the current innermost loop immediately, but a `break var` breaks out of the loop where `var` is the iteration or condition variable. 

See *15.5_continue.jai*:

```c++
#import "Basic";

main :: () {
    for i: 0..5 {  // This for loop prints out 0, 1, 2, 4, 5
        if i == 3 continue;  // (1)
        print("%, ", i);
    }
    print("\n");

    x := 0;
  	while cond := x < 6 {   // (2)
        defer x += 1;
        if x == 3 continue cond;
        print("%, ", x);
  	}

    for i: 0..5 {  
        for j: 0..5 {
            if i == 3 continue i; // (3) continues with the outer loop for 4 and 5
            print("(%, %) - ", i, j);
         }
    }
    print("\n");

    for i: 1..4 {     // (4)
        if i == 2  continue;
        for j: 11..14 {
            print("(%, %) - ", i, j);
            // Stop on unlucky number 13.
            if (i == 3) && (j == 13)  break i;  // Break from the outer loop, so we are done, last printing 13, 3.
        }
    }
}

/*
0, 1, 2, 4, 5,
0, 1, 2, 4, 5,
(0, 0) - (0, 1) - (0, 2) - (0, 3) - (0, 4) - (0, 5) - 
(1, 0) - (1, 1) - (1, 2) - (1, 3) - (1, 4) - (1, 5) - 
(2, 0) - (2, 1) - (2, 2) - (2, 3) - (2, 4) - (2, 5) - 
(4, 0) - (4, 1) - (4, 2) - (4, 3) - (4, 4) - (4, 5) - 
(5, 0) - (5, 1) - (5, 2) - (5, 3) - (5, 4) - (5, 5) -
(1, 11) - (1, 12) - (1, 13) - (1, 14) - 
(3, 11) - (3, 12) - (3, 13) -
*/

```

`continue` starts the enclosing loop again with the next iteration value.
In line (1) we see that the value 3 is not printed out because of the continue.
In line (2) we see the exact same effect in a while-loop, using the condition name `cond` used as continue `cond`.
Line (3) shows that the inner loop is not processed for i == 3, but `continue i` continues with the next value of i being 4.   
For both break and continue we see that the iteration variable can be used as a label here.

Line (4) and following show a combined use of break and continue. A lot of flexibility is possible, but a bug is easily created, so check thoroughly!

## 15.4 Looping over an enum's values:
See *15.6_for_enum.jai*:

```c++
#import "Basic";

Direction :: enum {
    EAST;  
    NORTH; 
    WEST;  
    SOUTH; 
}

main :: () {
    print("% contains the following values:\n", Direction);
    for enum_values_as_s64(Direction) {         // (1)
        print("\t%: %\n", it, cast(Direction) it);
    }
}
/*
Direction contains the following values:
        0: EAST
        1: NORTH
        2: WEST
        3: SOUTH
*/
```

In addition to the enum methods we discovered in § 13.6 that give us the range and the member names, we can also user a for-loop shown in line (1) to get the enum's values with the `enum_values_as_s64` proc.  

## 15.5 Looping over a struct's fields with type_info()
See *15.7_struct_members.jai*:

```c++
#import "Basic";
#import "Math";

Person :: struct @Version9 {                  // (1)
    name            : string;
    age             : int;
    location        : Vector2;  @NoSerialize  // (2)
}

main :: ()  {
    pinfo := type_info(Person);
    print("The struct has name: %\n", (<<pinfo).name); 
    // => The struct has name: Person
    for member: pinfo.members {       // (3)
        print("% - ", member.name);  
        print("% - ", << member.type);
        print("% - ", (<< member.type).runtime_size);  
        print("% - ", member.offset_in_bytes);
        print("% - ", member.notes);  // (4)
        print("% - \n", member.flags);  
    }
    print("\n");
    member, offset := get_field(pinfo, "age");  // (5)
    print("info age field: % and has offset %\n", << member, offset);
    print("\n");
}
/*
name - {STRING, 16} - 16 - 0 - [] - 0 -
age - {INTEGER, 8} - 8 - 16 - [] - 0 -
location - {STRUCT, 8} - 8 - 24 - ["NoSerialize"] - 0 -

info age field: {name = "age"; type = 7ff6_5021_4000; offset_in_bytes = 16; 
flags = 0; notes = []; offset_into_constant_storage = 0; } and has offset 16

*/    
```
We can use `type_info()` on a struct definition and then loop over its members (as in line (3)) to get their names, their type, and if present, flags and attached notes.
Also the `get_field` method (line (5) gives you detailed information.

## 15.6 Serialization
The methods discussed in the previous sections provide type info which can be used to _serialize_ structs into strings, and vice-versa _deserialize_ strings into structs. They enable us to write serialization procedures, commonly used e.g. in network replication of entities and save game data, see § 26.9.2

## 15.7 Annotations or notes
It's also possible to add a declarative note (annotation) to a struct, a struct field or a procedure, adding an at-sign (@) after a declaration. For example: to indicate a certain field must not be serialized, add a note **@NoSerialize**, see line (2).
The note tag is represented as a string, and unlike in Java or C#, is not structured. Its info is stored in the `notes` array of strings of the Type_Info_Struct_Member struct, making it available at compile-time and run-time. Each field can have several notes (see line (4)).
This can be picked up with introspection, and appropriate actions can be taken accordingly (see § 30.13).  
You can also add annotations to a struct itself, for example: to indicate which version of the struct definition is used (see line (1)).
Here is an example of a procedure with a note:  
`generate_code :: () { ... } @RunWhenReady`

Notes are also abundantly used within code comments to add useful info for refactoring.
For example: @TestProcedure, @test, @Incomplete, @Refactor, @Cleanup, @Simplify, @Temporary, @pure ...
Example of use: Look up in your code editor all occurrences of @Cleanup when you want to further improve your code.
You can invent your own sorts of notes, they are not limited.
