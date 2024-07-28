#import "Basic";

// for module in current folder: compile with -import_dir "." 
//             jai doubly_linked_list.jai -import_dir "."
// for module in folder D:\Jai\The_Way_to_Jai\my_modules     
//             jai doubly_linked_list.jai -import_dir "D:\Jai\The_Way_to_Jai\my_modules"
#import "Linked_List";

// #load "Linked_List.jai";  // jai doubly_linked_list.jai

main :: () {
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

    free(*a); free(*b); free(*c); free(*list);
}

/* 
List printed in a for loop: 
List item 0 is {10, null, f4_e8b2_fd18}
List item 1 is {20, f4_e8b2_fd30, f4_e8b2_fd00}
List item 2 is {30, f4_e8b2_fd18, null}
*/