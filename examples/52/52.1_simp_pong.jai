/* TODO
v - bounce ball against walls
v - draw ball, net, pallets
v - moving pallets with keys:  Left:  z and s / Right: i and k
v - pallet bouncing against pallets
v - keep scores: player1 - player2
- draw scores
- sound 
- refactoring:
    - constants
- real ball instead of rect?
*/

#import "Basic";
#import "Input";
#import "Math";
Simp :: #import "Simp";
#import "System";
#import "Window_Creation";


WHITE :: Vector4.{1.0, 1.0, 1.0, 1.0};
BLUE  :: Vector4.{0.0, 0.0, 1.0, 1.0};
RED :: Vector4.{1.0, 0.0, 0.0, 1.0};

BALL_SIZE :: 15.0;
PALLET_WIDTH :: 10.0;
PALLET_HEIGHT :: 75.0;
NET_SIZE:: 2.0;
VELOCITY :: 2.0;

// keys to move pallets:
Z :: 90; // left up
S :: 83; // left down
I :: 73; // right up  
K :: 75; // right down  

main :: () {
    window_width  := 800;
    window_height := 600;
    render_width  := window_width;
    render_height := window_height;

    scorepL := 0;
    scorepR := 0;

    win := create_window(window_width, window_height, "Jai Pong with Simp");    
    Simp.set_render_target(win);
    Simp.set_shader_for_color(true);

    // coordinates of ping pong ball
    ball_x := 0.0;                             
    ball_y := 0.0;
    dx := 1.0;
    dy := 1.0;

    // coordinates of pallets:
    // left: (lpb = left pallet bottom, lpt = left pallet top )
    lpb := Vector2.{0, cast(float) (window_height/2 - PALLET_HEIGHT/2)};
    lpt := Vector2.{PALLET_WIDTH, cast(float) (window_height/2 + PALLET_HEIGHT)};
    // right: (rpb = right pallet bottom, rpt = right pallet top )
    rpb := Vector2.{cast(float) (window_width - PALLET_WIDTH), 
                    cast(float) (window_height/2 - PALLET_HEIGHT/2)};
    rpt := Vector2.{cast(float) (window_width), 
                    cast(float) (window_height/2 + PALLET_HEIGHT)};
    pdx := 40.0;
    pdy := 40.0;

    quit := false;
    

    collL, collR: bool;
         
    while !quit {
        collL, collR = false;

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
                        // moving left pallet up (z):
                        case Z;  { 
                            if lpt.y <= xx window_height { lpb.y += pdy; lpt.y += pdy; } 
                        }   
                        // moving left pallet down (s): 
                        case S; {
                            if lpb.y > 0 { lpb.y -= pdy;  lpt.y -= pdy; } 
                        }
                        // moving right pallet up (i):
                        case I;  {
                            if rpt.y <= xx window_height { rpb.y += pdy;  rpt.y += pdy; } 
                        }   
                        // moving right pallet down (k): 
                        case K; {
                            if rpb.y > 0 { rpb.y -= pdy;  rpt.y -= pdy; } 
                        }
                    }
                }
            }
        }

        // check collision ball - left pallet:
        if (lpb.x < ball_x + dx && ball_x + dx < lpt.x ) && 
           (lpb.y < ball_y + dy && ball_y + dy < lpt.y) {
                collL = true;
                dx = -dx;
                dy = -dy; 
        }

        // check collision ball - right pallet:
        if (rpb.x <= ball_x + BALL_SIZE && ball_x <= rpt.x) && 
           (rpb.y <= ball_y + BALL_SIZE && ball_y <= rpt.y) {
                collR = true;
                dx = -dx;
                dy = -dy;
        }

        // otherwise, ball must bounce against the walls:
        if !(collL || collR) {
            if ball_x + dx < 0.0 || ball_x + dx + BALL_SIZE > cast(float) window_width   
                dx = -dx;
            if ball_y + dy < 0.0 || ball_y + dy + BALL_SIZE > cast(float) window_height    
                dy = -dy;
        } 
        
        // set scores:
        if  !collR && (ball_x - dx + BALL_SIZE > cast(float) window_width)   scorepL +=1;
        if  !collL && (ball_x - dx < 0)                          scorepR +=1;

        if (scorepL != 0 || scorepR != 0)
            print("Scores: playerLeft % / playerRight %\n", scorepL, scorepR);

        // move ball:
        ball_x += dx * VELOCITY;        
        ball_y += dy * VELOCITY;       

        // draw pingpong net:
        Simp.immediate_quad(cast(float) window_width/2, 0, 
                            cast(float) (window_width/2 + NET_SIZE), 
                            cast(float) (window_height + NET_SIZE), 
                            WHITE);

        // draw ball:
        Simp.immediate_quad(ball_x, ball_y, ball_x + BALL_SIZE, ball_y + BALL_SIZE, RED);

        // draw pallets:
        Simp.immediate_quad(lpb.x, lpb.y, lpt.x, lpt.y, BLUE);
        Simp.immediate_quad(rpb.x, rpb.y, rpt.x, rpt.y, BLUE);

        sleep_milliseconds(10);
        Simp.swap_buffers(win);
        reset_temporary_storage();    
    }
}