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

    win := create_window(window_width, window_height, "Xiangqi");    
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