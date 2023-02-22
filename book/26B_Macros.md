# 26B Macros

## 26.5 Basics of macros
A macro is also a way to insert code at compile-time at the call site, so it is similar to an inlined procedure.   
Unlike the C/C++ programming language in which a macro is completely arbitrary, Jai macros are more controlled, better supported by the compiler, and come with much better typechecking. Moreover, they can be debugged with the same techniques we saw in § 20.

They make some kinds of meta-programming easier. If they are well designed, they allow you to raise the level of code abstraction, by creating your own mini-language, specific to the problem space, and then you can solve your particular problem in that mini-language.  

Macros also allow you to cut down the repetition of not only specific actions (procedures are best for that), but of more abstract constructs.   When they are not well designed, however, creating and using macros, results in unmaintainable messes (hard to read, to understand, to debug).  
So you should only resort to macros when it really makes sense in your program's context: they are a 'last-resort' thing to use.

Jai's macros are so called _hygienic_:
- they do not cause any accidental captures of identifiers from the environment;
- they modify variables only when explicitly allowed;

Syntactically, macros resemble a procedure: they are defined by adding the **#expand** directive to the end of the proc declaration before the curly brackets.   
Let's see this in *26.7A_macros_intro.jai*:
```c++
#import "Basic";

// proc1 :: ()         {      // (1)  procedure
proc1 :: () #expand {      // (2)  macro
    print("You are in proc1!");
}   

main :: () {
    proc1(); // => You are in proc1!
}
```

`proc1` in this code is originally a procedure (line (1)). If you add `#expand` before its body (or uncomment it), it becomes a macro (line (2)). The way of calling them is the same, their output is the same.

Expand in `#expand` means that the macro-code is processed, transformed to real code, that is then inserted at the call-site of the macro.

The following examples in this section are meant to show the basic syntax, they do not show a useful application of macros, where you would prefer them above procs.

The syntax is shown in `macro0` defined in line (1) below, which does nothing. A macro is called like any proc: `macro0()`.

See *26.7_macros_basics.jai*:
```c++
#import "Basic";
#import "Math";

macro0 :: () #expand { }   // (1)

macro1 :: () #expand {
    a := "No backtick";    // (1B) 
    print("a at macro1 start is: %\n", `a); //   (4A) => a at macro1 start is: 0
    `a += 10;              //  (2) 
}

maxm :: (a: int, b: int) -> int #expand {  // (5)
    if a > b then return a;
    return b;
}

macro2 :: () -> int #expand {   // (6)
    if `b < `c {
      return 0;
    }
    defer print("Defer inside macro2\n"); // (6B) // => Defer inside macro2
    // `defer print("`Defer inside macro2\n"); // (6C) // => `Defer inside macro2
    return 1;
}

macro3 :: () #expand {
    print("This is macro3\n");
    `c = 108;
    nested_macro();

    nested_macro :: () #expand {
      print("This is a nested macro\n");
    }
}

factorial :: (n: int) -> int #expand {
    #if n <= 1 return 1;
    else {
      return n * factorial(n-1);
    }
}

macfunc :: () -> string {
    a := 0;
    b := 100;
    print("In maxfunc just before calling macron\n"); 
    c := macron();
    print("In maxfunc just before returning\n");  // never printed!
    return "none";

  macron :: () -> int #expand {
      defer print("Defer inside macron\n");  // (7)
      if `a < `b {
          `return "Backtick return macron\n"; 
       }
       return 1;
  }
}

macroi :: (c: Code) #expand {   // (9)
    #insert c;
    #insert c;
    #insert c; 
}

main :: () {
    a := 0;
    macro1(); // (3)
    print("a is: %\n", a); // (4B) => a is: 10

    b := 7;
    c := 3;
    print("max is %\n", maxm(b, c)); // => max is 7

    print("macro2 returns %\n", macro2()); // => macro2 returns 1

    macro3();
    // => This is macro3
    // => This is a nested macro
    print("c is %\n", c); // => c is 108


    x := factorial(5);
    print("factorial of 5 = %\n", x); // => factorial of 5 = 120

    s := macfunc();  
    // => In maxfunc just before calling macron
    // => Defer inside macron
    print("%\n", s); // (8) => Backtick return macron 

    va := Vector3.{1,2,3};
    code :: #code print("% - ", va);
    macroi(code); // => {1, 2, 3} - {1, 2, 3} - {1, 2, 3} -
}

