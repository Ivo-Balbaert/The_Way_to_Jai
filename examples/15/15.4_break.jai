#import "Basic";

main :: () {
    for i: 0..5 {  // This loop prints out 0, 1, 2 then breaks out of the loop
        if i == 3 break; // (1)
        print("%, ", i);
    }
    print("\n");  // => 0, 1, 2,

  // equivalent while-loop:
    i := 0;
    while i <= 5 {  // (2) This loop prints out 0, 1, 2 then breaks out of the loop
        if i == 3 break; // 
        print("%, ", i);
        i += 1;
    }
    print("\n"); // => 0, 1, 2,

    for i: 0..5 {    // (3)
        for j: 0..5 {
            if i == 3 break i; // breaks out of the outer loop for i:
            print("(%, %) - ", i, j);
        }
    }
    print("\n");

    x := 0;
  	while cond := x < 6 {   // (4)
        defer x += 1;
        if x == 3 break cond;
        print("%, ", x);
  	} // => 0, 1, 2,
}

/*
0, 1, 2,
0, 1, 2,
(0, 0) - (0, 1) - (0, 2) - (0, 3) - (0, 4) - (0, 5) - 
(1, 0) - (1, 1) - (1, 2) - (1, 3) - (1, 4) - (1, 5) - 
(2, 0) - (2, 1) - (2, 2) - (2, 3) - (2, 4) - (2, 5) - 
0, 1, 2,
*/