# 33 Graphical (GUI) modules

In § 31 we used OpenGL (through the modules _SDL_ and _GL_) to draw a simple screen and change its title. Here we discuss other modules from the compiler distribution that are used for graphics displaying. 

OpenGL is platform-independent, so we first need a library that can do all the operation-system specific work and give us a window and an OpenGL context to render in. Some of the more popular libraries that do this are GLUT, SDL, SFML and GLFW.

At the present time, Jai has bindings in the distribution for ImGui, nvt, stb_image and other stb_ libraries, D3D12, OpenGL and Vulcan (successor of OpenGL), and an untested Metal module.   

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
SDL is the [Simple DirectMedia Layer](https://www.libsdl.org/). It is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware via OpenGL and Direct3D.
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
    window := SDL_CreateWindow("An GL_SDL window", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,  
    xx w, xx h, SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE);

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
Simp is a simple 2D API framework for drawing graphics with OpenGL as backend, completely written in Jai. It is high-level and easy-to-use, and is built on a modern API.  
In this section, a number of simple examples are shown. They come from the many graphical Jai experiments by [Tsoding](https://github.com/tsoding).

### 33.5.1 A simple window
Here is Simp's minimum code to open and close a window:

See *33.2A_simp_window.jai*:
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

  win := create_window(window_width, window_height, "Simp_Window");   // (1)
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
    Simp.swap_buffers(win);         // (2B)
    reset_temporary_storage();      // (3)
  }
}
```

In line (1) the window is created. Line (2) starts the event-loop: the program is waiting for events to occur on the window and to act upon them. Each iteration in this loop draws a **frame** in line (2B). Line (3) clears temporary storage, so in the loop you'll want to store all your data in temp.
To make Simp draw objects with opacity, use: `Simp.set_shader_for_color(true);`

### 33.5.2 A colored triangle
Let's see how to draw a triangle with some nice color effect.

See *33.11_colored_triangle.jai*:
```c++
#import "Basic";
#import "Input";
#import "Math";
Simp :: #import "Simp";
#import "Window_Creation";

RED   :: Vector4.{1, 0, 0, 1};   // (1)
GREEN :: Vector4.{0, 1, 0, 1};
BLUE  :: Vector4.{0, 0, 1, 1};

main :: () {
    window_width  := 800;   
    window_height := 600;

    p0 := make_vector3(0, 0, 0);
    p1 := make_vector3(xx window_width, 0, 0);
    p2 := make_vector3(cast(float) window_width/2, xx window_height, 0);
    
    win := create_window(window_width, window_height, "Triangle");   
    Simp.set_render_target(win);
    Simp.set_shader_for_color(true);                           // (2)

    quit := false;
    while !quit {                          
        Simp.clear_render_target(0.2, 0.3, 0.3, 1);
        update_window_events();

        for events_this_frame {
            if it.type == .QUIT    quit = true;
        }

        Simp.immediate_triangle(p0, p1, p2, RED, GREEN, BLUE);  // (1)

        Simp.swap_buffers(win);
        sleep_milliseconds(10);
        reset_temporary_storage();   
    }
}
```

Simp's coordinate system looks like this:  

     y  ^
        |
        |
        |----------->  x

(z runs perpendicular to this plane, we don't use this coordinate here and set it arbitrarily to 1)
Line (1) draws our triangle. This needs three Vector3 instances, which are the coordinates of the vertices (points indicated by o) of the triangle:

       (window_width/2, window_height)
                  o

           o              o
        (0, 0)       (window_width, 0)

It also needs three color Vector4 instances, which are of the form:  
        `(red, green, blue, opacity)`    
red equal to 0 means no red, equal to 1 means fully red, and so on.

Line (2) is needed for drawing the colors, and creating the nice shading effect, seen in ![Colored triangle with Simp](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/colored_triangle.png).  


### 33.5.3 Drawing a circle using triangles
A circle can be approximately made by drawing a number of triangles with top vertex in the center of the circle, and the other vertices on the circumference of the circle. The more triangles, the more accurate the circle looks like.
Here is how it is coded:

See *33.12_drawing_circle.jai*:
```c++
#import "Basic";
#import "Input";
#import "Math";
Simp :: #import "Simp";
#import "Window_Creation";

RED   :: Vector4.{1, 0, 0, 1};   
CIRCLE_RESOLUTION :: 30;         // number of triangles used to draw circle

