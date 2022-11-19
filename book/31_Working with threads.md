# 31 Working with Threads

Threads are a facility provided by the operating system. A different process can run in each thread. Jai exposes this facility: programs can launch multiple threads so that several processes can run in parallel, that is: simultaneously. To use this you need the _Thread_ module.                                Jai provides platform-independent thread routines, as well as a Thread_Group functionality. Each thread has its own Context.

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

You create a new thread by calling the `thread_create` procedure (see line (1)). The new thread has to do something, so `thread_create` is called with a proc as its parameter: this always has to have the signature as in line (5):
`thread_proc :: (thread: *Thread) -> s64`  
A thread had to be shut down when it is no longer useful, we do this with defer and the `thread_destroy` procedure in line (2).  
Then we have to start up the new thread with the `thread_start` procedure in line (3).  
Line (4) uses the proc `sleep_milliseconds()` to suspend the main thread for 1s. This is needed here to see the output of both main and thread1, without it main() closes off before thread1 has had the chance to print its own output.  
Line (5) shows that we can test whether a thread is still running with the `thread_is_done` procedure.  

From the output we see that the `main()` thread and the new thread `thread1` have a different `context`. Their contexts are using the same procedures, but they have a different thread_index and their temporary storage location is different.

## 31.2 Building a program using OpenGL, macros and threads
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

Line (1) and following imports the necessary modules_SDL_ ([Simple DirectMedia Layer](https://www.libsdl.org/)) and _GL_ ([OpenGL - Open Graphics Library](https://en.wikipedia.org/wiki/OpenGL)) and _Thread_.  
In line (2), we see a macro `show_gui`, which first activates OpenGL. Then in the parent (because of the `) scope where it is being called, a `show_gui` thread is created and started. Care is taken to shut down the threat at the end in the parent scope with `defer. At compilation, this macro becomes a proc `show_gui()`, which is the one which is called in line (2) in the main program 31.2_build_threads.jai
(Both versions of show_gui() don't form a problem, they are overloading procs.)
In the `show_gui` proc that is executed in the separate GUI thread, an SDL window is created in line (6), with a grey color (line (7)).  
In an unending loop in (8), we test until success, which is a global variable in parent scope, becomes true. This is the case when the compiler sends the COMPLETE message. In that case, the window title changes, its color becomes green (line (10)), and the loop is stopped. After 2 sec the window is then closed. 
