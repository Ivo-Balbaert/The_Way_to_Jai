#import "Basic";

ListNode :: struct {
    data: s64; 
    next:  *ListNode;
}

main :: () {
    lst := New(ListNode); // lst is of type *ListNode
    lst.data = 0;

    a :=  New(ListNode);  // a is of type *ListNode
    a.data = 12;
    lst.next = a;
    
    b  := New(ListNode);
    b.data = 24;
    a.next = b;
    
    c  := New(ListNode);
    c.data = 36;
    b.next = c;

    c.next = null; // the list ends here for the time being

    print("Our list is: %\n", lst); // => Our list is: 2ba_b8c6_6d70
    print("List data is % -> % -> % -> % \n", lst.data, a.data, b.data, c.data); 
    // => List data is 0 -> 12 -> 24 -> 36

    // free memory:
    free(a); free(b); free(c); free(lst);
}