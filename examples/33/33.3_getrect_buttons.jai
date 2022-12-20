#import "Basic";
#import "GetRect";
Input :: #import "Input";
#import "Simp";
#import "Window_Creation";

val: s32 = 0;

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
  if button(r, "Button 0") {
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

