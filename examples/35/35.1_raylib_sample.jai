#import,dir "raylib";
#import "Math";

main :: () {
    InitWindow(800, 450, "JAI Sample");
    defer CloseWindow();

    SetTargetFPS(60);

    while !WindowShouldClose() {
		BeginDrawing();
		defer EndDrawing();

		ClearBackground(RAYWHITE);

		DrawText("Congrats! You created your first window!", 190, 200, 20, LIGHTGRAY);
    }
}