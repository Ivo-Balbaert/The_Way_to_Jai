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