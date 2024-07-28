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
