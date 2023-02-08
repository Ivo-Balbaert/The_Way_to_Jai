# 27 Working with Files

Manipulation of files is a common requirement for every type of program. Jai has a _File_ module which takes care of that, so we have to import it in code that needs this functionality (see line (1) in code below). There are also the following modules: _File_Utilities_, _File_Async_  and _File_Watcher_  
Because of the OS differences, there is often a Windows variant and a Unix variant of the File procedures.

Here are some examples of the most common operations:

## 27.1 Basic file operations
See *27.1_working_with_files.jai*:
```c++
#import "Basic";
#import "File";               // (1)

TESTFILE :: "assets/example.txt";

BLOCK_OF_TEXT :: #string DONE
The quick
   brown
fox
 jumps
over the
 lazy dog.
DONE

main :: () {
    make_directory_if_it_does_not_exist("assets");  // (2)
    // delete_directory("assets");

    // if file_exists(TESTFILE) {          // (3)
    //     assert(false, message="'%' in assets directory already exists.", TESTFILE);
    //     return;
    // }

    if write_entire_file(TESTFILE, BLOCK_OF_TEXT)   print("Filewrite success!\n"); // (4)
    else print("Error while writing file!\n");  
    // => Filewrite success!

    // data1 :=  read_entire_file(TESTFILE);            // (5)
    // data1, success :=  read_entire_file(TESTFILE);            
    // if !success   return; 
    text, success := read_entire_file(TESTFILE);
    // assert(success, "Error. Cannot read file.\n" );   // (5B)
    if success {
        print("File successfully read.\n");
    } else {
        print("Error. Cannot read file.\n");
        exit(-1);
    }
    print("Contents of TESTFILE:\n\"%\"\n", text);

    file, success2 :=  file_open(TESTFILE, for_writing=true, keep_existing_content=true); // (6)
    if !success2 {
        print("Could not open file % for writing.\n", TESTFILE);
        return;
    }

    advance :=  file_length(file);    // (7)
    print("Length file is %\n", file_length(file));  // => Length file is 50
    file_set_position(file, advance); // (7B)

    success =  file_write(*file, "\nHello, \nSailor!\n"); // (8)
    if !success {
        print("Could not write to file %\n", TESTFILE);
        return;
    }

    file_close(*file); // (9)

    file, success =  file_open(TESTFILE);  // (10)
    if !success {
        print("Could not open file % for writing.\n", TESTFILE);
        return;
    }
    defer file_close(*file);  // (10B)

    length :=  file_length(file);
    buffer := cast(*u8) alloc(length);

    success =  file_read(file, buffer, length);  // (11)
    if !success {
        print("Could not read from %.\n", TESTFILE);
        return;
    }

    data2: string;           // (12)
    data2.data = buffer;
    data2.count = length;

    print("Contents is: %\n", data2);
    free(buffer);
}

/* After the end of the program the contents is:
Contents of TESTFILE:
"The quick
   brown
fox
 jumps
over the
 lazy dog.

Hello, 
Sailor!

"
*/
```

If you need to create a folder from code, do it as in line (2). Similarly, you have delete_directory.  
To test whether a file already exists, use `file_exists` as in line (3).  
Use `write_entire_file` (see line (4)) to write a string to a file, creating the file when it does not exist). This proc can also take a `*builder`, where `builder` is a String Builder.  
`read_entire_file` (line (5)) reads the contents of a file and returns it as a string. The filename can also be stored in a variable instead of a constant.   
Whenever a proc returns a bool variable indicating the success of the operation, you can test on it like this:
* if success {  }
  else {  }
* if !success return;
* assert(success);

If the file read returns an error, the program outputs a message like:
```
Could not open file "assets/example.txt": code 2, The system cannot find the file specified.
d:/Jai/The_Way_to_Jai/examples/27/27.1_working_with_files.jai:34,5: Assertion failed: 
Error. Cannot read file.

Stack trace:
c:/jai/modules/Preload.jai:350: default_assertion_failed
c:/jai/modules/Basic/module.jai:72: assert
d:/Jai/The_Way_to_Jai/examples/27/27.1_working_with_files.jai:34: main
A breakpoint was hit, but no debugger is attached.
```

The `file_open` operation (line (6)) has the following signature:  
`file_open :: (name: string, for_writing := false, keep_existing_content := false, log_errors := true) -> File, bool`  
It's first return value is a file handle on Windows or a pointer to a file in Unix, of type `File` (defined in windows.jai / unix.jai).  
If we want to add data to the file, we must first know its length, and then advance the cursor to that position in the file: lines (7) and following.

In line (8), we add another string to the file; make sure in line (9) to close the file after this to write to disk.

**use defer to close a file**  
If you open a file read-only, you can use `defer file_close(*file);` as in line (11B) immediately after the success check. 

We then read the entire contents back in line (11).
`file_read` has the following signature:  
`file_read :: (f: File, vdata: *void, bytes_to_read: s64) -> (success: bool, bytes_read: s64)`  
so first we define a `buffer` to read into.
In line (12) we construct a string with the buffer data and then print it out. 

To rename a file, use `file_move`, to remove a file `file_delete`.
Search in module _File_ for other variants of the above procedures.

## 27.2 Deleting sub-folders
The following program provides a way to recursively delete directories with a specific name.

See *27.2_del_dirs.jai*:
```c++
#import "Basic";
#import "File";
#import "File_Utilities";

HELP :: "Usage: % [to-be-deleted_directory] [start_directory]\n
Start directory will be working directory if not set.\n";

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
    
    you_are_here := get_working_directory();   // (1)
    redacted := args[1];
    print("Working directory: %\nRemoving directories named '%'...\n", you_are_here, redacted);
    
    delete_proc :: (using info: *File_Visit_Info, redacted : string) {
        if short_name == redacted {
            success := delete_directory(full_name);
            if !success {
                print("Failed to delete directory %!\n", full_name);
                exit(-1);
            }
            descend_into_directory = false;
        }
    }
    complete := visit_files(you_are_here, true, redacted, delete_proc, visit_files = false, visit_directories = true);
    
    if !complete {
        print("There was an error while traversing the directory tree! Oh no!\n");
        exit(-2);
    } else {
        print("Removed all directories named '%' from %!\n", redacted, you_are_here);
    }
}
```

The `File_Visit_Info` struct as well as the `visit_files` proc are defined in module *File_Utilities*. In line (1) we get the current folder we are in with `get_working_directory()`.
`delete_proc` is the procedure that effectively does the delete, `visit_files` takes this proc as 4th argument.  

Here are some invocations of the program and their output:  
```
D:\Jai\testing>deldirs
Usage: deldirs [to-be-deleted_directory] [start_directory]
Start directory will be working directory if not set.

D:\Jai\testing>deldirs .build
Working directory: D:\Jai\testing
Removing directories named '.build'...
Removed all directories named '.build' from D:\Jai\testing!
```

*File_Utilities* also contains all kinds of procs for working with paths.

Look at jai/examples/beta_key_mailer for more examples on how to work with files.