/* with defer in macro 2:
a at macro1 start is: 0
a is: 10
max is 7
Defer inside macro2
macro2 returns 1
This is macro3
This is a nested macro
c is 108
factorial of 5 = 120
In maxfunc just before calling macron
Defer inside macron
Backtick return macro
{1, 2, 3} - {1, 2, 3} - {1, 2, 3} -
*/
```

`macro1` does something new: it adds 10 to the variable `a` found in the outer scope in line (3): the backtick in front of a (`a) denotes that `a` must exist in the outer scope. When `macro1` is called in main(), this is indeed the case. We see in line (4B) that `a` has value 10, through the execution of `macro1`. The a in line (1B) is just a local (to the macro) variable, it does not pollute the outer scope.

> Macros can have context, namely if indicated with ` they can see variables in their outer scope.

If `a` does not exist, we get the following error in line (2): `Error: Undeclared identifier 'a'.`
while getting this message at line (3): `Info: While expanding macro 'macro1' here...`
The ` mechanism for looking up outer variables only works one level up.

Line (5) shows that a macro can have parameters, just like any proc. This is a way to avoid the backtick syntax.
`macro2` defined in line (6) refers to two outer variables b and c. In this case it returns 1, but just before leaving the macro, it prints something by using the `defer` keyword in line (6A).  
But notice what happens when we use `defer` in line (6B): because of the backtick the defer now takes the scope of the caller (main() in this case) as its scope, and prints its message just before main() ending (see the attached complete output in both cases).  

`macro3` shows _inner_ or _nested_ macros: a macro can contain and call macros defined inside itself. But there is a limit as to how many macro calls you can generate inside another macro.    
`factorial` is an example of a recursive macro; #if needs to be used here (instead of if), else you get the following `Error: Too many nested macro expansions. (The limit is 1000.)`  

`maxfunc` is a procedure which calls a nested macro `macron`; this returns "Backtick return macro" as return value from `maxfunc`.  

### 26.5.1 Using a macro with #insert
`macroi` in line (9) illustrates that we can use #insert (see § 26.4) inside a macro: it takes a code argument and inserts it 3 times in the main code.

**Exercises**   
1) Declare a variable n with value 42, and a constant of type Code that multiplies this by 3. Write a macro that inserts this line of code 4 times. Show the result (see *changer_macro1.jai*)
2) Write a macro that takes 2 integer arguments and can access an outer variable x. x is multiplied with the 1st argument, and the 2nd argument is added to it. (see *changer_macro2.jai*)  

### 26.5.2 Using a macro with #insert to unroll a for loop
Sometimes you might want to unroll loops to optimize a program's execution speed so that the program does less branching. Loops can be unrolled through a mixture of #insert directives and macros. In the example below, we unroll a basic for loop that counts from 0 to 10.

See *26.14_insert_for_loop.jai*:
```c++
#import "Basic";

unroll_for_loop :: (a: int, b: int, body: Code) #expand {
  #insert -> string {
    builder: String_Builder;
    print_to_builder(*builder, "{\n");
    print_to_builder(*builder, "`it: int;\n");
    for i: a..b {
      print_to_builder(*builder, "it = %;\n", i);
      print_to_builder(*builder, "#insert body;\n");  // (1)
    }
    print_to_builder(*builder, "}\n");
    return builder_to_string(*builder);
  }
}

main ::() {
  unroll_for_loop(0, 10, #code {
    print("% - ", it); // => 0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 
  });

}
```

In this example `unroll_for_loop` is a macro that receives a Code parameter. It uses the `#insert -> string` shortcut (see § 26.4). In fact, it uses multiple inserts, #insert can be run recursively inside another #insert as seen in line (1).  
When compiling, you can see what is inserted in `.\build\.added_strings_w2`.

### 26.5.3 Using a macro for an inner proc
In § 17.2 we saw that an inner proc cannot access outer variables. A way to circumvent this is to define the inner proc as a macro and use `. The example below is inner_proc() from *17.2_local_procs.jai*, which is now redefined as a macro to be able to change the outer variable x.

See *26.13_local_procs.jai*:
```c++
#import "Basic";

