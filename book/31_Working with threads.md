# 31 Working with Threads

Threads are a facility provided by the operating system. A different process can run in each thread. Jai exposes this facility: programs can launch multiple threads so that several processes can run in parallel, that is: simultaneously. To use this you need the _Thread_ module.                                        
Jai provides platform-independent thread routines, as well as Mutexes, Threading primitives, Semaphores and a ThreadGroup functionality.
Thread is a struct, defined   in the module _Thread_.
Each thread has its own Context. Because Temporary_Storage is in the Context, there's a separate storage space per thread, so you don't have to synchronize between threads, and it is fast.

## 31.1 Basics of threads
See *31.1_basic_threads.jai*:
```c++
#import "Basic";
#import "Thread";

thread_proc :: (thread: *Thread) -> s64 {  // (5)
    print("Thread context: %\n", context);
    return 0;
}

main :: () {
    print("Main context: %\n", context);
    thread1 := thread_create(thread_proc);  // (1)
    defer thread_destroy(thread1);          // (2)
    thread_start(thread1);                  // (3)
    sleep_milliseconds(1000);               // (4)
    while !thread_is_done(thread1) { }      // (5)
}

/*
Main context: {{thread_index = 0; allocator = {procedure 0x7ff7_35f4_7c60, null}; 
logger = procedure 0x7ff7_35f4_bcb0; logger_data = null; log_source_identifier = 0; 
log_level = NORMAL; temporary_storage = 7ff7_35f7_f008; dynamic_entries = [{(null), 
...
Thread context: {{thread_index = 1; allocator = {procedure 0x7ff7_35f4_7c60, null}; 
logger = procedure 0x7ff7_35f4_bcb0; logger_data = null; log_source_identifier = 0; 
log_level = NORMAL; temporary_storage = 21e_caf8_9b90; dynamic_entries = [{(null), 
...
*/
```

You create a new thread by calling the `thread_create` procedure (see line (1)), which internally calls `thread_init`, and creates a thread using heap allocation.
`thread_create` has this signature:  
`thread_create :: (proc: Thread_Proc, temporary_storage_size : s32 = 16384, starting_storage: *Temporary_Storage = null) -> *Thread;`

The `thread_init` proc has this signature:  
`thread_init :: (thread: *Thread, proc: Thread_Proc, temporary_storage_size : s32 = 16384, starting_storage: *Temporary_Storage = null) -> bool`
This proc does not start a thread, it just initializes the thread's data.

The new thread has to do something, so `thread_create` is called with a proc as its 1st parameter: this always has to have the signature as in line (5):
`thread_proc :: (thread: *Thread) -> s64`  
A thread had to be shut down when it is no longer useful, we do this with defer and the `thread_destroy` procedure in line (2).  

Then we have to start up the new thread with the `thread_start` procedure in line (3); this proc has the signature: `thread_start :: (thread: *Thread);`.  
Line (4) uses the proc `sleep_milliseconds(1000)` to suspend the main thread for 1s. This is needed here to see the output of both main and thread1, without it main closes off before thread1 has had the chance to print its own output.  
Line (5) shows that we can test whether a thread is still running with the `thread_is_done` procedure.  

From the output we see that the `main` thread and the new thread `thread1` have a different `context`. Their contexts are using the same procedures, but they have a different thread_index and their temporary storage location is different.

## 31.2 Thread Groups
## 31.2.1 Concept and basic example
When you need a bunch of threads to asynchronously respond to requests simultaneously, you can launch a so-called Thread_Group.  
The following proc's are at your disposal:  
* `init :: ()`  initializes a thread group
  Here is its signature:
  `init :: (group: *Thread_Group, num_threads: s32, group_proc: Thread_Group_Proc, enable_work_stealing := false);`

   The thread group can only execute one procedure, namely the one indicated by `group_proc`.  
   The `Thread_Group_Proc` procedure pointer is defined as:   
   `Thread_Group_Proc :: #type (group: *Thread_Group, thread: *Thread, work: *void) -> Thread_Continue_Status;`

   work is passed into the Thread_Group through the add_work :: () function, but the actual work is specified in `Thread_Group_Proc`. 
   The `Thread_Continue_Status` can have the following values: 
    .STOP       causes the thread to terminate 
    .CONTINUE   causes the thread to continue to run

