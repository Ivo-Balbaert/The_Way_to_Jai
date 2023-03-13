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

    win := create_window(window_width, window_height, "Tetris Start");    
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