proc :: () {
    x := 1;
    inner_proc();
    print("x is now %\n", x); // => x is now 42

    inner_proc :: () #expand {
        `x = 42;
    }
}

main :: () {
    proc();
}
```

Jai does not support closures (also called captures of variables). The technique demonstrated here is a way to emulate a closure.

> Use a macro to get the functionality of closures in Jai.

In § 15.1.3 we showed code that iterated over a linked list with a while loop.
Wouldn't it be nice if we could do this with a for loop?

### 26.5.4 Using a macro with #insert,scope()
See *26.22_insert_scope.jai*:
```c++
#import "Basic";

bubble_sort :: (arr: [] $T, compare_code: Code) #expand { // (1)
  for 0..arr.count-1 {
    for i: 1..arr.count-1 {
      a := arr[i-1];
      b := arr[i];
      if !(#insert,scope() compare_code) { // (2) arr[i-1] > arr[i], so swap them
        t := arr[i];
        arr[i] = arr[i-1];
        arr[i-1] = t;
      }
    }
  }
}

main :: () {
    arr: [10] int;
    arr = .[23, -89, 54, 108, 42, 7, -2500, 1024, 666, 0];

    bubble_sort(arr, #code (a <= b));
    print("sorted array: %\n", arr);
    // => sorted array: [-2500, -89, 0, 7, 23, 42, 54, 108, 666, 1024]

    for i: 0..9  arr[i] = cast(int) random_get() % 100;
    bubble_sort(arr, #code (a < b));
    print("sorted array: %\n", arr);
    // => sorted array: [-58, -43, -33, -33, -25, 6, 26, 78, 89, 92]
}
```

The macro `bubble_sort` defined in line (1) takes an array and a piece of code to compare subsequent item-pairs of the array. The `#insert,scope()` in (2) (formerly #insert_internal) makes it possible to use the outer macro-variables a and b in compare_code, so it allows code to access variables in the local scope.  

It lets you specify the scope into which to insert the target Code or string, by saying #insert,scope(target). 'target' is a Code that must be constant at compile-time.

The scope where the Code lives is used as the enclosing scope for the #insert (which determines how identifiers inside the inserted code are resolved).   
If they are not in order, they are swapped.
`#insert,scope() compare_code` inserts a comparison code (a <= b) into a bubble sort. The inserted code acts like a comparison function, except without the drawbacks of function pointer callback performance cost.
This example also shows that a macro can be polymorphic.

### 26.5.5 Using a macro for swapping values
See *26.28_swap_macro.jai*:
```c++
#import "Basic";

swap :: (a: Code, b: Code) #expand {
  t := (#insert a);
  (#insert a) = (#insert b);
  (#insert b) = t;
}

main :: () {
    a, b := 3, 5;
    print("Pre-swap:  a is %, b is %\n", a, b);
    swap(a, b);    // (2)
    print("Post-swap: a is %, b is %\n", a, b);
}

/*
Pre-swap:  a is 3, b is 5
Post-swap: a is 5, b is 3
*/
```

This macro uses Code arguments and #insert to insert the values. It also provides type-checking: a and b must be of the same type. 

### 26.5.6 Measuring performance with a macro
Remember § 6B.2 where we used get_time() to measure performance of a procedure (see 6B.2_get_time.jai) ? We can also do this with a macro `perf_measure`:

See *26.33_measure_performance.jai*:
```c++
#import "Basic";

factorial :: (n: int) -> int {
    if n <= 1  return 1;
    return n * factorial(n-1);
}

perf_measure :: (code: Code) #expand {
    start_time := get_time();
    #insert code;   // (1)
    elapsed := get_time() - start_time;
    print("Piece of code took % ms\n", elapsed * 1000);
    // => Factorial 20 took 0.1857 ms
}

main :: () {
    code :: #code print("Factorial 20 is %\n", factorial(20));
    perf_measure(code);
    // Factorial 20 is 2432902008176640000
    // Piece of code took 0.2209 ms
}
```

Why use a macro? Because you want to #insert at compile-time the piece of code of which you want to measure the performance. This happens in line (1).


## 26.6 Using a for-expansion macro to define a for loop
As easy as it is to for-loop over an array, this is not defined for other composite data-structures, such as the linked list we discussed in § 12.6. Jai has a slick mechanism, which makes writing a custom iterator for a custom data container very easy.
This can be done with a macro, by defining a so-called *for_expansion*:

See *26.8_linked_list_for_expansion.jai*:
```c++
#import "Basic";

LinkedList :: struct {
    data: s64; 
    next:  *LinkedList;
}

main :: () {
    lst := New(LinkedList); // lst is of type *LinkedList
    lst.data = 0;

    a :=  New(LinkedList); 
    a.data = 12;
    lst.next = a;
    
    b  := New(LinkedList);
    b.data = 24;
    a.next = b;
    
    c  := New(LinkedList);
    c.data = 36;
    b.next = c;

    c.next = null; 

    print("List printed in a for loop: \n");
    print("The list starts with a %\n", lst.data);
    // version (1)
    for_expansion :: (list: *LinkedList, body: Code, flags: For_Flags) #expand {  // (1)
        iter := list;   // (2)
        i := 0;
        while iter != null {    // (3)
            iter = iter.next;
            if !iter break;     // (4)
            `it := iter.data;   // (5)
            `it_index := i;     // (6)
            #insert body;       // (7)
            i += 1;             // (8)
        }
    }

    for lst {                   // (9)
        print("List item % is %\n", it_index, it);  // (10)
    }

    // Version (2):
    for_expansion :: (list: *LinkedList, body: Code, flags: For_Flags) #expand {  
        `it := list;        
        `it_index := 0;
        while it {            
            #insert body;       
            it = it.next;
            it_index += 1;   
        }
    }

    for lst {                   
        print("List item % is %\n", it_index, it.data);  // (11)
    }

// List printed in a for loop:
// The lists starts with a 0
// List item 0 is 12
// List item 1 is 24
// List item 2 is 36

    free(a); free(b); free(c); free(lst);
}
```

We take the linked-list example from § 12.6, the same struct ListNode and *ListNode variable lst.  
A for-expansion macro is a special kind of macro that uses `i` as counter and `iter` as iteration variable (defined in line (2)).  
The macro is defined in line (1) with the signature:  
`for_expansion :: (list: *ListNode, body: Code, flags: For_Flags) #expand`   
`for_expansion` takes in three parameters: a pointer to the data structure one wants to use the for loop on, a `Code` datatype, and a `For_Flags` flags.    
It uses the same while loop as in § 15.1.3. Line (4) assures we break out of the loop if iter gets the null value: break when iter is empty (if this would not be here, the program would crash, try it out!).  

Because we emulate a for-loop, we must give values for the variables  
`it_index`  : which is of course the counter `i` (line (6))  
and `it`    : which is `iter.data` (line (5))
They both have to be prefixed with a back-tick, because they are outer variables to the macro.  

The `#insert body;` in line (7) is responsible for printing out the data. `body` is the 2nd argument, and is of type Code. `body` denotes the body of the for-loop, and it is substituted into the expanded code. Its content is the `print` statement in line (10).  
So `#insert` is used inside macros to insert code in the expansion.  
(There is also a variant directive **#insert,scope()**, which allows you to insert code in the macro itself.  
A macro often takes an argument suitably named `body: Code`, which is then used to insert in the expansion: `#insert body`.)

The `For_Flags` enum_flags is found in module *Preload_.jai* with the following definition:
```c++
For_Flags :: enum_flags u32 {
  POINTER :: 0x1; // this for-loop is done by pointer.
  REVERSE :: 0x2; // this for-loop is a reverse for loop.
}
```
Line (8) simply increments our counter variable `i`.  
Now we can print out the data from a linked list in a for-loop like any other array (see line (9))!

But we can do better! (see for_expansion macro Version 2). Just leave out the temporary variables `iter` and `i` and work only with it and it_index. Also note you only have to backtick the variables the first time you use these. Note that in our actual `for call, we have to print `it.data`.

> The `for_expansion` may have any other name like `looping`, so that you can define different for_expansions. It is called like this:
> `for :looping v, n: data_structure`
> Also it and it_index can be renamed, like this: 
> `for :looping v, n: data_structure  print("[%] %\n", n, v);`
> When you have several for_expansions looping1, looping2 and so on, you could have:
> `for :looping1 v, n: data_structure`
> `for :looping2 v, n: data_structure`
> Our code would then become:

See *26.8B_linked_list_for_expansion.jai*:
```c++
#import "Basic";

LinkedList :: struct {
    data: s64; 
    next:  *LinkedList;
}

main :: () {
    lst := New(LinkedList); // lst is of type *LinkedList
    lst.data = 0;

    a :=  New(LinkedList); 
    a.data = 12;
    lst.next = a;
    
    b  := New(LinkedList);
    b.data = 24;
    a.next = b;
    
    c  := New(LinkedList);
    c.data = 36;
    b.next = c;

    c.next = null; 

    print("List printed in a for loop: \n");
    print("The list starts with a %\n", lst.data);

    looping :: (list: *LinkedList, body: Code, flags: For_Flags) #expand {  
        `it := list;        
        `it_index := 0;
        while it {            
            #insert body;       
            it = it.next;
            it_index += 1;   
        }
    }

    for :looping lst {                   
        print("List item % is %\n", it_index, it.data);  
    }

    print("\n");

    for :looping v, n: lst {                   
        print("List item % is %\n", n, v.data);  
    }

// List printed in a for loop: 
// The list starts with a 0
// List item 0 is 0
// List item 1 is 12
// List item 2 is 24
// List item 3 is 36
//
// List item 0 is 0
// List item 1 is 12
// List item 2 is 24
// List item 3 is 36

    free(a); free(b); free(c); free(lst);
}
```
> Iterating over data-structures with for was the primary reason for introducing macros in Jai.

Now let's make the same for-loop for a double linked-list:

## 26.7 A for-expansion macro for a double linked-list
Let's now define a more general linked list as having a first and a last Node (see line (1)), whereby Node is recursively defined(see line (2)) as having a value, a previous and a next Node. Another advantage is that the type of the value (and Node) is polymorph written as T.

See *26.9_double_linked_list.jai*:
```c++
#import "Basic";
// Debug :: #import "Debug";

LinkedList :: struct (T: Type) {  // (1)
    first: *Node(T); 
    last:  *Node(T);
}

Node :: struct (T: Type) {          // (2)
    value: T;
    prev: *Node(T);
    next: *Node(T);
}

// Version 1:
for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {  
    iter := list.first;     
    i := 0;
    // Debug.breakpoint();
    while iter {            
        `it := iter.value;   
        `it_index := i;      
        iter = iter.next;
        #insert body;        
        if !iter break;    
        i += 1;             
    }
}

// Version 2:
for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {  
    `it := list.first;     
    `it_index := 0;
    while it {            
        #insert body;        
        it = it.next;
        it_index += 1;             
    }
}

// Version 3A:
for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {
    `it := ifx flags == For_Flags.REVERSE   list.last   else    list.first;  // (6)
    `it_index := ifx flags == For_Flags.REVERSE  2  else    0; ;   
    while it {            
        #insert body;
        if flags == For_Flags.REVERSE  { 
            it = it.prev;
            it_index -= 1; 
        } else          {  
            it = it.next;
            it_index += 1;   
        }        
    }
}

main :: () {
    // Debug.init();
    // Debug.attach_to_debugger();
    a : Node(int);      // (3)
    b : Node(int);
    c : Node(int);
    a.value = 10;
    b.value = 20;
    c.value = 30;
    a.next = *b;
    b.prev = *a;
    b.next = *c;
    c.prev = *b;

    list: LinkedList(int);
    list.first = *a;
    list.last = *c;

    print("List printed in a for loop: \n");
   
    for list {                     // (4) 
        print("List item % is %\n", it_index, << it);      
    }
    print("\n");
    
    for < list {                   // (5) 
        print("List item % is %\n", it_index, << it);      
    }

    // no need to free the variables a,b and c as in the following line, 
    // because they are allocated on the stack:
    // free(*a); free(*b); free(*c); free(*list);
    // if they were create with New(), then the line above would be necessary

}

/* Version 1:
List printed in a for loop: 
List item 0 is 10
List item 1 is 20
List item 2 is 30
*/

/* Version 2:
List printed in a for loop: 
List item 0 is {10, null, 9c_e92f_f990}
List item 1 is {20, 9c_e92f_f9a8, 9c_e92f_f978}
List item 2 is {30, 9c_e92f_f990, null}
*/

/* Version 3A:
List item 2 is {30, d5_6fd4_fcb0, null}
List item 1 is {20, d5_6fd4_fcc8, d5_6fd4_fc98}
List item 0 is {10, null, d5_6fd4_fcb0}
*/
```

In lines (3) and following we define three Nodes a, b and c, give them values, link them together, and then link a LinkedList lst to them. We don't use New, so these Nodes are stack-allocated.   

Now we want to be able to write a for-loop like the one in (9), printing out the node position and its value. If we compile this, we get the `Error: Undeclared identifier 'for_expansion'`. So Jai tells us we need to write a for_expansion macro to accomplish this.    

This can be done with almost exactly the same code as in example 26.8 (because of the different structure, we need to move our break statement). The loop starting in (4) iterates over all the nodes.  

This example also shows that the for_expansion macro can be outside of main(). In fact, you could make a module for it and import that!  
If you want to experience how easy it is to debug a macro, just uncomment the lines that start with // Debug, and debug until you reach the break when `iter` has become a pointer with value null (here this is the case for c.next).  

But we can do better! (see for_expansion macro Version 2). Just leave out the temporary variables `iter` and `i` and work only with it and it_index.  
Also note you only have to backtick the variables the first time you use these. Version 2 also prints out the pointers, so we see that a has a prev which is null, and c has a next that is null.

Suppose we want to print out list backwards, like in line (5):  `for < list`
Then we need `For_flags`, this is an enum defined in module _Preload_ with 2 possible values, POINTER (1) and REVERSE(2).  
This is done in Version 3A:
We test on For_Flags.REVERSE to either start with list.first or list.last. Using ifx, we can assign the if or else value to \`it. (But we don't know the nodes count, so we hardcoded the last position as 2).  
We do the same in the while loop, going to next or prev and incrementing or decrementing `it_index`. With version 3A there is one compiled version for the normal for and the for <.

**Exercise**  
Use #if instead of ifx  (see for_expansion_version3B.jai) so that you get 2 different compiled versions, one for the for, and one for the reversed for (<).
How many compiled versions do you have when using if instead of #ifx? 

See also [Named Custom for Expansion](https://jai.community/docs?topic=176) for an example of a for_expansion for a Tree structure.

## 26.8 A for-expansion macro for an array
This seems totally unnecessary, because a for-loop is built-in for arrays! But it could be useful in case the for-loop has to do something additional, in which case it is beneficial to define it in one place as a for_expansion macro, instead of writing the addition in every for loop on your array.

See *26.34_abstracting_loop.jai*:
```c++
#import "Basic";

Player :: struct {
    name: string;
    score: u8;
}

players: [..]Player;

for_expansion :: (_: *type_of(players), body: Code,   // (1)
                  flags: For_Flags) #expand {
    for `it, `it_index: players {
        print("inside macro! \n");
        if it_index >= players.count  break;
        #insert body;
    }
}

