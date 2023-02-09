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

    if write_entire_file(TESTFILE, BLOCK_OF_TEXT)   print("Filewrite success!\n");
    else print("Error while writing file!\n");  // (4)
    // => Filewrite success!

    // text :=  read_entire_file(TESTFILE);            // (5)
    // text, success :=  read_entire_file(TESTFILE);            
    // if !success {
    //     return;
    // }
    text, success := read_entire_file(TESTFILE);    // (5B)
    assert(success, "Error. Cannot read file.\n" );
    if success {
        print("File successfully read.\n");
    } else {
        print("Error. Cannot open file.\n");
        exit(-1);
    }
    print("Contents of TESTFILE:\n\"%\"\n", text);

    file, success2 :=  file_open(TESTFILE, for_writing=true, keep_existing_content=true); // (6)
    if !success2 {
        print("Could not open file % for writing.\n", TESTFILE);
        return;
    }

    advance :=  file_length(file);  // (7)
    print("Length file is %\n", file_length(file));  // => Length file is 50
    file_set_position(file, advance);

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
    defer file_close(*file);

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