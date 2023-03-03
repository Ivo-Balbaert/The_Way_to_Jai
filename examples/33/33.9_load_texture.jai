#import "Basic";
#import "Simp";

ship_map: Texture;

make_texture :: (filename: string) -> Texture, bool {
    result: Texture;
    success := texture_load_from_file(*result, filename);
    return result, success;
}

main :: () {
    ship_map = make_texture("assets/textures/ship.png");
}