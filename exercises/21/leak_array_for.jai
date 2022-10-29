#import "Basic"()(MEMORY_DEBUGGER=true);

main :: () {
    N :: 4;
    static_array: [N]int = .[0, 1, 2, 3]; 
    dynamic_array : [..]int;
    array_view : []int = static_array;

    for static_array   static_array[it_index] = it;
    // for 0..static_array.count-1  static_array[it_index] = it; // (1) => Error: Undeclared identifier 'it_index'.
    for static_array print("SA item[%] = % - ",  it_index, it);
    // => SA item[0] = 0 - SA item[1] = 1 - SA item[2] = 2 - SA item[3] = 3 - 
    print("\n");
   
    array_add(*dynamic_array, 4);
    array_add(*dynamic_array, 5);
    array_add(*dynamic_array, 6);
    array_add(*dynamic_array, 7);
    for dynamic_array   dynamic_array[it_index] = it;  // (2)
    for dynamic_array print("DA item[%] = % - ", it_index, it);  
    // => DA item[0] = 4 - DA item[1] = 5 - DA item[2] = 6 - DA item[3] = 7 -
    print("\n");

    for array_view   array_view[it_index] = it;   
    for array_view print("AV item[%] = % - ", it_index, it);
    // => AV item[0] = 0 - AV item[1] = 1 - AV item[2] = 2 - AV item[3] = 3 -
    print("\n");
    
    for n: static_array     print("% - ", n); // (2) => 0 - 1 - 2 - 3 
    // for n: static_array     print("% - ", it); // => Error: Undeclared identifier 'it'.
    print("\n");

    for value, index: dynamic_array {         // (3)
        print("DynArray[%] = % - ", index, value);
    }
    // => DynArray[0] = 4 - DynArray[1] = 5 - DynArray[2] = 6 - DynArray[3] = 7 -
    print("\n");

    // changing an array:
    arr := int.[1, 2, 3, 4, 5];
    // take all the values in an arr and square the items
    for *elem: arr {            // (4)
        val := <<elem;
        <<elem = val * val; 
    }
    print("arr is: %\n", arr); // => arr is: [1, 4, 9, 16, 25]

    // reversing the iteration:
    static_array2 := int.[1, 2, 3, 4, 5];
    for < static_array2  print(" % ", it);  // (5)
    // => 5  4  3  2  1

    array_free(dynamic_array);

    report := make_leak_report();   // (2)
    log_leak_report(report);        // (3)
} 

/* without free:
----- 64 bytes in 1 allocation -----
realloc        c:/jai/modules/Basic/module.jai:105
array_reserve  c:/jai/modules/Basic/Array.jai:237
maybe_grow     c:/jai/modules/Basic/Array.jai:269
array_add      c:/jai/modules/Basic/Array.jai:84
main           d:/Jai/The_Way_to_Jai/exercises/21/leak_array_for.jai:15

Total: 64 bytes in 1 allocation.

Marked as non-leaks: 0 bytes in 0 allocations.
*/

/* with array_free:
Total: 0 bytes in 0 allocations.

Marked as non-leaks: 0 bytes in 0 allocations.
*/