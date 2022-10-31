#import "Basic";

main :: () {
    print("One!\n");
    defer print("Two!\n");
    print("Three!\n");
}

/*
One!
Three!
Two!
*/
