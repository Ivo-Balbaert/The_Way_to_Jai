#import "Basic";

my_print_stack_trace :: (node: *Stack_Trace_Node) {     // (1)
    while node {
        if node.info {
        print("[%] at %:%. call depth %  hash 0x%\n", 
                        node.info.name, 
                        node.info.location.fully_pathed_filename, 
                        node.line_number, 
                        node.call_depth,
                        formatInt(node.hash, base=16));
        }
        node = node.next;
    }
}

proc1 :: (x: int) {         // (2)
    print("x is %\n", x);
    if x < 1 { 
        my_print_stack_trace(context.stack_trace);   // (2B)  
        // print_stack_trace(context.stack_trace);         // (2C)  
    }  
    else     {  proc1(x - 1); }
}

main :: () {
    proc1(3);               // (3)
}

/*
/* Calling line 2B: */
x is 3
x is 2
x is 1
x is 0
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:21. call depth 4
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:21. call depth 3
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:21. call depth 2
[main] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:25. call depth 1

/* Calling line 2C: */
x is 3
x is 2
x is 1
x is 0
'proc1' at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:22
'proc1' at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:22
'proc1' at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:22
'main' at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:26

/* with my_print_stack_trace: */
x is 3
x is 2
x is 1
x is 0
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:23. call depth 4  hash 0xb15659a3b1256905
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:23. call depth 3  hash 0x7f4c4427a7efb165
[proc1] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:23. call depth 2  hash 0xda2a148d41461045
[main] at d:/Jai/The_Way_to_Jai/examples/25/25.2_stack_trace.jai:27. call depth 1  hash 0xc1d0f3c6d9994ba5
*/