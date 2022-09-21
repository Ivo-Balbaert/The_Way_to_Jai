#import "Basic";

main :: () {
    defer print("One!\n");
    defer print("Two!\n");
    defer print("Three!\n");
}

/*
Three!
Two!
One!
*/