#import "Basic";
#import "Simp";

window_height: s32 = 720;
my_font: *Dynamic_Font;

main :: () {
    pixel_height := window_height / 24;
    my_font = get_font_at_size("assets/fonts/", "Anonymous Pro.ttf", pixel_height);
    assert(my_font != null);
}