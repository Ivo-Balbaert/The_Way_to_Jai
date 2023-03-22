#import "Basic";

Good_Fruit :: enum {
    APPLE      :: 1;
    BANANA     :: 2;
    BANANANA   :: 3;
    KIWI       :: 4;
    GRAPE      :: 5;
    STRAWBERRY :: 6;
}

main :: () {
    numbers := int.[1, 3, 5, 7, 9]; // (1) array literal
    // numbers2 := .[1, 3, 5, 7, 9]; // (1B) => Error: This declaration is bound to a struct 
    // or array literal that did not specify its type, 
    // so there is no way to know its type.
    print("count is %, and data is %.\n", numbers.count, numbers.data); // (2)
    // => count is 5, and data is f8_01ba_f828.
    print("%\n", type_of(numbers)); // (3) => [5] s64
    print("%\n", type_of([4]int) == type_of([5]int)); // (4) => true because both are Type
    numbers[2] = 42;
    print("%", numbers); // => [1, 3, 42, 7, 9]

    // Error when defined as follows:
    // numbers2: []int = .[1, 3, 5, 7, 9];
    // numbers2[2] = 42;
    /*
    The program crashed because of an access violation writing location 0x7ff69f8aa118.
    This address is in the read only section .rdata of the program.
    A common mistake is to write to a constant string or array, 
    which is put by the compiler in a read only section of the program.
    */



    // empty array literal:
    emp := string.[]; // (5)
    print("% - %\n", emp.count, emp.data); // => 0 - null
    // arr1 : [4]float = float.[10.0, 20.0, 1.4, 10.0]; // (6)
    // shorter:
    arr1: = float.[10.0, 20.0, 1.4, 10.0];
    print("arr1 is % \n", arr1); // (7) => arr1 is [10, 20, 1.4, 10]
    print("The 3rd item is %\n", arr1[3]); // (8) => The 3rd item is 10
    arr1[3] = 2.71;              // (9)
    print("arr1 is % \n", arr1); // => arr1 is [10, 20, 1.4, 2.71]
    words := string.["The", "number", "is", "odd."];
    print("words is %\n", words); // => words is ["The", "number", "is", "odd."]

    what_i_want :: Good_Fruit.[.APPLE, .GRAPE, .KIWI, .BANANANA, .APPLE]; // (10)

    for numbers print("numbers[%] = %\n", it_index, it); // (11)
    /* =>
    numbers[0] = 1
    numbers[1] = 3
    numbers[2] = 5
    numbers[3] = 7
    numbers[4] = 9
    */
    for words   print(" %. %\n", it_index, it);
    /*
    0. The
    1. number
    2. is
    3. odd.
    */
}