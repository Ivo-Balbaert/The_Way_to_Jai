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
    Simp.set_shader_for_color(true);   // (2)

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