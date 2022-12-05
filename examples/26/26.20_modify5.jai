#import "Basic";

Bitmap :: struct (Width: s16, Height: s16)
#modify { return Width >= Height, "Width of a Bitmap must be >= Height."; }
{
    pixels: [Width*Height] u32;
}

main :: () {
    monster: Bitmap(128, 64); // valid Bitmap
    // gateway: Bitmap(512, 1024); // Error: #modify returned false: Width of a Bitmap must be >= Height.
}