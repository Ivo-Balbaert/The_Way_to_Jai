#import "Basic";

LinkedList :: struct {
    data: s64; 
    next:  *LinkedList;
}

main :: () {
    lst := New(LinkedList); // lst is of type *LinkedList
    lst.data = 0;

    a :=  New(LinkedList); 
    a.data = 12;
    lst.next = a;
    
    b  := New(LinkedList);
    b.data = 24;
    a.next = b;
    
    c  := New(LinkedList);
    c.data = 36;
    b.next = c;

    c.next = null; 

    print("List printed in a for loop: \n");
    print("The list starts with a %\n", lst.data);
    // version (1)
    // for_expansion :: (list: *LinkedList, body: Code, flags: For_Flags) #expand {  // (1)
    //     iter := list;   // (2)
    //     i := 0;
    //     while iter {            // (3)
    //         iter = iter.next;
    //         if !iter break;     // (4)
    //         `it := iter.data;   // (5)
    //         `it_index := i;     // (6)
    //         #insert body;       // (7)
    //         i += 1;             // (8)
    //     }
    // }

    // for lst {                   // (9)
    //     print("List item % is %\n", it_index, it);  // (10)
    // }

    // Version (2):
    for_expansion :: (list: *LinkedList, body: Code, flags: For_Flags) #expand {  // (1)
        `it := list;        
        `it_index := 0;
        while it {            
            #insert body;       
            it = it.next;
            it_index += 1;   
        }
    }

    for lst {                   
        print("List item % is %\n", it_index, it.data);  
    }

// List printed in a for loop:
// The lists starts with a 0
// List item 0 is 12
// List item 1 is 24
// List item 2 is 36

    free(a); free(b); free(c); free(lst);
}