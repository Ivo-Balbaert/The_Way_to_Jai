#import "Basic";

my_print_stack_trace :: (node: *Stack_Trace_Node) {     // (1)
    while node {
        if node.info {
        print("[%] at %:%. call depth %\n", 
                        node.info.name, 
                        node.info.location.fully_pathed_filename, 
                        node.line_number, 
                        node.call_depth);
        }
        node = node.next;
    }
}

proc1 :: (x: int) {         // (2)
    print("x is %\n", x);
    if x < 1 { 
        // my_print_stack_trace(context.stack_trace);   // (2B)  
        print_stack_trace(context.stack_trace);         // (2C)  
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
*/