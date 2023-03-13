#import "Basic";
#import "Simp";

ship_map: Texture;

load_texture :: (filename: string) -> Texture {
    result: Texture;
    success := texture_load_from_file(*result, filename);
    assert(success);
    return result;
}

main :: () {
    ship_map = load_texture("assets/textures/ship.png");
}