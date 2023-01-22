LinkedList :: struct (T: Type) {  // (1)
    first: *Node(T); 
    last:  *Node(T);
}

Node :: struct (T: Type) {          // (2)
    value: T;
    prev: *Node(T);
    next: *Node(T);
}

for_expansion :: (list: LinkedList, body: Code, flags: For_Flags) #expand {  
    `it := list.first;     
    `it_index := 0;
    while it {            
        #insert body;        
        it = it.next;
        it_index += 1;             
    }
}