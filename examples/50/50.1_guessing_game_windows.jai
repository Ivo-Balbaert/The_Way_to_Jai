#import "Basic";
#import "Random";
#import "Windows";

kernel32 :: #system_library "kernel32";
stdin, stdout: HANDLE;

ReadConsoleA  :: (
    hConsoleHandle: HANDLE, 
    buff : *u8, 
    chars_to_read : s32,  
    chars_read : *s32, 
    lpInputControl := *void 
) -> bool #foreign kernel32;

Game :: struct {            // (1)
    answer: int;
    done: bool;
    guesses: int;
    high: int;
}

err_count := 0;

ask_guess :: (high: int) -> result: int, ok: bool {
    print("Guess a number between 1 and %: ", high);
    text := read_line();
    if text {
        defer free(text);
        result, ok, _ := to_integer(text);
        return result, ok;
    }
    return result = 0, ok = false;
}

ask_guess_multi :: (high: int) -> int {
    while true {
        result, ok := ask_guess(high = high);
        if ok then return result;
        print("I didn't understand\n");
        err_count += 1;
    }
    // Shouldn't ever happen, but avoids warning.
    return -1;
}

pick_answer :: (high: int) -> int {
    return cast(int) (random_get() % cast(u64) high) + 1;
}

play :: (game: *Game) {
    while !game.done {
        guess := ask_guess_multi(game.high);
        report(game, guess);
        <<game = update(game, guess);
        // Could reset_temporary_storage() here.
    }
}

read_line :: () -> string {
    MAX_BYTES_TO_READ :: 1024;
    buffer : [MAX_BYTES_TO_READ] u8;
    result: string = ---;
    bytes_read : s32;
    
    if !ReadConsoleA( stdin, buffer.data, xx buffer.count, *bytes_read )   return "";

    result.data  = alloc(bytes_read);
    result.count = bytes_read;
    memcpy(result.data, buffer.data, bytes_read);
    return result;
}

report :: (game: Game, guess: int) {
    // game.done = true;
    // print("%\n", *game);
    description :=
        ifx guess < game.answer then "too low"
        else ifx guess > game.answer then "too high"
        else "the answer!";
    print("% is %\n", guess, description);
}

update :: (game: Game, guess: int) -> next: Game {
    next := game;
    next.done = guess == game.answer;
    next.guesses += 1;
    return next;
}

main :: () {
    stdin = GetStdHandle( STD_INPUT_HANDLE );
    high :: 100;
    random_seed(current_time_monotonic().low);
    answer := pick_answer(high);
    game: Game;                 // (2)
    game.answer = answer;
    game.high = high;
    play(*game);                // (3)
    print("Finished in % guesses\n", game.guesses);
    print("Total input errors: %\n", err_count);
}