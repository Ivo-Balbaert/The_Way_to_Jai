#import "Basic";
#import "Thread";   // (1)
// #import "Thread"()(DEBUG=true);   // (1)

mutex_A: Mutex;
mutex_B: Mutex;
mutex_C: Mutex;

main :: () {
    init(*mutex_A, "A", 1);      // (2)
    init(*mutex_B, "B", 2);
    init(*mutex_C, "C", 3);

    // correct locking order:
    {
        lock(*mutex_C);
        defer unlock(*mutex_C);
        print("Doing C stuff!\n");
        {
            lock(*mutex_B);
            defer unlock(*mutex_B);
            print("Doing B stuff!\n");
            {
                lock(*mutex_A);
                defer unlock(*mutex_A);
                print("Doing A stuff!\n");
            }
        }
    }
    
    // error in locking order:
    // { // (4)31.7_mutex_order.jai
    //     lock(*mutex_B);
    //     defer unlock(*mutex_B);
    //     print("Doing B stuff!\n");
    //     {
    //         lock(*mutex_C);
    //         defer unlock(*mutex_C);
    //         print("Doing C stuff!\n");
    //     }
    // }
}

/*
Doing C stuff!
Doing B stuff!
Doing A stuff!

/* If section // (4) is uncommented: */
Doing B stuff!
Attempt to lock mutexes out of order.
While we had already locked 'B' at order 2 (d:/Jai/The_Way_to_Jai/examples/31/31.7_mutex_order.jai:32)...
We tried to lock 'C' at order 3 (d:/Jai/The_Way_to_Jai/examples/31/31.7_mutex_order.jai:36).
Lock order must strictly decrease, so this is invalid.
c:/jai/modules/Thread/primitives.jai:552,21: Assertion failed!

Stack trace:
c:/jai/modules/Preload.jai:341: default_assertion_failed
c:/jai/modules/Basic/module.jai:75: assert
c:/jai/modules/Thread/primitives.jai:552: lock
d:/Jai/The_Way_to_Jai/examples/31/31.7_mutex_order.jai:36: main



*/