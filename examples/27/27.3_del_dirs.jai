#import "Basic";
#import "File";
#import "File_Utilities";

HELP :: "Usage: % [to-be-deleted_directory] [start_directory]\nStart directory will be working directory if not set.\n";

main :: () {
    context.allocator = temp;
    args := get_command_line_arguments(); 
    if args.count <= 1 || args.count > 3 {
        print(HELP, args[0]);
        exit(1);
    }
    if args.count == 3 {
        set_working_directory(args[2]);
        print("Setting working directory to %\n",args[2]);
    }
    
    you_are_here := get_working_directory();   /// (1)
    folder_to_delete := args[1];
    print("Working directory: %\nRemoving directories named '%'...\n", you_are_here, folder_to_delete);
    
    delete_proc :: (using info: *File_Visit_Info, folder_to_delete : string) {
        if short_name == folder_to_delete {
            success := delete_directory(full_name);
            if !success {
                print("We failed to delete directory %!\nIt was simply too powerful... ;____;\n", full_name);
                exit(-1);
            }
            descend_into_directory = false;
        }
    }
    complete := visit_files(you_are_here, true, folder_to_delete, delete_proc, visit_files = false, visit_directories = true);
    
    if !complete {
        print("There was an error while traversing the directory tree! Oh no!\n");
        exit(-2);
    } else {
        print("Removed all directories named '%' from %!\n", folder_to_delete, you_are_here);
    }
}
