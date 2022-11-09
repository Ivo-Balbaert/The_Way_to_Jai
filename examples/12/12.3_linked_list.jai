#import "Basic";

LinkedList :: struct {
    data: s64; 
    next:  *LinkedList;
}

main :: () {
    lst := New(LinkedList); // lst is of type *LinkedList
    lst.data = 0;

    a :=  New(LinkedList);  // a is of type *LinkedList
    a.data = 12;
    lst.next = a;
    
    b  := New(LinkedList);
    b.data = 24;
    a.next = b;
    
    c  := New(LinkedList);
    c.data = 36;
    b.next = c;

    c.next = null; // the list ends here for the time being

    print("Our list is: %\n", lst); // => Our list is: 2ba_b8c6_6d70
    print("List data is % -> % -> % -> % \n", lst.data, a.data, b.data, c.data); 
    // => List data is 0 -> 12 -> 24 -> 36

    // free memory:
    free(a); free(b); free(c); free(lst);
}