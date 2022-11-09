#import "Basic";
// Debug :: #import "Debug";

LinkedList :: struct (T: Type) {  // (1)
    first: *Node(T); 
    last:  *Node(T);
}

Node :: struct (T: Type) {          // (2)
    value: T;
    prev: *Node(T);
    next: *Node(T);
}

// Version 1:
// for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {  
//     iter := list.first;     
//     i := 0;
//     while iter {            
//         `it := iter.value;   
//         `it_index := i;      
//         iter = iter.next;
//         #insert body;        
//         if !iter break;    
//         i += 1;             
//     }
// }

// Version 2:
for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {  
    `it := list.first;     
    `it_index := 0;
    while it {            
        #insert body;        
        it = it.next;
        it_index += 1;             
    }
}

// Version 3A:
// for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {
//     `it := ifx flags == For_Flags.REVERSE   list.last   else    list.first;  // (6)
//     `it_index := ifx flags == For_Flags.REVERSE  2  else    0; ;   
//     while it {            
//         #insert body;
//         if flags == For_Flags.REVERSE  { 
//             it = it.prev;
//             it_index -= 1; 
//         } else          {  
//             it = it.next;
//             it_index += 1;   
//         }        
//     }
// }

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

    list: LinkedList(int);
    list.first = *a;
    list.last = *c;

    print("List printed in a for loop: \n");
   
    for list {                     // (4) 
        print("List item % is %\n", it_index, << it);      
    }
    print("\n");
    
    for < list {                   // (5) 
        print("List item % is %\n", it_index, << it);      
    }

    free(*a); free(*b); free(*c); free(*list);
}

/* Version 1:
List printed in a for loop: 
List item 0 is 10
List item 1 is 20
List item 2 is 30
*/

/* Version 2:
List printed in a for loop: 
List item 0 is {10, null, 9c_e92f_f990}
List item 1 is {20, 9c_e92f_f9a8, 9c_e92f_f978}
List item 2 is {30, 9c_e92f_f990, null}
*/

/* Version 3:
List item 2 is {30, d5_6fd4_fcb0, null}
List item 1 is {20, d5_6fd4_fcc8, d5_6fd4_fc98}
List item 0 is {10, null, d5_6fd4_fcb0}
*/