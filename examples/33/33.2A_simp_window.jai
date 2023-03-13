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

    win := create_window(window_width, window_height, "Simp_Window");    // (1)
    Simp.set_render_target(win);
    Simp.set_shader_for_color(true);

    quit := false;
    while !quit {                          // (2)
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

        sleep_milliseconds(10);
        Simp.swap_buffers(win);
        reset_temporary_storage();    // (3)
    }
}