immediate_circle :: (center: Vector2, radius: float, color: Vector4) {  // (1)
    STEP_ANGLE :: 2*PI/CIRCLE_RESOLUTION;  // (2)
    for 0..CIRCLE_RESOLUTION-1 {           // (3) 
        p0 := center;
        p1 := center + make_vector2(cos(STEP_ANGLE*it), sin(STEP_ANGLE*it))*radius;
        p2 := center + make_vector2(cos(STEP_ANGLE*(it + 1)), sin(STEP_ANGLE*(it + 1)))*radius;
        Simp.immediate_triangle(
            make_vector3(p0, 0), make_vector3(p1, 0), make_vector3(p2, 0),
            color, color, color);
    }
}

main :: () {
    window_width  := 800;   
    window_height := 600;

    win := create_window(window_width, window_height, "Circle");   
    Simp.set_render_target(win);
    Simp.set_shader_for_color(true);   // (2)

    quit := false;
    while !quit {                          
        Simp.clear_render_target(0.2, 0.3, 0.3, 1);
        update_window_events();

        for events_this_frame {
            if it.type == .QUIT    quit = true;
        }

       immediate_circle(make_vector2(cast(float) window_width/2, cast(float) window_height/2), 100, RED);  

        x, y, success := get_mouse_pointer_position();   // (3)
        immediate_circle(make_vector2(xx x, xx (window_height - y)), 15, RED);

        Simp.swap_buffers(win);
        sleep_milliseconds(10);
        reset_temporary_storage();   
    }
}
```

Analogously to `immediate_triangle` and `immediate_quad` from Simp, we define our own `immediate_circle` procedure (see line (1)). In it, we calculate the angle from the number of circles used (the resolution). Then in a for-loop (line (2)), we calculate the three vertices from the triangle as Vector2's, and then draw the triangle. Experiment with the resolution from 5 to 100 to see the effect.  
By adding just two lines starting at (3), we can draw a circle at the mouse cursor which follows every move of the mouse. This is done by using the `get_mouse_pointer_position` proc from module *Window_Creation*.

**Exercise:**
See the color effect you get when using three colors to draw the circle, as in § 33.5.2

### 33.5.4 A bouncing square
By only adding some 10 lines of code to the previous example, we can draw a moving red square, that bounces of the sides of the window: 

See *33.2B_bouncing_square.jai*:
```c++
#import "Basic";
#import "Input";
#import "Math";
Simp :: #import "Simp";
#import "System";
#import "Window_Creation";

main :: () {
    window_width  := 800;
    window_height := 600;
    render_width  := 800;
    render_height := 600;

    win := create_window(window_width, window_height, "Bouncing Square");    
    Simp.set_render_target(win);
    Simp.set_shader_for_color(true);

    x := 0.0;                               // (1)
    y := 0.0;
    dx := 1.0;
    dy := 1.0;
    quad_size := 50.0;
    velocity :: 5.0;

    quit := false;
    while !quit {                         
        Simp.clear_render_target(0.2, 0.3, 0.3, 1);
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

        for event : events_this_frame {
            if event.type == {
                case .QUIT; { quit = true; break; }

                case .KEYBOARD; if event.key_pressed {
                    if event.key_code == {
                        case .ESCAPE;    quit = true; break;
                    }
                }
            }
        }

        // (2)
        if x + dx < 0.0 || x + dx + quad_size > cast(float) window_width     dx = -dx;
        if y + dy < 0.0 || y + dy + quad_size > cast(float) window_height    dy = -dy;

        x += dx * velocity;         // (3)
        y += dy * velocity;       

        // (4)
        Simp.immediate_quad(x, y, x + quad_size, y + quad_size, make_vector4(1.0, 0.5, 0.5, 1.0));
        // last argument is the color: Vector4, here pink

        sleep_milliseconds(10);
        Simp.swap_buffers(win);
        reset_temporary_storage();    
    }
}
```
In line (1) we define starting coordinates x and y for the left bottom point of the square. dx and dy are the increments, with which x and y are incremented each frame. To control its speed, we define a velocity parameter, to multiply dx and dy before adding them, see line (3).  
The square is drawn with `immediate_quad` from Simp, see line (4).

> Note:
> A quad in graphics programming is a four-sided polygon that can be used to represent a surface or a texture. Quads are often preferred over triangles because they can be subdivided into smaller quads for more detail. Quads can also be organized into quadtrees, which are data structures that divide a two-dimensional space into four regions recursively. Quadtrees can help with collision detection, image compression and rendering efficiency.

To make the square bounce off the window boundary, we reverse the sign of dx and dy when the boundary is exceeded (line (2)).


The module Simp also contains some examples (_modules/Simp/examples_):
- _example.jai_: this shows a window with a texture background and a colored rotating square in the centre;
- _multiple_windows.jai_: this shows 2 windows next to each other, the 1st is the window from the previous example, the 2nd window has a text with a color-changing background;  

### 33.5.5 A Chess Board
Here is the code to draw a board:  

See *33.13_drawing_board.jai*:
```c++
#import "Basic";
#import "Input";
#import "Math";
Simp :: #import "Simp";
#import "Window_Creation";

