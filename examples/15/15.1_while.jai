#import "Basic";

main :: () {
    n := 0;
    while n < 10 {          // (1)
        n += 1;
    }
    print("n is: %\n", n);  // => n is: 10
    // one-line:
    while n < 10  n += 1;   // (2) => n is: 10
    print("n is: %\n", n);

    count := 10;
    lift_off := 0;
    print("Counting down\n");
    while count > lift_off {
        print("% - ", count);
        count-=1;
    }
    print("Lift off!\n");

    // while on non-zero values:
    str := "Jai";   // (3)
    while str {
        print(str); // => Jai
        str = "";   // this stops the loop
    }
    n1 := 5;        //  (4)
    while n1 {
        print(" % - ", n1); 
        n1 -=1; // loop stops when n1 reaches 0
    } // => 5 - 4 - 3 - 2 - 1 -

    ptr: *int;      // (5)
    print("%\n", ptr); // => null
    a : int = 42; 
    while !ptr {
        count += 1;
        print("This is a null pointer\n"); // => This is printed out 3 times
        if count == 3 then ptr = *a; // then or {} are necessary here!
    }
    print("ptr now is %\n", ptr);

    // Nested while loop:	
    i, j: int;
    while j < 4 {    // (6)
        defer j += 1;
        i = 0;
        while i < 4 {
            defer i += 1;
            print("(%, %) - ", i, j);
        }
        print("\n");
    }

    // Named while-loop:
    count2 := 10;
    lift_off2 := 0;
    print("Counting down 2\n");
    while counting := count2 > lift_off2 { // (7)
        print("% - ", count2);
        count2-=1;
    }
    print("Lift off!\n");
}

/*
n is: 10
n is: 10
Counting down
10 - 9 - 8 - 7 - 6 - 5 - 4 - 3 - 2 - 1 - Lift off!
Jai 5 -  4 -  3 -  2 -  1 - null
This is a null pointer
This is a null pointer
This is a null pointer
ptr now is 41_b68f_fba0
(0, 0) - (1, 0) - (2, 0) - (3, 0) -
(0, 1) - (1, 1) - (2, 1) - (3, 1) -
(0, 2) - (1, 2) - (2, 2) - (3, 2) -
(0, 3) - (1, 3) - (2, 3) - (3, 3) - 
Counting down 2
10 - 9 - 8 - 7 - 6 - 5 - 4 - 3 - 2 - 1 - Lift off!
*/