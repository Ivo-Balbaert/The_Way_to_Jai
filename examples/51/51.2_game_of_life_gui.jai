#import "Basic";
#import "GetRect";
Input :: #import "Input";
#import "Math";
#import "Simp";
#import "Window_Creation";

main :: () {
  win := create_window(800, 600, "John Conway's Game of Life");
  window_width, window_height := get_render_dimensions(win);
  set_render_target(win);
  ui_init();
  setup_getrect_theme(.Grayscale);
  dt := 0.01;
  timer := 0.0;

  while eventloop := true {                 // (1) game event loop
    Input.update_window_events();
    for Input.get_window_resizes() {
      update_window(it.window);
      if it.window == win {
        window_width  = it.width;
        window_height = it.height;
      }
    }

    mouse_pressed := false;
    for event: Input.events_this_frame {     // (2) event handling
      if event.type == .QUIT then 
        break eventloop;
      getrect_handle_event(event);
      if event.type == .KEYBOARD then {
        if event.key_pressed {
          if event.key_code == {
          case .MOUSE_BUTTON_LEFT;
            mouse_pressed = true;
          case .ARROW_UP;
            render_j -= 1;
            render_j &= M-1;
          case .ARROW_DOWN;
            render_j += 1;
            render_j &= M-1;
          case .ARROW_LEFT;
            render_i -= 1;
            render_i &= M-1;
          case .ARROW_RIGHT;
            render_i += 1;
            render_i &= M-1;
          }
        }
      }
    }

    if timer >= max_time then {
      next_generation();
      timer = 0.0;
    }

    current_time := get_time();
    render_gol(win, current_time, mouse_pressed);
    sleep_milliseconds(10);

    if play == true then {
      timer += dt;
    }

    reset_temporary_storage();              // (3)
  }
}

#scope_file                     // (4)
play := false;

M :: 128;
#assert((M & (M-1)) == 0);
gol_grid: [M][M] s8;

next_generation :: () {         // (5)
  temp: [M][M] s8 = ---;
  for i: 0..M-1 {
    for j: 0..M-1 {
      count := neighbors_count(i, j);
      if gol_grid[i][j] == 1 {
        if count < 2 || count > 3 then
          temp[i][j] = 0;
        else
          temp[i][j] = 1;
      } else {
        if count == 3
          temp[i][j] = 1;
        else
          temp[i][j] = 0;
      }
    }
  }

  for i: 0..M-1 {               // (6)
    for j: 0..M-1 {
      gol_grid[i][j] = temp[i][j];
    }
  }

  neighbors_count :: (i: int, j: int) -> s8 #expand {
    count: s8 = 0;
    count += gol_grid[wrap(i-1)][wrap(j-1)];
    count += gol_grid[wrap(i-1)][j];
    count += gol_grid[wrap(i-1)][wrap(j+1)];

    count += gol_grid[i][wrap(j-1)];
    count += gol_grid[i][wrap(j+1)];

    count += gol_grid[wrap(i+1)][wrap(j-1)];
    count += gol_grid[wrap(i+1)][j];
    count += gol_grid[wrap(i+1)][wrap(j+1)];
    return count;
  }
}

wrap :: (index: int) -> int #expand {
  return index & (M-1);
}

render_i := 0;
render_j := 0;
sq_width := 35.0;

render_gol :: (win: Window_Type, current_time: float64, mouse_pressed: bool) #expand {
  // background.
  clear_render_target(.35, .35, .35, 1);
  defer swap_buffers(win);
  width, height := get_render_dimensions(win);

  set_shader_for_color();

  i := render_i;
  j := render_j;
  cycles_x := 0;
  sq_x: float = 0.0;
  sq_y: float = xx height;
  fwidth: float = xx width;
  fheight: float = xx height;
  offset := sq_width * 0.025;
  dark := Vector4.{.15, .15, .15, 1};
  while sq_x < fwidth && cycles_x < M {
    sq_y = fheight;
    j = render_j;
    cycles_y := 0;
    while sq_y > 0 && cycles_y < M {
      if gol_grid[i][j] == 1 {
        immediate_quad(sq_x + offset, sq_y - offset, sq_x + sq_width - offset, sq_y - sq_width + offset, color_theme);
      } else {
        immediate_quad(sq_x + offset, sq_y - offset, sq_x + sq_width - offset, sq_y - sq_width + offset, dark);
      }
      sq_y -= sq_width;
      j = (j + 1) & (M-1);
      cycles_y += 1;
    }
    sq_x += sq_width;
    i = (i + 1) & (M-1);
    cycles_x += 1;
  }

  ui_per_frame_update(win, width, height, current_time);

  ui_interaction := false;
  k := clamp(height * .05, 17.0, 30.0);
  r := get_rect(5, (xx height) - 5.0 - k, 8.5*k, k);
  play_text := ifx play == true "Stop" else "Simulate";
  if button(r, play_text) {
    play = !play;
    ui_interaction = true;
  }

  r.y -= k + 5.0;

  if button(r, "Next") {
    next_generation();
    ui_interaction = true;
  }

  r.y -= k + 5.0;

  if button(r, "Zoom In") {
    sq_width = min(sq_width+1.0, xx min(width, height));
    ui_interaction = true;
  }

  r.y -= k + 5.0;

  if button(r, "Zoom Out") {
    sq_width = max(sq_width-1.0, 1.0);
    ui_interaction = true;
  }

  r.y -= k + 5.0;

  if button(r, "Clear") {
    memset(gol_grid.data, 0, size_of(#type [M][M] s8));
    ui_interaction = true;
  }

  r.y -= k + 5.0;

  if slider(r, *max_time, 0.01, 3.0, 0.01, *getrect_theme.slider_theme, "Update ", " secs") {
    ui_interaction = true;
  }

  r.y -= k + 5.0;

  choice := color_option_choice;
  dropdown_state := dropdown(r, color_options, *choice);
  if (prev_open == true && dropdown_state.open == false) || (dropdown_state.open == true) {
    ui_interaction = true;
  }
  prev_open = dropdown_state.open;

  defer {
    draw_popups();
    if choice != color_option_choice {
      color_option_choice = choice;
      if color_option_choice == 0 {
        color_theme = Vector4.{1,1,0,1};
      } else if color_option_choice == 1 {
        color_theme = Vector4.{0,1,0,1};
      } else if color_option_choice == 2 {
        color_theme = Vector4.{1,0,0,1};
      } else if color_option_choice == 3 {
        color_theme = Vector4.{.25,.25,1,1};
      }
    } 
  }

  if ui_interaction == false && mouse_pressed then {
    mouse_x, mouse_y := get_mouse_pointer_position(win, true);
    i := (cast(int) (mouse_x / sq_width) + render_i) & (M-1);
    j := (cast(int) ((height - mouse_y) / sq_width) + render_j) & (M-1);
    if i >= 0 && i < M && j >= 0 && j < M then {
      gol_grid[i][j] ^= 1;
    }
  }

  color_options :: string.[
    "yellow",
    "green",
    "red",
    "blue"
  ];
  

}

color_option_choice: s32;
max_time: float = 1.0;
getrect_theme: Overall_Theme; 
color_theme := Vector4.{1,1,0,1};
prev_open: bool = false;

setup_getrect_theme :: (theme: Default_Themes) #expand {
  proc := default_theme_procs[theme];
  getrect_theme = proc();
  button_theme := *getrect_theme.button_theme;
  button_theme.label_theme.alignment = .Left;

  slider_theme := *getrect_theme.slider_theme;
  slider_theme.foreground.alignment = .Left;
  set_default_theme(getrect_theme);
}