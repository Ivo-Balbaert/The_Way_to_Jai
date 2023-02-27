#import "Basic";
rl :: #import "raylib_win64";

main :: () {
	rl.InitWindow(800, 600, "Raylib Module");

	while !rl.WindowShouldClose() {
		rl.BeginDrawing();
		rl.ClearBackground(.{50, 100, 150, 255});
		rl.EndDrawing();
	}
}
