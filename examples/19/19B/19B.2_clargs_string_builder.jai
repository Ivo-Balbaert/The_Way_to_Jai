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