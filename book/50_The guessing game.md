# 50 The guessing game
( This example was taken from [jai-comparisons](https://github.com/contextfreecode/jai-comparisons) )

This is a console game. The program randomly chooses a number lower than a certain maximum (say 100). The player inputs an integer between 0 and 100. The program tells if the number is too low or too high, and when you have guessed the right number, in how many steps.  
Here is an example of the interaction between program and player:  
`ivo@DESKTOP-KN14QQK:~/jai*projects$ ./guessing_game  
Guess a number between 1 and 100: 75  
75 is too high  
Guess a number between 1 and 100: 63  
63 is too high  
Guess a number between 1 and 100: 52  
52 is too high  
Guess a number between 1 and 100: 42  
42 is too low  
Guess a number between 1 and 100: 47  
47 is the answer!  
Finished in 5 guesses  
Total input errors: 0  

We have two versions:  
* a version working on Linux: it imports the _POSIX_ module for the `read` function in procedure `read_line` (which uses the `libdl` library): *50.1_guessing_game_linux.jai*
* a version working on Windows: it imports the _Windows_ module for the `ReadConsoleA` function in procedure `read_line`: *50.1_guessing_game_windows.jai* This version uses a somewhat lower-level API than the Linux version, that's why it is a bit more involved.

## 50.1 Discussion
First we look at the Linux version. The logic for the Windows version is entirely the same, except for the read_line input part.

### 50.1.1 Linux version
See *50.1_guessing_game_linux.jai*:
```c++
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
```

First we need to pick a random number, for which we use the technique laid out in § 6B.2  
`pick_answer` determines the `answer` the player should guess. It uses `random_get`, which uses the random seed from the line before.

The game data are stored in a struct instance game of type Game (defined in (1)). This is populated with data in lines (2) and following, and the game starts in (3):  
`play(*game);`

This consists of the following steps:  
(1) `ask_guess_multi`  
    --> (1.1) `ask_guess`
        --> (1.1.1) `read_line`

This reads in a string, which must be converted to an integer before returning as the `guess`.
It does this by calling the proc `read` from module _POSIX_, which reads input from stdin and stores it in a `buffer`. This is converted to a string with `to_string`.

(2) `report`
    This compares the guess with the answer, and prints the guess and the response from the game.

(3) `update`
    Here the Game state is updated: the number of guesses is incremented and `done` is set to true when guess == answer.

When done == true, the while loop in play stops :
`while !game.done`
and line (3) returns. This prints "Finished in ", the number of guesses and eventual errors and stops the game.

### 50.1.2 Windows version
Here is the Windows version:
See *50.1_guessing_game_windows.jai*:
```c++
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
    stdin = GetStdHandle( STD_INPUT_HANDLE );    // (4)
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
```

We discuss only the different part, which is:
--> (1.1.1) `read_line`

This reads in a string, which must be converted to an integer before returning as the `guess`.
It does this by calling the proc `ReadConsoleA` from the _kernel32.dll_ Windows system library, which reads input from stdin and stores it in a `buffer`. We then allocate a string `result` with the same amount of bytes as read in into the buffer. Then we copy the bytes read in from the buffer into the `result` string with `memcpy`.
At the start of our program (line (4)), we also have to get a handle for the standard input.
