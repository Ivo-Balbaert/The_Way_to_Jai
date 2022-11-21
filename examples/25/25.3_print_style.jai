#import "Basic";

main :: () {
    NUMBERS :: u32.[1, 69105, 1491625];
    
    new_context := context;
    push_context new_context {  
        format_int := *context.print_style.default_format_int;  // (1)
        // default is:  format_int.base = 10;
        for NUMBERS print("% / ", it); // => 1 / 69105 / 1491625 / 
        print("\n");
        format_int.base = 16;          // (2)
        for NUMBERS print("% / ", it); // => 1 / 10df1 / 16c2a9 /
        print("\n");
        format_int.base = 2;
        for NUMBERS print("% /", it); // => 1 /10000110111110001 /101101100001010101001 /
    }
    print("\n");
    for NUMBERS print("% /", it); // (3) => 1 / 69105 / 1491625 / 
}

/*


*/