# 19B - Get command-line arguments

Often it is useful to start a program on the command-line with some arguments that will alter the behavior of the program, like this:

        `prog1 arg1 arg2 arg3`
or:     
        `./prog1 arg1 arg2 arg3`

This is done with the `get_command_line_arguments` proc from module _Basic_, which returns an array of type []string.

See *19B.1_command_line_args.jai*:
```c++
#import "Basic";

main :: () {
    args := get_command_line_arguments(); 
    defer  array_reset(*args);

    print("Number of command line arguments: %\n", args.count);
    print("The command-line arguments are:\n");
    for args {  // (1)
        print("Position: % - Value: %\n", it_index, it);
    }
}

/* Start program as: '19B.exe 42 "hello" 3.14'
Number of command line arguments: 4
The command-line arguments are:
Position: 0 - Value: 19B.exe
Position: 1 - Value: 42
Position: 2 - Value: hello
Position: 3 - Value: 3.14
*/
```

Line (1) prints out all the arguments with their positions. From the output we see that the executable's name is at position 0, and the real arguments start from position 1.
You can use the arguments as args[1], args[2] and so on.

Here is an example program that adds all the command-line arguments to a string builder:

See *19B.2_clargs_string_builder.jai*:
```c++
#import "Basic";
#import "String";

main :: () {
    args := get_command_line_arguments();

    builder : String_Builder;
    init_string_builder(*builder);

    if args.count > 1 {
        append(*builder, args[1]);
        for index: 2..args.count - 1 {
            append(*builder, " ");
            append(*builder, args[index]);
        }
    }

    append(*builder, "\n");
    print(builder_to_string(*builder));
}

/* Start program as: '19B.exe 42 "hello" 3.14'
42 hello 3.14
*/
```

Module _Command_Line_ has more sophisticated functionality for processing options on the command-line.