player_loop :: (_: *type_of(players), body: Code,      // (2)
                  flags: For_Flags) #expand {
    for `it, `it_index: players {
        print("inside macro player_loop! \n");
        if it_index >= players.count  break;
        #insert body;
    }
}

main :: () {
    p1 := Player.{"Jane", 82};
    p2 := Player.{"John", 75};
    array_add(*players, p1);
    array_add(*players, p2);
    for players     print("Player no % is %\n", it_index, it);   // (3)
    /*
    Player no 0 is {"Jane", 82}
    Player no 1 is {"John", 75}
    */

    for player: players {                                        // (4)
        print("Player is %\n", player);
    }
    /*
    Player is {"Jane", 82}
    Player is {"John", 75}
    */

    // This uses the for_expansion macro
    for :for_expansion   player: players {                         // (5)
         print("Player is %\n", player);
    }
    /*
    inside macro!
    Player is {"Jane", 82}
    inside macro!
    Player is {"John", 75}
    */

     // This uses the player_loop macro
    for :player_loop   player, ix: players {                       // (6)
         print("Player % is %\n", ix, player);
    }
    /*
    inside macro player_loop!
    Player 0 is {"Jane", 82}
    inside macro player_loop!
    Player 1 is {"John", 75}
    */
}

```

In the code above we have an array `players` of type `Player`. In lines (3) and (4) we call familiar for-loops on this array. In line (1) we have defined a for_expansion macro, that does something additional (printing, logging, checking, and so on). To call it, we have to write:  
` for :for_expansion {}`  
as in line (5).  
We can of course give it another name like `player_loop`, and/or use the index besides the value, and/or make different for_expansion routines. This we can write like in line (6):  
` for :player_loop   player, ix: players {}`

**Exercise**
Here is a definition of a polymorphic struct:  
```c++
FixedVector :: struct($T: Type, N: int) {
  values : [N]T;
  count : int; // number of items already stored in values
}
```

Make an instantiation of this struct for int items and N == 10.
Write a `push` proc add a new value to this struct. Then write a `for_expansion` macro to loop over it and print out the values.
Write a 2nd version that skips values equal to 5.
(See *for_expansion_fixed_vector.jai*)


