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
    table_remove(table, del);               // (4)
    for table {                                     
        key, value := it_index, it;
        print("key is % and value is %\n", key, value);
    }
    /*
    key is Sandra Dee and value is 521-9655
    key is John Smith and value is 521-8976
    */
}