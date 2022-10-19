Debug :: #import "Debug";  // (1)
#import "Basic";

main :: () {
    Debug.init();          // (2)

    a := 0;
    b := 1 / a;         // Causes a crash

    print("Done!");     // will never be reached!
}