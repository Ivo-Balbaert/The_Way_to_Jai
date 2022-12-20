#import "Basic";
#import "Thread";

thread_test :: (group: *Thread_Group, thread: *Thread, work: *void) -> Thread_Continue_Status {
  print("thread_test :: () from thread.index = %\n", thread.index);
  return .CONTINUE;
}

main :: () {
  thread_group: Thread_Group;
  init(*thread_group, 4, thread_test, true);     // (1)
  thread_group.logging = false;                  // (2) 

  start(*thread_group);                          // (3)
  for i: 0..10                                   // (4)
    add_work(*thread_group, null);

  sleep_milliseconds(5000);                      // (5)

  shutdown(*thread_group);                       // (6)
  print("exit program\n");
}

/*
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 3
thread_test :: () from thread.index = 3
thread_test :: () from thread.index = 3
thread_test :: () from thread.index = 3
thread_test :: () from thread.index = 3
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 4
thread_test :: () from thread.index = 1
thread_test :: () from thread.index = 3
exit program

// other run:
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 1
thread_test :: () from thread.index = 1
thread_test :: () from thread.index = 3
thread_test :: () from thread.index = 2
thread_test :: () from thread.index = 4
exit program
*/