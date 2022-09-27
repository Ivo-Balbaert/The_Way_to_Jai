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

    print("List printed in a while loop: \n");
    print("% -> ", lst.data);
    r := lst.next;              // (1)
    while r {                   // (2) 
        print("% -> ", r.data);
        r = r.next;             // (3) 
    }
    print("\n");
    // => List printed in a while loop:
    // => 0 -> 12 -> 24 -> 36 ->
    free(a); free(b); free(c); free(lst);
}
