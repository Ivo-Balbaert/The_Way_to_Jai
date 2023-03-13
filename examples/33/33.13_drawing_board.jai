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