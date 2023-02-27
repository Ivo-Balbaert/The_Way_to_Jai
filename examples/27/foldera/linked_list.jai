// to use as ebud example
// takes a long time to execute ? crash !!
// Debug: Access violation writing location 0x0000000000000008.
// Solution: New(Listnode);
// Unable to read memory :  a.value / a.next
#import "Basic";
#import "Debug";

List :: struct {
    head: *Listnode;
}

Listnode :: struct {
    value: s64; 
    next:  *Listnode;
}

main :: () {
    init();
    defer print("Program ended gracefully");

    lst : List;

    a  :  *Listnode;
    a.value = 1;
    b  :  *Listnode;
    c  :  *Listnode;

    lst.head = a;
    a.next = b;
    //b.next = c;
}

// #run main();