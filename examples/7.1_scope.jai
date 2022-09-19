#import "Basic";

// global scope
global_var := 42;
GLOBAL_CONSTANT :: 999;

Values :: enum {
        ONE :: 1;
        TWO :: 2;
        THREE :: 5;
        // factorial(5); // Error: Invalid statement inside an enum. Only declarations, bare identifiers, and #if are supported.
}

main :: () {
    // local procedure scope in main block:
    local_main_var := 7;
    // local scope in anonymous code block:
    { // (1) block scope: these are only known inside this block
        CONSTANT :: 100;
        n := 10;
    // print their values
        print("CONSTANT is %\n", CONSTANT);
        print("n is %\n", n);

        print("local_main_var is %\n", local_main_var);  // => local_main_var is 7
    }
    print("local_main_var is %\n", local_main_var);  // => local_main_var is 7
    // CONSTANT and n are NOT known outside the block in which they are defined
    // Try to print them out here:
    // print("n is %\n", n); // Error: Undeclared identifier 'n'.
}

/*
CONSTANT is 100
n is 10
local_main_var is 7
local_main_var is 7
*/