* `start :: ()` starts the running of the threads; it has the signature:  `start :: (group: *Thread_Group);`
  
* `shutdown :: ()` stops the running of the threads; call shutdown before your program exits.

* `add_work :: ()` adds a unit of work, which will be given to one of the threads; here is its signature:  
  `add_work :: (group: *Thread_Group, work: *void, logging_name := "");`

Let's see this in action in the following example:

See _31.3_thread_groups.jai_:
(Example taken from the Jai Community Library wiki)
```c++
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
```

In line (1) the thread group is initialized with 4 threads, the proc `thread_test` is the work the group is going to execute. Here it only prints out the index of the currently active thread. Line (2) turns off the thread logging; set logging to true to turn on debugging.  
The group is started in line (3), and in the loop in line (4) work is added. The thread group is stopped in line (6). Without the pause of the `main` thread in (5), main would exit and stop the program before the thread group could start its work.    
From the added output of two runs, we see that the order in which threads are activated is totally random.  
With logging set to true, the output is much more verbose:
```
'' added     work '' to the available list at time 0.
'' added     work '' to the available list at time 0.000207.
'' added     work '' to the available list at time 0.00033.
'' added     work '' to the available list at time 0.000496.
'' added     work '' to the available list at time 0.000631.
'' added     work '' to the available list at time 0.000728.
'' added     work '' to the available list at time 0.000829.
'' assigned  work ''   to thread 2 at time 0.000733.
'' assigned  work ''   to thread 4 at time 0.000721.
thread_test :: () from thread.index = 4
'' added     work '' to the available list at time 0.000968.
'' added     work '' to the available list at time 0.001455.
'' added     work '' to the available list at time 0.001547.
'' assigned  work ''   to thread 3 at time 0.000848.
thread_test :: () from thread.index = 3
'' assigned  work ''   to thread 1 at time 0.000993.
thread_test :: () from thread.index = 1
'' added     work '' to the available list at time 0.001644.
'' assigned  work ''   to thread 4 at time 0.001338.
thread_test :: () from thread.index = 4
'' stole     work ''  for thread 4 (worker 3) at time 0.002513 from worker 0.       
'' assigned  work ''   to thread 4 at time 0.00266.
thread_test :: () from thread.index = 4
thread_test :: () from thread.index = 2
'' assigned  work ''   to thread 1 at time 0.002228.
thread_test :: () from thread.index = 1
'' stole     work ''  for thread 4 (worker 3) at time 0.002824 from worker 1.       
'' assigned  work ''   to thread 2 at time 0.002904.
thread_test :: () from thread.index = 2
'' stole     work ''  for thread 1 (worker 0) at time 0.003141 from worker 2.       
'' assigned  work ''   to thread 1 at time 0.003531.
thread_test :: () from thread.index = 1
'' assigned  work ''   to thread 4 at time 0.003262.
thread_test :: () from thread.index = 4
'' assigned  work ''   to thread 3 at time 0.001953.
thread_test :: () from thread.index = 3
exit program
```  

## 31.2.2 Getting results from the thread group
The basic example above didn't do any useful work. Let's see a more practical example:

See _31.4_thread_group_response.jai_:
(Example taken from the Jai Community Library wiki)
```c++

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

```

This example follows the same pattern as in the previous one. 
But now `thread_test` does some more work: it calculates a sum, which is returned in line (1), by setting the result field of the Work struct. The work is set up in lines (2) and following (it is defined through 10 Work structs), and send to the thread group in line (2B).  
In line (3), the `get_completed_work` proc gets the results back. 
In the main thread, these results are totalized and printed out. We also see that pausing the main thread by 1 ms is enough to give the thread group the opportunity to do its work. Measuring the time it took with the technique from § 6B.2 gives: `The thread group took 0.015675 seconds`.

## 31.3 Building a program using OpenGL, macros and threads
> Remark: This example was made by Nuno Afonso, and discussed in his YouTube video series 'The Joy of Programming in Jai", part 11: Advanced Compilation.

