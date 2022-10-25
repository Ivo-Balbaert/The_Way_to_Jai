# 26 - Meta-programming and macros

A 'meta-program' is a piece of code that alters (or 'programs') an existing program (another piece of code).
In Jai, this takes place solely at compile-time. The compiler gives you the source code in AST format (Abstract Syntax Tree) for you to modify.

> Jai offers arbitrary compile-time execution, with powerful meta-programming features to modify your code in whatever way you want.

This functionality has been built into the language from the start. Meta-programs can modify the program in arbitrarily complex ways easily. 

In order to do meta-programming, full type-information is needed. Jai has that available at compile-time (see§ 5.1.4, § 9, § 16),  but also retains static type information for every structure available at runtime (see § 26.1).
In § 13.6 and § 15.4 we discussed some useful reflection methods for enums. In § 15.5 we highlighted useful reflection methods for structs, useful for serialization (see § 15.6).

Using type info to meta-program is also called _reflection_ or _introspection_ in other languages.

We already talked about running code at compile time as early as § 3.2.4. Jai provides full compile-time code execution, meaning that all Jai code can also be executed while compiling.

> Remark: because all of this processing happens at compile-time, there is a natural overlap between this chapter and § 27.

## 26.1 The type table
See _26.1_type_table.jai_:
```c++
#import "Basic";
#import "Compiler";

main :: () {
    x1 := 3.14;

    table := get_type_table();         // (1) 

    print("The type table has % entries: \n", table.count); 
    // => The type table has 355 entries:
    for table {
        print("%: ", it_index);
        print("  type: %\n", it.type); 
    }
}

/*
The type table has 355 entries: 
0:   type: INTEGER
1:   type: INTEGER
2:   type: VARIANT
3:   type: INTEGER
...
350:   type: STRUCT
351:   type: PROCEDURE
352:   type: PROCEDURE
353:   type: POINTER
354:   type: ARRAY
*/
```

Full introspection data is available for all structs, functions, and enums at runtime. A structure called **_type_table** contains all variables with their types; this is populated at compile-time. Then this data structure is stored in the data segment of the executable file, making it available at runtime.
This structure is not directly accessible, you have to use the proc `get_type_table` from module _Compiler_,  as we did in line (1).  
`table` has as type [] *Type_Info.  

(See also build option: runtime_storageless_type_info  in § 27.?? )

