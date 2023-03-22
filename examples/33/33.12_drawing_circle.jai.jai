#import "Basic";
#import "Input";
#import "Math";
Simp :: #import "Simp";
#import "Window_Creation";

RED   :: Vector4.{1, 0, 0, 1};
GREEN :: Vector4.{0, 1, 0, 1};
CIRCLE_RESOLUTION :: 30;         // number of triangles used to draw circle

immediate_circle :: (center: Vector2, radius: float, color: Vector4) {
    STEP_ANGLE :: 2*PI/CIRCLE_RESOLUTION;
    for 0..CIRCLE_RESOLUTION-1 {
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

        immediate_circle(make_vector2(cast(float) window_width/2, cast(float) window_height/2), 
                25, GREEN);  

        x, y, success := get_mouse_pointer_position();   // (3)
        immediate_circle(make_vector2(xx x, xx (window_height - y)), 15, RED);

        Simp.swap_buffers(win);
        sleep_milliseconds(10);
        reset_temporary_storage();   
    }
}