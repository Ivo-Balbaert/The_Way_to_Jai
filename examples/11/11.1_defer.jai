#import "Basic";

main :: () {
    print("step %\n", 1);
    print("step %\n", 2);
    defer print("This prints at the very end instead of between 2 and 3!\n");
    print("step %\n", 3);
    print("step %\n", 4);
}

/*
step 1
step 2
step 3
step 4
This prints at the very end instead of between 2 and 3!
*/