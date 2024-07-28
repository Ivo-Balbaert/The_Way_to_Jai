# 52 The Pong game
Everybody knows the ping-pong simulation game, the first ever computer game that made it into the living room.

## 52.1  A Simp version 
Here is a still imperfect version of this game using pure Jai:

See *52.1_simp_pong.jai*:
```c++
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
```

The comments should be enough to understand the code.
See a screenshot ![here](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/simp_pong.png).   

## 52.2  A version using Raylib
(For an introduction to Raylib: see § 35.1)

A number of lovely simple games where made by `hopeforsenegal`, see [https://github.com/hopeforsenegal/SimpleGames-Jai]. Written in Jai, using a Jai wrapper to the Raylib module.  
Here is the version of the Pong game from this collection.

See *52.2_jai_raylib_pong.jai*:
```c++
#import "String"; 
#import "Math"; 
#import "Basic";
raylib :: #import,dir "raylib";

TextAlignment :: enum {
	Left; 
	Center;
	Right;
}

Rectangle :: struct {
	centerPosition: Vector2;
	size:           Vector2;
}

Ball :: struct {
 using rectangle: Rectangle;
	   velocity:  Vector2;
}

InputScheme :: struct {
	upButton:   raylib.KeyboardKey;
	downButton: raylib.KeyboardKey;
}

Pad :: struct {
 using rectangle: 	Rectangle;
 using input: 		InputScheme;
	   score:    	int;
	   velocity: 	Vector2;
}

players: 	[2]Pad;
player1: 	*Pad;
player2: 	*Pad;
ball: 		Ball;

InitialBallPosition: Vector2;

main :: () {
    raylib.InitWindow(800, 450, "JAI Pong");
    defer raylib.CloseWindow();
	raylib.SetTargetFPS(60);
	
	player1 = *players[0];	// We have to do this here instead of above since pointers to array aren't constant yet
	player2 = *players[1];	// Careful to not put player2 := *players[1] because you will shadow and crash
	
	screenSizeX := raylib.GetScreenWidth();
	screenSizeY := raylib.GetScreenHeight();
	
	InitialBallPosition = make_vector2(cast(float)(screenSizeX/2), cast(float)(screenSizeY/2));
	ball.velocity = make_vector2(150, 125);
	ball.centerPosition = InitialBallPosition;
	ball.size = make_vector2(10, 10);
	player2.size = make_vector2(5, 50);
	player1.size = make_vector2(5, 50);
	player2.score = 0;
	player1.score = 0;
	player2.velocity = make_vector2(200, 200);
	player1.velocity = make_vector2(200, 200);
	player1.centerPosition = make_vector2(cast(float)(0 + 5), cast(float)(screenSizeY / 2));
	player2.centerPosition = make_vector2(cast(float)(cast(float)(screenSizeX) - player2.size.x - 5), cast(float)(screenSizeY / 2));
	player1.input = InputScheme.{
		.KEY_W,
		.KEY_S,
	};
	player2.input = InputScheme.{
		.KEY_I,
		.KEY_K,
	};
	
    while !raylib.WindowShouldClose() {
        reset_temporary_storage();	// reset the memory used by tprint
		dt := raylib.GetFrameTime();
		Update(dt);
		Draw();
    }
}

Update :: (deltaTime:float64){
	height := raylib.GetScreenHeight();
	width := raylib.GetScreenWidth();
	{ // Update players
		for * player: players{
			if(raylib.IsKeyDown(player.downButton)){
				// Update position
				player.centerPosition.y += cast(float)(deltaTime * player.velocity.y);
				// Clamp on bottom edge
				if(player.centerPosition.y + (player.size.y/2) > cast(float)height){
					player.centerPosition.y = height - (player.size.y /2);
				}
			}
			if(raylib.IsKeyDown(player.upButton)){
				// Update position
				player.centerPosition.y -= cast(float)(deltaTime * player.velocity.y);
				// Clamp on top edge
				if(player.centerPosition.y - (player.size.y/2) < 0){
					player.centerPosition.y = player.size.y /2;
				}
			}
		}
	}
	{ // Update ball
		ball.centerPosition.x += cast(float)deltaTime * ball.velocity.x;
		ball.centerPosition.y += cast(float)deltaTime * ball.velocity.y;
	}
	{ // Check collisions
		for player : players {
			isDetectBallTouchesPad := DetectBallTouchesPad(ball, player);
			if isDetectBallTouchesPad {
				ball.velocity.x *= -1;
			}
		}
		isBallOnTopBottomScreenEdge := ball.centerPosition.y > cast(float)(height) || ball.centerPosition.y < 0;
		isBallOnRightScreenEdge := ball.centerPosition.x > cast(float)(width);
		isBallOnLeftScreenEdge := ball.centerPosition.x < 0;
		if isBallOnTopBottomScreenEdge {
			ball.velocity.y *= -1;
		}
		if isBallOnLeftScreenEdge {
			ball.centerPosition = InitialBallPosition;
			player2.score += 1;
		}
		if isBallOnRightScreenEdge {
			ball.centerPosition = InitialBallPosition;
			player1.score += 1;
		}
	}
}

Draw :: (){
    raylib.BeginDrawing();
    defer raylib.EndDrawing();
    raylib.ClearBackground(raylib.BLACK);
	
	height := raylib.GetScreenHeight();
	width := raylib.GetScreenWidth();
	
	{ // Draw players
		for player: players{
			raylib.DrawRectangle(cast(s32)(player.centerPosition.x-(player.size.x/2)), cast(s32)(player.centerPosition.y-(player.size.y/2)), cast(s32)(player.size.x), cast(s32)(player.size.y), raylib.WHITE);		
		}
	}
	{ // Draw Court Line
		LineThinkness :: 2.0; 
		x := width / 2.0;
		from := make_vector2(x, 5.0);
		to := make_vector2(x, height - 5.0);
		
		raylib.DrawLineEx(from, to, LineThinkness, raylib.LIGHTGRAY);
	}
	{ // Draw Scores
		DrawText(tprint("%", player1.score), TextAlignment.Right, (width/2)-10, 10, 20);
		DrawText(tprint("%", player2.score), TextAlignment.Left,  (width/2)+10, 10, 20);
	}
	{ // Draw Ball
		raylib.DrawRectangle(cast(s32)(ball.centerPosition.x-(ball.size.x/2)), cast(s32)(ball.centerPosition.y-(ball.size.y/2)), cast(s32)(ball.size.x), cast(s32)(ball.size.y), raylib.WHITE);
	}
}

DetectBallTouchesPad :: (ball:Ball, pad:Pad) ->bool {
	if ball.centerPosition.x >= pad.centerPosition.x && ball.centerPosition.x <= pad.centerPosition.x+pad.size.x {
		if ball.centerPosition.y >= pad.centerPosition.y-(pad.size.y/2) && ball.centerPosition.y <= pad.centerPosition.y+pad.size.y/2 {
			return true;
		}
	}
	return false;
}

DrawText :: (text:string, alignment:TextAlignment, posX:s32, posY:s32, fontSize :s32){
	fontColor := raylib.LIGHTGRAY;
	if alignment == .Left {
		 raylib.DrawText(text.data, posX, posY, fontSize, fontColor);
	} else if alignment == .Center {
		scoreSizeLeft := raylib.MeasureText(text.data, fontSize);
		raylib.DrawText(text.data, (posX - scoreSizeLeft/2), posY, fontSize, fontColor);
	} else if alignment == .Right {
		scoreSizeLeft := raylib.MeasureText(text.data, fontSize);
		raylib.DrawText(text.data, (posX - scoreSizeLeft), posY, fontSize, fontColor);
	}
}
```

See a screenshot ![here](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/jai_raylib_pong.png).   

