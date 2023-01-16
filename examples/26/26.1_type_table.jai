#import "Basic";
#import "Compiler";

main :: () {
    x1 := 3.14;

    table := get_type_table();         // (1) 

    print("The type table has % entries: \n", table.count); 
    // => The type table has 355 entries:
    for table {
        print("%: ", it_index);
        print("  type: % ", it.type); 
        print("  size: %\n", it.runtime_size); 
    }
}

/*
The type table has 355 entries: 
0:   type: INTEGER   size: 8
1:   type: INTEGER   size: 2
2:   type: VARIANT   size: 2
3:   type: INTEGER   size: 1
...
381:   type: STRUCT   size: 16
382:   type: PROCEDURE   size: 8
383:   type: PROCEDURE   size: 8
384:   type: POINTER   size: 8
385:   type: ARRAY   size: 16
*/