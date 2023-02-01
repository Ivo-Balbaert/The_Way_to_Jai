# 35 External graphical modules.

## 35.1 Raylib
[raylib](https://www.raylib.com/) is a simple and easy-to-use library to enjoy videogames programming. It supports multiple target platforms, it has been tested in the following ones but, technically, any platform that supports C language and OpenGL graphics (or similar) can run raylib or it can be very easily ported to.

The Jai community has made several versions of a module for binding to raylib:  
* [Raylib-Jai](https://github.com/shiMusa/Raylib-Jai) - auto-generated bindings for Raylib 4
* [Raylib-Jai examples](https://github.com/kujukuju/raylib-jai) - with direct Jai ports of the [raylib examples](https://www.raylib.com/examples.html).

We use the kujukuju module here.
In order to use Raylib, we need `raylib.dll`.  
Get it from the lib folder in the Jai module, or from the following [distribution](https://github.com/raysan5/raylib/releases/download/2.6.0/raylib-2.6.0-Win64-msvc15.zip).   
Copy raylib.dll next to the game executable.

See *35.1_raylib_sample.jai*:
```c++
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
```
Compile this with `jai 35.1_raylib_sample.jai` and run the executable. A simple window with the following centered text: "Congrats! You created your first window!" appears.