window_width  :: 800;
window_height :: 600;

background_color :: Vector4.{x=1, y=.0, z=.0, w=1};
grid_color       :: Vector4.{x=.2, y=.2, z=.2, w=1};

grid_cols        :: 8;
grid_rows        :: 8;
grid_cell_width  :: grid_width / grid_cols;
grid_cell_height :: grid_height / grid_rows;
grid_percent     :: 0.5;

grid_width    :: window_width;
grid_height   :: window_width;
grid_x        : float : 0.0;
grid_y        : float : window_height*grid_percent - grid_height*grid_percent;

immediate_cell_quad :: (col: s64, row: s64, color: Vector4) {
    x : float = grid_x + xx (col*grid_cell_width);
    y : float = grid_y + xx (row*grid_cell_height);
    w : float = grid_cell_width;
    h : float = grid_cell_height;
    Simp.immediate_quad(x, y, x + w, y + h, color);
}
main :: () {
    win := create_window(window_width, window_height, "Chess Board");    
    Simp.set_render_target(win);
    Simp.set_shader_for_color(true);

    quit := false;
    while !quit {                         
        Simp.clear_render_target(0.2, 0.3, 0.3, 1);
        update_window_events();

        for event : events_this_frame {
            if event.type == {
                case .QUIT; { quit = true; break; }

                case .KEYBOARD; if event.key_pressed {
                    if event.key_code == {
                        case .ESCAPE;    quit = true; break;
                    }
                }
            }
        }

        for col: 0..grid_cols-1 {           // (1)
            for row: 0..grid_rows-1 {
                color := ifx (col + row)%2 == 0 then background_color else grid_color; // (2)
                immediate_cell_quad(col, row, color);
            }
        }

        sleep_milliseconds(10);
        Simp.swap_buffers(win);
        reset_temporary_storage();    
    }
}
```

The actual drawing takes place in the for-loop starting in (1). Here we:  
- iterate over all columns and rows  
- choose the color, depending on if it is a cell or if it is background (line (2))
- draw the cell

### 33.5.6 A moving shape
Starting from the code in the previous §, we change the colors so that the board appears more like a background.  
To draw a shape, we change a few adjacent cells to another color (shape_color), and call `immediate_cell_quad` four times (see line (1)).
```c++
immediate_cell_quad(0, 1, shape_color);
immediate_cell_quad(1, 1, shape_color);
immediate_cell_quad(2, 1, shape_color);
immediate_cell_quad(2, 2, shape_color);
```
To show the falling movement, the y coordinate is set to a variable row, which starts at the top (grid_rows - 2), and diminishes when time goes by (implemented in snippets (2A-B)).  
Implementing left-right movement is done in the event-handler (see lines (3) where we check for arrow-left and arrow-right keys):   
```c++
case .ARROW_LEFT;  col -= 1;      // (3)
case .ARROW_RIGHT; col += 1;
```  
so we now have to replace the x coordinate by col.


See *33.14_moving_shape.jai*:
```c++
#import "Basic";
#import "Input";
#import "Math";
Simp :: #import "Simp";
#import "Window_Creation";

window_width  :: 800;
window_height :: 600;

shape_color      :: Vector4.{x=.2, y=.8, z=.2, w=1};
background_color :: Vector4.{x=.1, y=.1, z=.1, w=1};
grid_color       :: Vector4.{x=.2, y=.2, z=.2, w=1};

grid_cols        :: 8;
grid_rows        :: 8;
grid_cell_width  :: grid_width / grid_cols;
grid_cell_height :: grid_height / grid_rows;
grid_percent     :: 0.5;

grid_width    :: window_width;
grid_height   :: window_width;
grid_x        : float : 0.0;
grid_y        : float : window_height*grid_percent - grid_height*grid_percent;

step_interval    :: 1.5;
DT_MAX : float : 0.15;

