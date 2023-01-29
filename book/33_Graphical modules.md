# 33 Graphical (GUI) modules

In § 31 we used OpenGL (through the modules _SDL_ and _GL_) to draw a simple screen and change its title. Here we discuss other modules from the compiler distribution that are used for graphics displaying. At the present time, Jai has bindings in the distribution for D3D12, Vulcan and OpenGL, and an untested Metal module.                              OpenGL is platform-independent, so we first need a library that can do all the operation-system specific work and give us a window and an OpenGL context to render in. Some of the more popular libraries that do this are GLUT, SDL, SFML and GLFW.

## 33.1 The _GLFW_ module
[GLFW](https://www.glfw.org/) is an open source, multi-platform library for OpenGL, OpenGL ES and Vulkan development on the desktop. It provides a simple API for creating an OpenGL context, creating windows, contexts and surfaces and receiving user input and events.
We start with the basic setup code to open up a window:

See *33.1_glfw_window.jai*:
```c++
#import "GL";
#import "glfw";

main :: () {
  if !glfwInit() then return;           // (1)
  defer glfwTerminate();                // (1B)

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2); // (2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
  window := glfwCreateWindow(640, 480, "GLFW Window", null, null);  // (3)
  if !window then return;
  defer glfwDestroyWindow(window);

  glfwMakeContextCurrent(window);   // (4)
  while !glfwWindowShouldClose(window) {    // (5) render loop
    processInput(window);            // (6)

    glfwSwapBuffers(window);
    glfwPollEvents();
  }
}

processInput :: (window: *GLFWwindow ) {  // (6B)
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, 1);
    }
}
```
 We first initialize GLFW with glfwInit (line (1)), after which we can configure GLFW using glfwWindowHint (line (2)). The first argument of glfwWindowHint tells us what option we want to configure, where we can select the option from a large enum of possible options prefixed with GLFW_. The second argument is an integer that sets the value of our option. A list of all the possible options and its corresponding values can be found at GLFW's window handling documentation.  
 Next we're required to create a window object. This window object holds all the windowing data and is required by most of GLFW's other functions. The glfwCreateWindow (see line (3)) function requires the window width and height as its first two arguments respectively. The third argument allows us to create a name for the window. We can ignore the last 2 parameters. The function returns a GLFWwindow object that we'll later need for other GLFW operations. After that we tell GLFW in line (4) to make the context of our window the main context on the current thread.

We don't want the application to draw a single image and then immediately quit and close the window. We want the application to keep drawing images and handling user input until the program has been explicitly told to stop. For this reason we have to create a while loop, that we now call the render loop, that keeps on running until we tell GLFW to stop. The code starting in line (5) shows a very simple render loop.

It already contains a proc stub `processInput` for handling input. Right now it only processes the ESC key, which closes the window. 

The glfwWindowShouldClose function checks at the start of each loop iteration if GLFW has been instructed to close. If so, the function returns true and the render loop stops running, after which we can close the application.
The glfwPollEvents function checks if any events are triggered (like keyboard input or mouse movement events), updates the window state, and calls the corresponding functions (which we can register via callback methods). The glfwSwapBuffers will swap the color buffer (a large 2D buffer that contains color values for each pixel in GLFW's window) that is used to render to during this render iteration and show it as output to the screen. This is needed because double buffering is used for the display, so that no flickering occurs.

After exiting the render loop,  we want to properly clean/delete all of GLFW's resources that were allocated. We can do this via the glfwTerminate function that we call at the end of the main function via defer (see line (1B)).

When running this program a black window appears (created in line (1)) with a title bar showing the text "GLFW Window".

> Module _glfw_ disappeared from the distribution starting from version 1-027, we took a copy from 1-025 and put it in the examples/33 folder. Now compile the program with:  `jai 33.1_glfw_window.jai -import_dir "."`
> The glfw3.dll and glfw3.lib (or similar files for other OS's) have to be copied in the same folder as the executable of program 33.1

## 33.2 The _SDL_ module
SDL is the [Simple DirectMedia Layer](https://www.libsdl.org/)). It is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware via OpenGL and Direct3D.
We saw a 1st example of its use in § 31.2

The Jai _SDL_ module has SDL2 bindings. It contains the following test example:
See _33.4_sdl_test.jai_:
```c++
#import "Basic";
#import "SDL";
#import "String";

main :: () {

    SDL_Init(SDL_INIT_VIDEO);

    // Create an application window with the following settings:
    window := SDL_CreateWindow("An SDL2 window",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN);

    // Check that the window was successfully created
    if window == null {
        // In the case that the window could not be made...
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return;
    }

    exit := false;
    while !exit {
        event : SDL_Event;
        while SDL_PollEvent(*event) {
            if event.type == {
                case SDL_QUIT;
                    exit = true;
                case SDL_KEYUP;
                    if event.key.keysym.sym == SDLK_ESCAPE  exit = true;
            }
        }

        SDL_Delay(1);
    }

    // Close and destroy the window
    SDL_DestroyWindow(window);

    // Clean up
    SDL_Quit();
}
```

This opens a window with the title text "An SDL2 window" using only SDL:`\modules\SDL\examples\sdl_test.jai`.
(Copy SDL2.dll and SDL2.lib from the SDL/win folder next to the exe)

## 33.3 The _GL_ module
GL is the [OpenGL - Open Graphics Library](https://en.wikipedia.org/wiki/OpenGL). It is a cross-language, cross-platform application programming interface (API) for rendering 2D and 3D vector graphics. The API is typically used to interact with a graphics processing unit (GPU), to achieve hardware-accelerated rendering.

The Jai distribution contains a simple example of opening a window with the title txt "An SDL2 window" using GL and SDL (see § 33.5):`\modules\GL\examples\gl_sdl.jai`.
(Copy SDL2.dll and SDL2.lib from the SDL/win folder next to the exe)

See *33.5_gl_sdl.jai*:
```c++
#import "Basic";
#import "GL";
#import "SDL";
#import "String";

main :: () {

    SDL_Init(SDL_INIT_VIDEO);

    w := 640;
    h := 480;
    window := SDL_CreateWindow("An SDL2 window", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, xx w, xx h, SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE);

    // Check that the window was successfully created
    if window == null {
        // In the case that the window could not be made...
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return;
    }

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);

    gl_context := SDL_GL_CreateContext(window);
    if !gl_context {
        print( "Could not create OpenGL context: %\n", to_string(SDL_GetError()));
        return;
    }  

    gl_load(*gl, SDL_GL_GetProcAddress);
    using gl;

    print ("GL Vendor = %\n", to_string(glGetString(GL_VENDOR)));
    print ("GL Version = %\n", to_string(glGetString(GL_VERSION)));


    exit := false;
    while !exit {
        event : SDL_Event;
        while SDL_PollEvent(*event) {
            if event.type == {
                case SDL_QUIT;
                    exit = true;
                case SDL_KEYUP;
                    if event.key.keysym.sym == SDLK_ESCAPE exit = true;
                case SDL_WINDOWEVENT;
                    if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
                        w = event.window.data1;
                        h = event.window.data2;
                    }
            }
        }

        glViewport(0, 0, xx w, xx h);
        glClear(GL_COLOR_BUFFER_BIT);

        SDL_GL_SwapWindow(window);
    }

    SDL_DestroyWindow(window);
    SDL_Quit();
}
```

When the window is closed,it prints out the GL Vendor and Version to the terminal (probably different on your machine):
```
GL Vendor = NVIDIA Corporation
GL Version = 4.6.0 NVIDIA 456.71
```
## 33.4 Direct3D
Direct3D is a graphics application programming interface (API) for Microsoft Windows. Part of DirectX, Direct3D is used to render three-dimensional graphics in applications where performance is important, such as games. Direct3D uses hardware acceleration if it is available on the graphics card, allowing for hardware acceleration of the entire 3D rendering pipeline or even only partial acceleration.
The modules *d3d_compiler* , _d3d11_ and _d3d12_ contain interfacing code for Direct3D.
d3d12 contains a minimal example `example.jai`, as well as jai\examples\d3d11_example.


## 33.5 The _Simp_ module
Simp is a simple 2D API framework for drawing graphics with OpenGL as backend, completely written in Jai.

Here is Simp's minimum code to open and close a window:

See *33.2_simp_window.jai*:
```c++
#import "Basic";
#import "Input";
Simp :: #import "Simp";
#import "System";
#import "Window_Creation";


main :: () {
  window_width  : s32 = 1920;
  window_height : s32 = 1080;
  render_width  : s32 = 1920;
  render_height : s32 = 1080;

  win := create_window(window_width, window_height, "Xiangqi");   // (1)
  Simp.set_render_target(win);
  quit := false;
  while !quit {                 // (2)
    update_window_events();
    for get_window_resizes() {
        if it.window == win {
            window_width  = it.width;
            window_height = it.height;
            render_width  = window_width;
            render_height = window_height;
            Simp.update_window(win);
        }
    }

    Simp.clear_render_target(0.15555, 0.15555, 0.15555, 1.0);
    for events_this_frame {
        if it.type == .QUIT then 
          quit = true;
    }

    sleep_milliseconds(10);
    Simp.swap_buffers(win);
    reset_temporary_storage();      // (3)
  }
}
```

In line (1) the window is created. Line (2) starts the event-loop: the program is waiting for events to occur on the window and to act upon them. Line (3) clears temporary storage, so in the loop you'll want to store all your data in temp.
To make SIMP draw objects with opacity, use: `Simp.set_shader_for_color(true);`

The module also contains some examples (_modules/Simp/examples_):
- _example.jai_: this shows a window with a texture background and a colored rotating square in the centre;
- _multiple_windows.jai_: this shows 2 windows next to each other, the 1st is the window from the previous example, the 2nd window has a text with a color-changing background;  

## 33.6 The _Getrect_ module
This is a simple UI module which works together with Simp.
The following program draws two buttons when the render1 macro call is uncommented: Button 0 and Button 1. When clicked their button text is printed.
When render2 is called, a dropdown list is shown.

See _33.3_getrect_buttons.jai_:
```c++
#import "Basic";
#import "GetRect";
Input :: #import "Input";
#import "Simp";
#import "Window_Creation";

main :: () {
  win := create_window(800, 600, "Window");
  window_width, window_height := get_render_dimensions(win);
  set_render_target(win);
  ui_init();
  while eventloop := true {
    Input.update_window_events();
    for Input.get_window_resizes() {
      update_window(it.window);
      if it.window == win {
        window_width  = it.width;
        window_height = it.height;
      }
    }

    mouse_pressed := false;
    for event: Input.events_this_frame {
      if event.type == .QUIT then {
        break eventloop;
      }
      getrect_handle_event(event);
    }

    current_time := get_time();
    render1(win, current_time);
    // render2(win, current_time);
    sleep_milliseconds(10);
    reset_temporary_storage();
  }
}

render1 :: (win: Window_Type, current_time: float64) #expand {
  // background.
  clear_render_target(.35, .35, .35, 1);
  defer swap_buffers(win);

  // update ui
  width, height := get_render_dimensions(win);
  ui_per_frame_update(win, width, height, current_time);

  // create a button in the top left hand corner.
  k := height * 0.10;
  r := get_rect(5.0, (xx height) - 5.0 - k, 8.5*k, k);
  if button(r, "Button 0") {    // (1)
    print("Button 0\n");
  }

  r.y -= k + 5.0;

  if button(r, "Button 1") {
    print("Button 1\n");

  }
}

// render 2:
render2 :: (win: Window_Type, current_time: float64) #expand {
  // background.
  clear_render_target(.35, .35, .35, 1);
  defer swap_buffers(win);

  // update ui
  width, height := get_render_dimensions(win);
  ui_per_frame_update(win, width, height, current_time);

  // create a button in the top left hand corner.
  k := height * 0.10;
  r := get_rect(5.0, (xx height) - 5.0 - k, 8.5*k, k);

  ARRAY :: string.["Item 0", "Item 1", "Item 2"];

  dropdown(r, ARRAY, *val); // val is global

  defer draw_popups();
}
```

When `if button(r, "Button 0")` is true the button has been clicked (line (1)). So the body of the if is effectively the click event handler.

The module also contains an example (_modules/Simp/examples_):
- _example.jai_: this shows a window with all available GUI widgets, besides the above. It also displays a text field, a slider, checkboxes, and so on.


## 33.7 The *Window_Creation* module
This module contains platform-independent window creation routines.
Showing a window is as easy as this code-snippet:

See *33.6_window_creation.jai:
```c++
#import "Input";
#import "Windows";
#import "Window_Creation";

main :: () {
    handle_window := create_window(window_name="Example", width=200, height=200);

    while true {
        update_window_events();
    }
}
```

Adding handling a QUIT event:

See *33.6_window_creation.jai*:
```c++
#import "Input";
#import "Windows";
#import "Window_Creation";

WINDOW_WIDTH  :: 1280;
WINDOW_HEIGHT :: 720;
the_window: Window_Type;

main :: () {
    the_window = create_window(WINDOW_WIDTH, WINDOW_HEIGHT, "Window Creation");

    quit := false;
    while !quit {
        update_window_events();

        for events_this_frame {
            if it.type == .QUIT then quit = true;

            if it.type == .KEYBOARD {
                if it.key_pressed == 0       continue;
                if it.key_code == .ESCAPE    quit = true;
            }
        }
    }
}
```


Other modules in a Jai distribution:
- ImGui
- Metal
- nvt
- stb_image and stb_
- Vulkan (successor of OpenGL)
