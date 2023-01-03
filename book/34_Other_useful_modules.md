# 34 Other useful modules.

## 34.1 Sorting
This is covered by the _Sort_ module, which contains implementations of bubble sort and quicksort.
(We already used bubble sort in program 30.11_using_notes.jai - § 30.12)
Here we present a simple example for using these procs.

See *34.1_sorting.jai*:
```c++
#import "Basic";
#import "Sort";
#import "String";

main :: () {
    arrf := float.[8, 108, 42, 5, 3.14, 17, -5, -272];
    arrs := string.["the", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog"];

    quick_sort(arrf, compare_floats);
    print("arrf quick-sorted is %\n", arrf); 
    // => [-272, -5, 3.14, 5, 8, 17, 42, 108]

    quick_sort(arrs, compare_strings);
    print("arrs quick-sorted is %\n", arrs); 
    // => arrs quick-sorted is ["brown", "dog", "fox", "jumped", "lazy", "over", "quick", "the", "the"]

    arrf1 := float.[8, 108, 42, 5, 3.14, 17, -5, -272];
    arrs1 := string.["the", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog"];

    bubble_sort(arrf1, compare_floats);
    print("arrf1 bubble-sorted is %\n", arrf1); 
    // => [-272, -5, 3.14, 5, 8, 17, 42, 108]

    bubble_sort(arrs1, compare);
    print("arrs1 bubble-sorted is %\n", arrs1); 
    // => ["brown", "dog", "fox", "jumped", "lazy", "over", "quick", "the", "the"]
}
```

Both sorting procedures need a 2nd argument. This is a procedure which specifies how to compare 2 values of the given type. The `compare` proc comes from the _String_ module
quick_sort is also used in how_to/460.

## 34.2 The Hash_Table module
This is a really useful data structure, which most languages implement, Jai included. A hash table (sometimes called hash map) is a data structure that implements an associative array abstract data type. It's a structure that can map keys to values.
Hash tables let us implement things like phone books or dictionaries; in them, we store the association between a value (like a dictionary definition of the word "lamp") and its key (the word "lamp" itself). We can use hash tables to store, retrieve, and delete data uniquely based on their unique key.
A hash table uses a _hash_ function to compute an index, also called a hash code,
 into an array of buckets or slots, where the associated value can be found.
(For more info, see: [https://en.wikipedia.org/wiki/Hash_table])  

See *34.2_hash_table.jai*:
```c++
#import "Basic";
#import "Hash_Table";

main :: () {
    table := New(Table(string, string));            // (1)

    table_add(table, "John Smith" , "521-8976" );   // (2)
    table_add(table, "Lisa Smith" , "521-1234" );
    table_add(table, "Sandra Dee" , "521-9655" );

    lookup := "Lisa Smith";
    telnr, success := table_find(table, lookup);
    if success print("The telnr of % is %\n", lookup, telnr);
    else print("The telnr of % was not found\n", lookup);
    // The telnr of Lisa Smith is 521-1234

    lookup = "Jane Doe";
    telnr, success = table_find(table, lookup);
    if success print("The telnr of % is %\n", lookup, telnr);
    else print("The telnr of % was not found\n", lookup);
    // The telnr of Jane Doe was not found

    for table {                                     // (3)
        key, value := it_index, it;
        print("key is % and value is %\n", key, value);
    }
    print("\n");
    /*
    key is Sandra Dee and value is 521-9655
    key is John Smith and value is 521-8976
    key is Lisa Smith and value is 521-1234
    */

    del := "Lisa Smith";
    table_remove(table, del);                   // (4)
    for table {                                     
        key, value := it_index, it;
        print("key is % and value is %\n", key, value);
    }
    /*
    key is Sandra Dee and value is 521-9655
    key is John Smith and value is 521-8976
    */
}
```

A new hash table is created on the heap as in line (1). Key-value pairs are added to with with the proc `table_add`, and a pair is deleted with the proc `table_remove`.
You can iterate over the table with a for-loop as in line (3).

