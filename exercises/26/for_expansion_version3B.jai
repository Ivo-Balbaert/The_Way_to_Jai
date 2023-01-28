// compare to 26.9_doubly_linked_list.jai
#import "Basic";

Linked_List :: struct (T: Type) {  // (1)
    first: *Node(T); 
    last:  *Node(T);
}

Node :: struct (T: Type) {          // (2)
    value: T;
    prev: *Node(T);
    next: *Node(T);
}

for_expansion :: (list: Linked_List, body: Code, flags: For_Flags) #expand {
    #if flags == For_Flags.REVERSE    {
        `it := list.last;
        `it_index := 2;
    } else { 
        `it := list.first;
        `it_index := 0;
    }
    while it {            
        #insert body;
        #if flags == For_Flags.REVERSE  { 
            it = it.prev;
            it_index -= 1; 
        } else { 
             it = it.next;
             it_index += 1;  
        }               
    }
}

main :: () {
    // Debug.init();
    // Debug.attach_to_debugger();
    a : Node(int);      // (3)
    b : Node(int);
    c : Node(int);
    a.value = 10;
    b.value = 20;
    c.value = 30;
    a.next = *b;
    b.prev = *a;
    b.next = *c;
    c.prev = *b;

    list: Linked_List(int);
    list.first = *a;
    list.last = *c;

    print("List printed in a for loop: \n");
   
    for list {                     // (4) 
        print("List item % is %\n", it_index, << it);      
    }
   
    for < list {                   // (5) 
        print("List item % is %\n", it_index, << it);      
    }
}

/*
List printed in a for loop: 
List item 0 is {10, null, 84_8e34_fdf0}
List item 1 is {20, 84_8e34_fe08, 84_8e34_fdd8}
List item 2 is {30, 84_8e34_fdf0, null}
List item 2 is {30, 84_8e34_fdf0, null}
List item 1 is {20, 84_8e34_fe08, 84_8e34_fdd8}
List item 0 is {10, null, 84_8e34_fdf0}
*/

// How many compiled versions do you have when using if instead of #ifx?  1