In this example, we start from 30.6_build_and_run.jai, to which we have only added 4 lines. While compiling, we are showing an SDL window with title "Compiling..." and a grey background. When the compiler emits the COMPLETE message, we change the window title to "Success!" and the background to green. To accomplish this, OpenGL is used to show the windows in a separate (GUI) thread from the main thread, using macros as well. See it in action: `jai 31.2_build_threads.jai`  

See *31.2_build_threads.jai*:
```c++
#import "Basic";
#import "Compiler";
#import "Process";

#load "build_gui.jai";      // (1)

success := false;          

build :: () {
    w := compiler_create_workspace();                     
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    target_options := get_build_options(w);               
    target_options.output_executable_name = "brun";    
    set_build_options(target_options, w);  

    show_gui();             // (2)           

    compiler_begin_intercept(w);     
    add_build_file("main.jai", w);   
    
    while true {                     
        message := compiler_wait_for_message();  

        sleep_milliseconds(100);  // (3)  
        
        if !message break; 
        if message.kind == {
            case .COMPLETE;         
                print(" >> %\n", <<message);
                message_complete := cast(*Message_Complete) message;  
                success = message_complete.error_code == 0;           
                break;
        }
    }
    compiler_end_intercept(w);  

    wait_gui();     // (4)  

    if success {            
        print("[SUCCESS!]\n");
        run_command(target_options.output_executable_name);  
    }    
}

main :: () {}

#run build();
```

In line (1) we load the file `build_gui.jai`, where all the graphical and thread magic happens. In line (2), the SDL window is shown. In line (3) we slow down the compiling process by waiting 10 ms between each compiler message. Line (4) makes the GUI thread wait even more. So don't think, why is the compiler now so slow? This effect is purely artificial, so that we can clearly view our windows.

Here are screenshots of the windows:
![Compiling](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/compiling.png)
![Success](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/success.png)

The loaded file `build_gui.jai` contains the following code:
See *build_gui.jai*:
```c++
#import "Basic";
#import "SDL";      // (1)
#import "GL";
#import "Thread";

show_gui :: () #expand {        // (2)
    gl_load(*gl, SDL_GL_GetProcAddress);
    `gui_thread := thread_create( show_gui );  // (3)
    thread_start( gui_thread );
    `defer thread_destroy( gui_thread );
}

wait_gui :: () #expand {        // (4)
    while !thread_is_done(`gui_thread) { 
        // wait 
    }
}

// #scope_file   // not needed

show_gui :: (thread: *Thread) -> s64 {  // (5)
    window_width :: 300;
    window_height :: 200;
    quit := false;

    // (6):
    window := SDL_CreateWindow("Compiling...", SDL_WINDOWPOS_CENTERED_DISPLAY(1), 
       SDL_WINDOWPOS_UNDEFINED, window_width, window_height, SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE);

    gl_context := SDL_GL_CreateContext(window);
    glViewport(0, 0, window_width, window_height);
    glClearColor(0.5, 0.5, 0.5, 1.0);  // color gray  // (7)
    
    while !quit {       // (8)
        if success {    // (9)
            SDL_SetWindowTitle(window, to_c_string("Success!"));
            glClearColor(0.0, 1.0, 0.0, 0.0); // color green  (10)
            quit = true;
        }

        render();
        SDL_GL_SwapWindow(window);
    }

    sleep_milliseconds(2000);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return  0;
}

render :: () {
    glClear(GL_COLOR_BUFFER_BIT);
}
```

Line (1) and following imports the necessary modules_SDL_, _GL_  and _Thread_.  
In line (2), we see a macro `show_gui`, which first activates OpenGL. Then in the parent (because of the `) scope where it is being called, a `show_gui` thread is created and started. Care is taken to shut down the threat at the end in the parent scope with `defer. At compilation, this macro becomes a proc `show_gui()`, which is the one which is called in line (2) in the main program 31.2_build_threads.jai
(Both versions of show_gui() don't form a problem, they are overloading procs.)
In the `show_gui` proc that is executed in the separate GUI thread, an SDL window is created in line (6), with a grey color (line (7)).  
In an unending loop in (8), we test until success, which is a global variable in parent scope, becomes true. This is the case when the compiler sends the COMPLETE message. In that case, the window title changes, its color becomes green (line (10)), and the loop is stopped. After 2 sec the window is then closed. 
