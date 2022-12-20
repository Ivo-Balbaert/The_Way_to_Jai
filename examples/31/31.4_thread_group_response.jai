
#import "Basic";
#import "Thread";

Work :: struct {
  count: int;
  result: int;
}

thread_test :: (group: *Thread_Group, thread: *Thread, work: *void) -> Thread_Continue_Status {
  w := cast(*Work) work;
  print("thread_test :: () from thread.index = %, work.count = %\n", thread.index, w.count);

  sum := 0;
  for i: 0..w.count {
    sum += i;
  }

  w.result = sum;               // (1)
  return .CONTINUE;
}


main :: () {
  secs := get_time();
  thread_group: Thread_Group;
  init(*thread_group, 4, thread_test, true);
  thread_group.logging = false;

  start(*thread_group);
  arr: [10] Work;                      // (2)
  for i: 0..9 {
    arr[i].count = 10000;       
    add_work(*thread_group, *arr[i]);  // (2B)
  }

  sleep_milliseconds(1);               // (2C) 

  work_list := get_completed_work(*thread_group);  // (3)
  total := 0;                          // (4)
  for work: work_list {
    val := cast(*Work) work;
    print("%\n", val.result);
    total += val.result;
  }
  print("Total = %\n", total);
  secs = get_time() - secs;   // (1)
  print("The thread group took % seconds\n", secs);
  shutdown(*thread_group);
  print("exit program\n");
}

/*
thread_test :: () from thread.index = 1, work.count = 10000
thread_test :: () from thread.index = 3, work.count = 10000
thread_test :: () from thread.index = 1, work.count = 10000
thread_test :: () from thread.index = 4, work.count = 10000
thread_test :: () from thread.index = 4, work.count = 10000
thread_test :: () from thread.index = 2, work.count = 10000
thread_test :: () from thread.index = 1, work.count = 10000
thread_test :: () from thread.index = 3, work.count = 10000
thread_test :: () from thread.index = 4, work.count = 10000
thread_test :: () from thread.index = 2, work.count = 10000
50005000
50005000
50005000
50005000
50005000
50005000
50005000
50005000
50005000
50005000
Total = 500050000
The thread group took 0.015675 seconds
exit program
*/
