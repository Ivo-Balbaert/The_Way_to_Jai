#import "Basic";
Debug :: #import "Debug";

main :: () {
    for i: 1..5 {
        for j: 1..5 {
            print("[% %]\n",i, j);
            if i == 3 {
                Debug.attach_to_debugger();
                Debug.breakpoint();
                break j;
            }
        }
    }
}

/*
[1 1]
[1 2]
[1 3]
[1 4]
[1 5]
[2 1]
[2 2]
[2 3]
[2 4]
[2 5]
[3 1]
[4 1]
[4 2]
[4 3]
[4 4]
[4 5]
[5 1]
[5 2]
[5 3]
[5 4]
[5 5]
*/