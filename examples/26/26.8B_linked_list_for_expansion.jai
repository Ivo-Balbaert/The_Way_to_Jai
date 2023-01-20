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

    looping :: (list: *LinkedList, body: Code, flags: For_Flags) #expand {  
        `it := list;        
        `it_index := 0;
        while it {            
            #insert body;       
            it = it.next;
            it_index += 1;   
        }
    }

    for :looping lst {                   
        print("List item % is %\n", it_index, it.data);  
    }

    print("\n");

    for :looping v, n: lst {                   
        print("List item % is %\n", n, v.data);  
    }

// List printed in a for loop: 
// The list starts with a 0
// List item 0 is 0
// List item 1 is 12
// List item 2 is 24
// List item 3 is 36
//
// List item 0 is 0
// List item 1 is 12
// List item 2 is 24
// List item 3 is 36

    free(a); free(b); free(c); free(lst);
}