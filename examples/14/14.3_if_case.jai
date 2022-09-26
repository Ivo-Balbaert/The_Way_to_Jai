#import "Basic";

main :: () {
    a3 := 0;
    if a3 == {                       // (1)
        case 0;
            print("case 0\n");       // => case 0
        case 1; 
            print("case 1\n");       // because a is 0, this will be ignored
            print("This is also in case 1!"); 
        case;
            print("default case\n"); // because a is 0, this will be ignored.
    }

    a4 := 0;
    if a4 == {                      // (2)
        case 0;
            print("case 0\n"); // => case 0
        #through;
        case 1;
    // because of the #through statement, this if-case statement will print out "case 1" 
    // in addition to "case 0". 
            print("case 1\n"); // => case 1
        case;
            print("default case\n"); // because there is no #through statement, this will be ignored
    }

    // if-case with enums, #complete:
    Val :: enum { A; B; C; }        // (3)
    a5 := Val.A;
    if #complete a5 == {
        case Val.A;
            print("This is Val.A case\n"); // => This is Val.A case
        case Val.B;
            print("This is Val.B case\n");
        case Val.C;
            print("This is Val.C case\n");
    }
}

/*
case 0
case 0
case 1
This is Val.A case
*/