immediate_cell_quad :: (col: s64, row: s64, color: Vector4) {
    x : float = grid_x + xx (col*grid_cell_width);
    y : float = grid_y + xx (row*grid_cell_height);
    w : float = grid_cell_width;
    h : float = grid_cell_height;
    Simp.immediate_quad(x, y, x + w, y + h, color);
}

main :: () {
    last_time := get_time();
    step_timeout := step_interval;

    win := create_window(window_width, window_height, "Moving Shape");    
    Simp.set_render_target(win);
    Simp.set_shader_for_color(true);

    col := 0;
    row := grid_rows - 2;
    quit := false;

    while !quit {      
        now := get_time();  // (2A)
        delta: float64 = now - last_time;
        current_dt := cast(float) delta;
        if current_dt > DT_MAX  current_dt = DT_MAX;
        last_time = now;

        step_timeout -= current_dt;  // (2B)
        if step_timeout < 0 {
            step_timeout = step_interval;
            row -= 1;                // <-- here the shape falls
        }

        Simp.clear_render_target(0.2, 0.3, 0.3, 1);
        update_window_events();

        for event : events_this_frame {
            if event.type == {
                case .QUIT; { quit = true; break; }

                case .KEYBOARD; if event.key_pressed {
                    if event.key_code == {
                        case .ESCAPE;    quit = true; break;
                        case .ARROW_LEFT;  col -= 1;      // (3)
                        case .ARROW_RIGHT; col += 1;
                    }
                }
            }
        }

        step_timeout -= current_dt;  // (2B)
        if step_timeout < 0 {
            step_timeout = step_interval;
            row -= 1;
        }

        // background grid:
        for col: 0..grid_cols-1 {          
            for row: 0..grid_rows-1 {
                color := ifx (col + row)%2 == 0 then background_color else grid_color; 
                immediate_cell_quad(col, row, color);
            }
        }

        // (1) drawing an  L shape
        immediate_cell_quad(col, row, shape_color);
        immediate_cell_quad(col + 1, row, shape_color);
        immediate_cell_quad(col + 2, row, shape_color);
        immediate_cell_quad(col + 2, row + 1, shape_color);

        sleep_milliseconds(10);
        Simp.swap_buffers(win);
        reset_temporary_storage();    
    }
}
```

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
  win := create_window(800, 600, "Buttons");
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

See *33.6_window_creation_events.jai*:
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

## 33.8 The *Input* module
This module from the standard distribution provides platform-independent input handler routines, for keyboard and mouse input.  
The distribution contains an example (*Input/examples/input_test.jai*) showing which keys are pressed or held, and the mouse position.

## 33.9 How to load a font with Simp
A font is defined in a file with an extension `.ttf`.
The functionalities for working with fonts are contained in the file `font.jai` from module *Simp*.


See *33.8_load_font.jai*:
```c++
#import "Basic";
#import "Simp";

window_height: s32 = 720;
my_font: *Dynamic_Font;    // (1)

main :: () {
    pixel_height := window_height / 24;
    my_font = get_font_at_size("assets/fonts/", "Anonymous Pro.ttf", pixel_height); // (2)
    assert(my_font != null);
}
```

`my_font` is a pointer to a `Dynamic_Font` struct, which is defined in `font.jai`.
The font "Anonymous Pro" is loaded through the procedure `get_font_at_size` into `my_font` from the .ttf file in subfolder *assets/fonts/*.

Once you have a font, you use it to initialize and draw some `text` (which is a string) on the screen:  
```c++
text := sprint("Score: %", num_invaders_destroyed);
text_w := prepare_text(my_font, text);
draw_prepared_text(my_font, window_width/30, window_height-my_font.character_height, .{.5, .8, .2, 1});
```

## 33.10 How to load a texture with Simp
An image `texture` can be applied to a surface to make the color of the surface vary from point to point, like painting a copy of an image onto the surface.  

A texture is defined in an image file, that has for example an extension `.png`.
The functionalities for working with textures are contained in the file `texture.jai` from module *Simp*. For example: the definition for the `Texture` struct, the proc `texture_load_from_file` and so on.  
Here is the minimal code to load a texture:

See *33.9_load_texture.jai*:
```c++
#import "Basic";
#import "Simp";

ship_map: Texture;

load_texture :: (filename: string) -> Texture {
    result: Texture;
    success := texture_load_from_file(*result, filename);
    assert(success);
    return result;
}

