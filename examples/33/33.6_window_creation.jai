#import "Input";
#import "Windows";
#import "Window_Creation";

main :: () {
    handle_window := create_window(window_name="Example", width=200, height=200);

    while true {
        update_window_events();
    }
}
