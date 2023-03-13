#import "Basic";
#import "Math";
#import "Window_Creation";
#import "System";
#import "File";
#import "Input";
#import "GL";
#import "Simp";
#import "Random";

WINDOW_SCALE :: 0.5;
WINDOW_WIDTH :: 1920;
WINDOW_HEIGHT :: 1080;

TILE_SIZE :: 32;

ARENA_WIDTH :: 40;
ARENA_HEIGHT :: 30;

Sprite :: struct {
    texture: *Texture;
    offset := Vector2.{0, 0};
    centered := true;
}

Entity :: struct {
    using position: Vector2;
    using sprite: Sprite;
}

Tile :: struct {
    #as using entity: Entity;
}

tiles: [..]Tile;
tile_texture: Texture;

init_textures :: () {
    tile_texture = load_texture("assets/textures/ship.png");
}

load_texture :: (filename: string) -> Texture {
    result: Texture;
    success := texture_load_from_file(*result, filename);
    assert(success);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    return result;
}

spawn_tile :: (id: int, x: int, y: int) {
    tile := Tile.{ x = xx x, y = xx y, 
                   sprite = .{ texture = *tile_texture, }
                 };
    array_add(*tiles, tile);
}

render_sprite :: (position: Vector2, using sprite: Sprite) {
    size := Vector2.{xx texture.width, xx texture.height};
    center_offset := ifx centered then size / 2 else Vector2.{0, 0};
    pos := position - center_offset + offset;
    
    set_shader_for_images(texture);
    immediate_begin();

    v0 := Vector2.{pos.x, pos.y};
    v1 := Vector2.{pos.x + size.x, pos.y};
    v2 := Vector2.{pos.x + size.x, pos.y + size.y};
    v3 := Vector2.{pos.x, pos.y + size.y};

    uv0 := Vector2.{0,0};
    uv1 := Vector2.{1,0};
    uv2 := Vector2.{1,1};
    uv3 := Vector2.{0,1};

    immediate_quad(v0, v1, v2, v3, uv0 = uv0, uv1 = uv1, uv2 = uv2, uv3 = uv3);
    immediate_flush();
}

main :: () {
    width := cast(int) (WINDOW_WIDTH * WINDOW_SCALE);
    height := cast(int) (WINDOW_HEIGHT * WINDOW_SCALE);

    window := create_window(window_name = "Load a texture", width = width, height = height);
    set_render_target(window);
    window_width, window_height := get_render_dimensions(window);

    init_textures();

    for y: 0..ARENA_HEIGHT-1 {
        for x: 0..ARENA_WIDTH-1 {
            spawn_tile(xx random_get_within_range(0, 5), x * TILE_SIZE, y * TILE_SIZE);
        }
    }

    quit := false;
    while (!quit) {
        update_window_events();
        // Render 
        clear_render_target(0.15, 0.08, 0.08, 1.0);
        // Sprites
        for tiles render_sprite(it.position, it.sprite);

        for events_this_frame {
            if it.type == {
                case .QUIT; quit = true;
            }
        }
        swap_buffers(window);
    }
}