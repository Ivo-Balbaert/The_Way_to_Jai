#import "Basic";

Player :: struct {
    name: string;
    score: u8;
}

players: [..]Player;

for_expansion :: (_: *type_of(players), body: Code,   // (1)
                  flags: For_Flags) #expand {
    for `it, `it_index: players {
        print("inside macro! \n");
        if it_index >= players.count  break;
        #insert body;
    }
}

player_loop :: (_: *type_of(players), body: Code,      // (2)
                  flags: For_Flags) #expand {
    for `it, `it_index: players {
        print("inside macro player_loop! \n");
        if it_index >= players.count  break;
        #insert body;
    }
}

main :: () {
    p1 := Player.{"Jane", 82};
    p2 := Player.{"John", 75};
    array_add(*players, p1);
    array_add(*players, p2);
    for players     print("Player no % is %\n", it_index, it);   // (3)
    /*
    Player no 0 is {"Jane", 82}
    Player no 1 is {"John", 75}
    */

    for player: players {                                        // (4)
        print("Player is %\n", player);
    }
    /*
    Player is {"Jane", 82}
    Player is {"John", 75}
    */

    // This uses the for_expansion macro
    for :for_expansion   player: players {                         // (5)
         print("Player is %\n", player);
    }
    /*
    inside macro!
    Player is {"Jane", 82}
    inside macro!
    Player is {"John", 75}
    */

     // This uses the player_loop macro
    for :player_loop   player, ix: players {                       // (6)
         print("Player % is %\n", ix, player);
    }
    /*
    inside macro player_loop!
    Player 0 is {"Jane", 82}
    inside macro player_loop!
    Player 1 is {"John", 75}
    */
}

