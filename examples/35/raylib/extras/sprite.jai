Sprite :: struct {
    texture: Texture2D;
    width: int;
    height: int;
    anchor: Vector2;
    scale: Vector2;
    tint: Color;
}

CreateSprite :: (texture: Texture2D, width: int, height: int, anchor: Vector2 = .{0, 0}, scale: Vector2 = .{1, 1}, tint: Color = WHITE) -> Sprite {
    sprite: Sprite = ---;
    sprite.texture = texture;
    sprite.width = width;
    sprite.height = height;
    sprite.anchor = anchor;
    sprite.scale = scale;
    sprite.tint = tint;

    return sprite;
}

DrawSprite :: (sprite: Sprite, position: Vector2) {
    scaleSignX := ifx sprite.scale.x < 0 then -1 else 1;
    scaleSignY := ifx sprite.scale.y < 0 then -1 else 1;

    rect: Rectangle = ---;
    rect.x = 0;
    rect.y = 0;
    rect.width = sprite.width * scaleSignX;
    rect.height = sprite.height * scaleSignY;

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
