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