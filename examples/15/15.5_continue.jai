#import "Basic";

main :: () {
    for i: 0..5 {  // This for loop prints out 0, 1, 2, 4, 5
        if i == 3 continue;  // (1)
        print("%, ", i);
    }
    print("\n");

    x := 0;
  	while cond := x < 6 {   // (2)
        defer x += 1;
        if x == 3 continue cond;
        print("%, ", x);
  	}

    for i: 0..5 {  
        for j: 0..5 {
            if i == 3 continue i; // (3) continues with the outer loop for 4 and 5
            print("(%, %) - ", i, j);
         }
    }
    print("\n");

    for i: 1..4 {     // (4)
        if i == 2  continue;
        for j: 11..14 {
            print("(%, %) - ", i, j);
            // Stop on unlucky number 13.
            if (i == 3) && (j == 13)  break i;  // Break from the outer loop, so we are done, last printing 13, 3.
        }
    }
}

/*
0, 1, 2, 4, 5,
0, 1, 2, 4, 5,
(0, 0) - (0, 1) - (0, 2) - (0, 3) - (0, 4) - (0, 5) - 
(1, 0) - (1, 1) - (1, 2) - (1, 3) - (1, 4) - (1, 5) - 
(2, 0) - (2, 1) - (2, 2) - (2, 3) - (2, 4) - (2, 5) - 
(4, 0) - (4, 1) - (4, 2) - (4, 3) - (4, 4) - (4, 5) - 
(5, 0) - (5, 1) - (5, 2) - (5, 3) - (5, 4) - (5, 5) -
(1, 11) - (1, 12) - (1, 13) - (1, 14) - 
(3, 11) - (3, 12) - (3, 13) -
*/