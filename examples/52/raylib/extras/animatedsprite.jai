// loads a basic animated sprite in row first order, where each cell is the same size
// later might add a way to load animated sprites that are packed

AnimatedSprite :: struct {
    texture: Texture2D;
    width: int;
    height: int;
    columns: int;
    frameCount: int;
    anchor: Vector2;
    scale: Vector2;
    tint: Color;
    frame: int;
}

CreateAnimatedSprite :: (texture: Texture2D, width: int, height: int, columns: int, frameCount: int, anchor: Vector2 = .{0, 0}, scale: Vector2 = .{1, 1}, tint: Color = WHITE, frame: int = 0) -> AnimatedSprite {
    sprite: AnimatedSprite = ---;
    sprite.texture = texture;
    sprite.width = width;
    sprite.height = height;
    sprite.columns = columns;
    sprite.frameCount = frameCount;
    sprite.anchor = anchor;
    sprite.scale = scale;
    sprite.tint = tint;
    sprite.frame = 0;

    return sprite;
}

DrawSprite :: (sprite: AnimatedSprite, position: Vector2) {
    scaleSignX := ifx sprite.scale.x < 0 then -1 else 1;
    scaleSignY := ifx sprite.scale.y < 0 then -1 else 1;

    rect: Rectangle = ---;
    rect.x = cast(float) (sprite.frame % sprite.columns) * sprite.width;
    rect.y = cast(float) (sprite.frame / sprite.columns) * sprite.height;
    rect.width = cast(float) sprite.width * scaleSignX;
    rect.height = cast(float) sprite.height * scaleSignY;

    // for some reason negative width doesnt work in the destination, only the source
    dest: Rectangle = ---;
    dest.x = position.x - sprite.anchor.x * sprite.width * abs(sprite.scale.x);
    dest.y = position.y - sprite.anchor.y * sprite.height * abs(sprite.scale.y);
    dest.width = sprite.width * abs(sprite.scale.x);
    dest.height = sprite.height * abs(sprite.scale.y);

    // what does origin do here?
    DrawTexturePro(sprite.texture, rect, dest, .{0, 0}, 0, sprite.tint);
}

#scope_file
#import "Math";
