#import "Basic";

main :: () {
    args := get_command_line_arguments();
    defer  array_reset(*args);

    print("Number of command line arguments: %\n", args.count);
    print("The command-line arguments are:\n");
    for args {
        print("Position: % - Value: %\n", it_index, it);
    }
}

/* Start program as: '19B.exe 42 "hello" 3.14'
Number of command line arguments: 4
The command-line arguments are:
Position: 0 - Value: 19B
Position: 1 - Value: 42
Position: 2 - Value: hello
Position: 3 - Value: 3.14
*/