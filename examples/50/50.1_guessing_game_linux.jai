#import "Basic";
#import "Random";
#import "POSIX";  

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
    buffer: [4096] u8;
    // No real way to distinguish between empty and error?
    bytes_read := read(STDIN_FILENO, buffer.data, buffer.count - 1);
    // No allocation on empty. Could use tprint here if wanted.
    return sprint("%", to_string(buffer.data, bytes_read));
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