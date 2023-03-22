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
