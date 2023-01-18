#import "Basic";

Entity :: struct {
    type: Type;
    x, y: float;
}

Player :: struct {
    using #as base: Entity;
    player_index: int;
}

main :: () {
    entities: [..]*Entity;
    p := New(Player);
    p.type = Player;
    p.player_index = 1;
    array_add(*entities, p);

    for entities {
        if it.type == Player {
            player := cast(*Player) it;
            print("%\n", p.player_index); // => 1
        }
    }   
}