main :: () {
    ship_map = load_texture("assets/textures/ship.png");
}
```

The loading of a texture needs bitmap functionality, which is defined in `bitmap.jai`.

Let's extend the previous example so that the ship texture is shown as a tile in a whole window:  

See *33.15_drawing_texture.jai*:
```c++
#import "Basic";
#import "Math";
#import "Window_Creation";
#import "System";
#import "File";
#import "Input";
#import "GL";
#import "Simp";
#import "Random";

WINDOW_SCALE :: 0.5;
WINDOW_WIDTH :: 1920;
WINDOW_HEIGHT :: 1080;

TILE_SIZE :: 32;

ARENA_WIDTH :: 40;
ARENA_HEIGHT :: 30;

Sprite :: struct {
    texture: *Texture;
    offset := Vector2.{0, 0};
    centered := true;
}

Entity :: struct {
    using position: Vector2;
    using sprite: Sprite;
}

Tile :: struct {
    #as using entity: Entity;
}

tiles: [..]Tile;
tile_texture: Texture;

init_textures :: () {
    tile_texture = load_texture("assets/textures/ship.png");
}

load_texture :: (filename: string) -> Texture {
    result: Texture;
    success := texture_load_from_file(*result, filename);
    assert(success);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    return result;
}

spawn_tile :: (id: int, x: int, y: int) {
    tile := Tile.{ x = xx x, y = xx y, 
                   sprite = .{ texture = *tile_texture, }
                 };
    array_add(*tiles, tile);
}

render_sprite :: (position: Vector2, using sprite: Sprite) {
    size := Vector2.{xx texture.width, xx texture.height};
    center_offset := ifx centered then size / 2 else Vector2.{0, 0};
    pos := position - center_offset + offset;
    
    set_shader_for_images(texture);
    immediate_begin();

    v0 := Vector2.{pos.x, pos.y};
    v1 := Vector2.{pos.x + size.x, pos.y};
    v2 := Vector2.{pos.x + size.x, pos.y + size.y};
    v3 := Vector2.{pos.x, pos.y + size.y};

    uv0 := Vector2.{0,0};
    uv1 := Vector2.{1,0};
    uv2 := Vector2.{1,1};
    uv3 := Vector2.{0,1};

    immediate_quad(v0, v1, v2, v3, uv0 = uv0, uv1 = uv1, uv2 = uv2, uv3 = uv3);
    immediate_flush();
}

main :: () {
    width := cast(int) (WINDOW_WIDTH * WINDOW_SCALE);
    height := cast(int) (WINDOW_HEIGHT * WINDOW_SCALE);

    window := create_window(window_name = "Load a texture", width = width, height = height);
    set_render_target(window);
    window_width, window_height := get_render_dimensions(window);

    init_textures();

    for y: 0..ARENA_HEIGHT-1 {
        for x: 0..ARENA_WIDTH-1 {
            spawn_tile(xx random_get_within_range(0, 5), x * TILE_SIZE, y * TILE_SIZE);
        }
    }

    quit := false;
    while (!quit) {
        update_window_events();
        // Render 
        clear_render_target(0.15, 0.08, 0.08, 1.0);
        // Sprites
        for tiles render_sprite(it.position, it.sprite);

        for events_this_frame {
            if it.type == {
                case .QUIT; quit = true;
            }
        }
        swap_buffers(window);
    }
}
```

The window is shown in ![A screen with tiles](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/tiles.png).  


## 33.11 How to play a sound with module *Sound_Player*
The following example shows how to accomplish this:
(Playing a sound only works while showing a window, but we omit event-handling code here (stop the program with CTRL+C).)

See *33.10_play_sound.jai*:
```c++
#import "Basic";
#import "File";
#import "Input";
#import "Random";
#import "Simp";
#import "Sound_Player";
#import "Wav_File";
#import "Window_Creation";

OGG :: "ogg";
WAV :: "wav";
sound_alien_dies:          *Mixer_Sound_Data;
sound_player :             *Sound_Player;
last_time    : float64;

load_sound :: (basename: string) -> *Mixer_Sound_Data {
    name := tprint("assets/sounds/%", basename);
    data := load_audio_file(name);

    if !data {
        print("Error: Could not load sound file: %\n", name);
        exit(1);
    }

    return data;
}

