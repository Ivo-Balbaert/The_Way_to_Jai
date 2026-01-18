# Chapter 7 – Scope of Variables
It is important to know how long a variable can be used and stay active, that is what its _lifetime_, or _scope_ is. When a variable is no longer active (it goes out of scope, its lifetime has ended), the memory it occupies can and must be freed (see § 7.1.2 and § 11).

In fact, there is a hierarchy of scopes: if you use an identifier, and it's not defined inside the current scope, the compiler looks upward into parent scopes.

## 7.1 - Data scope and imperative scope                                           
See *7.1_scope.jai*:

```jai
#import "Basic";

// global scope
global_var := 42;
GLOBAL_CONSTANT :: 999;

main :: () {
    // local procedure scope in main block:
    local_main_var := 7;
    // local scope in anonymous code block:
    { (1) //  block scope: these are only known inside this block
        CONSTANT :: 100;
        n := 10;
    // print their values
        print("CONSTANT is %\n", CONSTANT);
        print("n is %\n", n);

        print("local_main_var is %\n", local_main_var);  // => local_main_var is 7
    }
    print("local_main_var is %\n", local_main_var);  // => local_main_var is 7
    // CONSTANT and n are NOT known outside the block in which they are defined
    // Try to print them out here:
    // print("n is %\n", n); // Error:  Undeclared identifier 'n'.
}
```

There are two different kinds of scopes: _data scope_ and _imperative scope_:  
  A _data scope_ (also called _global scope_ or _application scope_, like in the lines before main) is outside of any procedures, including main. There's no actively running code in such a scope, you can't call a procedure to run during runtime. Data scope only contains declarations of variables like you have at the top level of a file. There's no notion of time in a data scope, and different declarations are unordered with respect to each other. In this scope global constants and variables can be defined, as well as enums, struct types and procedures.
  By default, all declarations in a source file go into the application scope; they are _exported_. In § 8B, we'll see a way to make exceptions to this rule.   

  _Imperative_ (or _procedural_) scopes represent the code inside procedures like `main()`, which can be run at runtime. We'll talk about procedures in § 17.
  The statements in these scopes are to be executed from top to bottom.

### 7.1.1 - Global constants and variables
Variables or constants like global_var or GLOBAL_CONSTANT that are declared at the top-level of a source file are known throughout the whole code file. When this code loads other code files, that loaded code also sees them. They are called global constants and global variables, and are said to have global or top-level scope.  

They will occupy memory throughout the entire time the program is running. That is one disadvantage for global variables. Variables defined inside `main` also stay active until `main` ends, but they are not visible in local procedures or procedures called from `main`.  


### 7.1.2 - Local variables
All other variables or constants are defined and only known within the code block in which they are defined: they are local variables and have local scope: they automatically get freed when the procedure is exited (just after the closing }).   
Procedures define local scope, as well as all kinds of coding structures for conditions and repetitions (see § 14-15).

We can also define a new local scope simply by starting a new _anonymous code block_  (surrounded by { } ) as in line (1) at the top-level or inside any other block. 

Whenever we try to use a variable n in a scope in which it is not defined, we get the following error: `Error: Undeclared identifier 'n'`.

Unlike Rust's behavior, a block cannot return a value to be assigned, if you try you get  `Error: Unable to parse an expression to the right of this binary operator.`

## 7.2 - Shadowing of variables
See *7.2_shadowing.jai*:

```jai
#import "Basic";

main :: () {
    outer := 42;
    {
        outer := 99; // (1) this is a new variable in the block
        print("outer in block: %\n", outer); 
        // => outer in block: 99
    }
    print("outer from main: %\n", outer);    
    // => outer from main: 42
}
```

A variable in an inner block can shadow a variable with the same name from an outer block, that is: inside the inner block, the inner variable takes precedence: see the `outer` variable in line (1) which shadows the `outer` variable defined outside the block.

> Shadowing can be confusing, use it only when it is really necessary.

Procedures can use global variables from a data scope.
A procedure, that is defined inside another procedure, cannot use the local variables of that outer procedure, because it has to be able to run independently by itself (see example § 17.2). However, it can use all constants, defined in any outer scope, also imperative. Because procedures are constants, they can also be called. 

Caution: Global variables are nearly indispensable in game development, but in (other) applications, they can be the cause of very difficult-to-find bugs. If a variable can be changed everywhere in code, where is it changed to a not-permitted value? Be very careful when using them!

