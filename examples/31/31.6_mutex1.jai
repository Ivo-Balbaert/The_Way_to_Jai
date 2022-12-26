#import "Basic";
#import "Thread";

mutex1: Mutex;

main :: () {
    init(*mutex1, "Critical");
    { // (1)
        lock(*mutex1);             //  (2)
        defer unlock(*mutex1);     //  (3)
        print("Doing critical stuff!\n");  //  (4)
        // => Doing critical stuff!
        print("Mutex1 is %\n", mutex1);
        // Further critical code
    }
}

/*
Mutex1 is {{DebugInfo = ffff_ffff_ffff_ffff; LockCount = 4294967294; RecursionCount = 1; 
OwningThread = 797c; LockSemaphore = null; SpinCount = 33556432; }}
*/