load_audio_file :: (name : string) -> *Mixer_Sound_Data {
    data : *Mixer_Sound_Data = null;

    file_data, success := read_entire_file(name);
    if !success return data;

    has_extension :: (name: string, extension: string) -> bool {
        if name.count < extension.count  return false;
        test := name;
        advance(*test, name.count - extension.count);
        return test == extension;
    }

    if has_extension(name, WAV) {
        data = New(Mixer_Sound_Data);
        data.name = copy_string(name);
        data.buffer = file_data;

        format, samples, success2, extra := get_wav_header(data.buffer);
        if !success2 {
            log_error("Unable to parse '%' as wav.\n", data.full_path);
            return data;
        }

        if format.wFormatTag == WAVE_FORMAT_PCM {
            data.type                     = .LINEAR_SAMPLE_ARRAY;
            data.nchannels                = cast(u16) format.nChannels;
            data.nsamples_times_nchannels = samples.count/2;
        } else if format.wFormatTag == WAVE_FORMAT_DVI_ADPCM {
            data.type             = .ADPCM_COMPRESSED;
            data.wSamplesPerBlock = extra.wSamplesPerBlock;
            data.nBlockAlign      = format.nBlockAlign;
            data.nchannels = cast(u16) format.nChannels;
            data.nsamples_times_nchannels = extra.wSamplesAccordingToFactChunk * data.nchannels;
        } else {
            assert(false);
        }

        data.samples       = cast(*s16) samples.data;
        data.sampling_rate = cast(u32) format.nSamplesPerSec;
    } else if has_extension(name, OGG) {
        data = New(Mixer_Sound_Data);
        data.name   = copy_string(name);
        data.buffer = file_data;
        data.type   = .OGG_COMPRESSED;
    } else { // Unsupported format. 
    }

    return data;
}

play_sound :: (data: *Mixer_Sound_Data, perturb: bool = true) -> *Sound_Stream {
    stream := make_stream(sound_player, data);

    if stream {
        stream.sound_data = data;
    }

    if perturb && stream {
        stream.user_volume_scale = random_get_within_range(0.7, 1);
        stream.desired_rate = random_get_within_range(0.7, 1.22);
    }

    stream.repeat_end_position = cast(int)(data.sampling_rate * 234.475); 
    return stream;
}

main :: () {
    window := create_window(250, 250, "Sound");  

    sound_player = New(Sound_Player);    // (1)
    sound_player.update_history = true;
    // sound_alien_dies          = load_sound("alien_dies.wav");  // (2A)
    sound_alien_dies       = load_sound("lux_aeterna.ogg"); // (2B)     

    stream := play_sound(sound_alien_dies, false);  // (3)
    if stream {
        stream.flags |= .REPEATING;
        stream.repeat_end_position = cast(int)(sound_alien_dies.sampling_rate * 234.475);  
        stream.category = .MUSIC;
    }

    success := init(sound_player, xx window, true, true);
    assert(success);    

    while true {              // (4)             
        dt : float;
        now := get_time();
        if last_time == 0 { dt = 0; } 
        else { dt = cast(float)(now - last_time); }
        last_time = now;
 
        pre_entity_update(sound_player);
        for sound_player.streams  it.marked = true;
        post_entity_update(sound_player, dt);
    }
}
```

In line (1) we create a `Sound_Player` struct instance. (2A-B) load the sound from a .wav or .ogg file respectively. Line (3) starts playing the sound in a new thread. We need a loop (line (4)), otherwise the program stops immediately.

## 33.12 How to disable a Windows app from opening the console
In all the previous examples in this chapter, when we started the windows executable, a window appears combined with a (black) console window. But when you want to run your app in production, you don't want the console!  
There is an easy way to do this, just add the following lines to your app:  
```c++
#run {
    Windows_Resources :: #import "Windows_Resources";
    Windows_Resources.disable_runtime_console();
};
```  

Just add them above main :: (), for example in `33.2A_simp_window.jai`. After compiling with this, only the window screen will appears (see *33.2C_simp_window.jai*).

## 33.13 How to attach an icon to a Windows executable
If you want your program executable to appear in Explorer with a specific image or icon instead of the default one, add the following to your build file:  

( We assume the following:  
- `exe_name` contains the name of the executable
- the icon is stored in a file icon.png in folder assets ) 

1) Import the following modules:
```
#import "Windows_Resources";
#import "Ico_File";
```

2) In the `build` proc after compiling is complete, add this code:

```
ico_data := create_ico_file_from_bitmap_filename("assets\\icon.png");
defer free(ico_data);
if !ico_data then 
    print("Could not load image for icon: assets/icon.png\n");
else set_icon_by_data(exe_name, ico_data);

manifest_options: Manifest_Options;
manifest_options.dpi_aware = false;
add_manifest_to_executable(exe_name, manifest_options);
```

Because this feature is specific for Windows, you might want to place this code in a ` #if OS == .WINDOWS { }` section.

