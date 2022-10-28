#import "Basic";

ListNode :: struct {
    data: s64; 
    next:  *ListNode;
}

main :: () {
    lst := New(ListNode); // lst is of type *ListNode
    lst.data = 0;

    a :=  New(ListNode); 
    a.data = 12;
    lst.next = a;
    
    b  := New(ListNode);
    b.data = 24;
    a.next = b;
    
    c  := New(ListNode);
    c.data = 36;
    b.next = c;

    c.next = null; 

    print("List printed in a for loop: \n");
    print("The list starts with a %\n", lst.data);
    for_expansion :: (list: *ListNode, body: Code, flags: For_Flags) #expand {  // (1)
        iter := list;   // (2)
        i := 0;
        while iter {            // (3)
            iter = iter.next;
            if !iter break;     // (4)
            `it := iter.data;   // (5)
            `it_index := i;     // (6)
            #insert body;       // (7)
            i += 1;             // (8)
        }
    }

    for lst {                   // (9)
        print("List item % is %\n", it_index, it);  // (10)
    }

// List printed in a for loop:
// The lists starts with a 0
// List item 0 is 12
// List item 1 is 24
// List item 2 is 36

    free(a); free(b); free(c); free(lst);
}