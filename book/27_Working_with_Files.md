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

    // text :=  read_entire_file(TESTFILE);            // (5)
    // text, success :=  read_entire_file(TESTFILE);            
    // if !success   return; 
    text, success := read_entire_file(TESTFILE);
    // assert(success);
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
        print("Could not open file % for reading.\n", TESTFILE);
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

If you need to create a folder from code, do it as in line (2). Similarly, you have delete_directory to remove a folder.  
To test whether a file already exists, use `file_exists` as in line (3).  
Use `write_entire_file` (see line (4)) to write a string to a file, creating the file when it does not exist.   
This proc can also take a `*builder`, where `builder` is a String Builder.  
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
Its first return value is a file handle on Windows or a pointer to a file in Unix, of type `File` (defined in windows.jai / unix.jai).  
If we want to add data to the file, we must first know its length, and then advance the cursor to that position in the file: lines (7) and following.

In line (8), we add another string to the file; make sure in line (9) to close the file after this write to disk.

**Use defer to close a file**  
If you open a file, you can use `defer file_close(*file);` as in line (10B) immediately after the success check. 

We then read the entire contents back in line (11).
`file_read` has the following signature:  
`file_read :: (f: File, vdata: *void, bytes_to_read: s64) -> (success: bool, bytes_read: s64)`  
so first we define a `buffer` to read into.
In line (12) we construct a string with the buffer data and then print it out. 

To rename a file, use `file_move`, to remove a file `file_delete`.  
Search in module _File_ for other variants of the above procedures.

## 27.2 Working with CSV files
In assets/people.csv we have a CSV text file, which contains 10 person records. Each record is a line on its own, separated by a newline from the previous and following records. Every record contains data for the following fields in this order:  
_Index,User Id,First Name,Last Name,Sex,Email,Phone,Date of birth,Job Title_  
Usually this is the header line in the CSV file.
These data fields are separated by comma's (,) on each line, for example here are the first 3 records:  
```
Index,User Id,First Name,Last Name,Sex,Email,Phone,Date of birth,Job Title
1,88F7B33d2bcf9f5,Shelby,Terrell,Male,elijah57@example.net,001-084-906-7849x73518,1945-10-26,Games developer
2,f90cD3E76f1A9b9,Phillip,Summers,Female,bethany14@example.com,214.112.6044x4913,1910-03-24,Phytotherapist
3,DbeAb8CcdfeFC2c,Kristine,Travis,Male,bthompson@example.com,277.609.7938,1992-07-02,Homeopath
```
(To limit the output we have only 10 person records, but that number doesn't matter, the code stays the same.)

Our program will read in the CSV file, and process each person record. It will extract the fields and put these in a Person struct variable. 

See *27.2_working_with_csv.jai*:
```c++
#import "Basic";
#import "String";
#import "File";               

CSVFILE :: "assets/people.csv";

Person :: struct {
    index: string;
    user_id: string;
    first_name: string;
    last_name: string;
    sex: string;
    email: string;
    phone: string;
    birth_date: string;
    job_title: string;
}

SOA :: struct(T: Type, count: int) {    
  #insert -> string {                   
    builder: String_Builder;           
    defer free_buffers(*builder);
    t_info := type_info(T);             
    for fields: t_info.members {        
      print_to_builder(*builder, "  %1: [%2] type_of(T.%1);\n", fields.name, count);  
    }
    result := builder_to_string(*builder);  
    return result;
  }
}

main :: () {
    data, success := read_entire_file(CSVFILE);    
    if !success {
        print("Error. Cannot open file %.\n", CSVFILE);
        exit(-1);
    }

    print("File % successfully read.\n", CSVFILE);

    lines: [..] string;
    _lines := split(data, "\n");
    for _lines {
        line := trim(it);
        array_add(*lines, line);
    }
    defer array_free(lines);

    persons: [..] Person;   // array of structs
    defer array_free(persons);

    for lines {
        if it_index == 0    continue;  // header line 
        pers_info := split(it, ",");
        p := New(Person);
        defer free(p);
        p.index = pers_info[0];
        p.user_id = pers_info[1];
        p.first_name = pers_info[2];
        p.last_name = pers_info[3];
        p.sex = pers_info[4];
        p.email = pers_info[5];
        p.phone = pers_info[6];
        p.birth_date = pers_info[7];
        p.job_title = pers_info[8];
        array_add(*persons, p);
    }

    print("The persons array of structs is: \n");
    for persons     print("%\n", it);
    // => see in /* */ after program

    // turning into SOA:
    soa_persons: SOA(Person, 10);       
    // transferring data from persons (AOS) to soa_persons (SOA):
    for 0..persons.count - 1 {
        soa_persons.index[it] = persons[it].index;
        soa_persons.user_id[it] = persons[it].user_id;
        soa_persons.first_name[it] = persons[it].first_name;
        soa_persons.last_name[it] = persons[it].last_name;
        soa_persons.sex[it] = persons[it].sex;
        soa_persons.email[it] = persons[it].email;
        soa_persons.phone[it] = persons[it].phone;
        soa_persons.birth_date[it] = persons[it].birth_date;
        soa_persons.job_title[it] = persons[it].job_title;
    }
    print("\n");
    print("The soa_persons struct of arrays is: \n");
     // => see in /* */ after program

    for i: 0..soa_persons.count-1 {    
        print("Person[%]: first_name= %, last_name= %, job_title= %\n", 
        soa_persons.index[i], soa_persons.first_name[i], soa_persons.last_name[i], soa_persons.job_title[i]);
    }  
}

/*
The persons array of structs is:
{index = "1"; user_id = "88F7B33d2bcf9f5"; first_name = "Shelby"; last_name = "Terrell"; sex = "Male"; email = "elijah57@example.net"; phone = "001-084-906-7849x73518"; birth_date = "1945-10-26"; job_title = "Games devel"; }
{index = "2"; user_id = "f90cD3E76f1A9b9"; first_name = "Phillip"; last_name = "Summers"; sex = "Female"; email = "bethany14@example.com"; phone = "214.112.6044x4913"; birth_date = "1910-03-24"; job_title = "Phytotherapi"; }
{index = "3"; user_id = "DbeAb8CcdfeFC2c"; first_name = "Kristine"; last_name = "Travis"; sex = "Male"; email "; }thompson@example.com"; phone = "277.609.7938"; birth_date = "1992-07-02"; job_title = "Homeopath
{index = "4"; user_id = "A31Bee3c201ef58"; first_name = "Yesenia"; last_name = "Martinez"; sex = "Male"; email = "kaitlinkaiser@example.com"; phone = "584.094.6111"; birth_date = "2017-08-03"; job_title = "Market researc"; }
{index = "5"; user_id = "1bA7A3dc874da3c"; first_name = "Lori"; last_name = "Todd"; sex = "Male"; email = "buchananmanuel@example.net"; phone = "689-207-3558x7233"; birth_date = "1938-12-01"; job_title = "Veterinary surg"; }
{index = "6"; user_id = "bfDD7CDEF5D865B"; first_name = "Erin"; last_name = "Day"; sex = "Male"; email = "tconner@example.org"; phone = "001-171-649-9856x5553"; birth_date = "2015-10-28"; job_title = "Waste management of"; }r
{index = "7"; user_id = "bE9EEf34cB72AF7"; first_name = "Katherine"; last_name = "Buck"; sex = "Female"; email = "conniecowan@example.com"; phone = "+1-773-151-6685x49162"; birth_date = "1989-01-22"; job_title = "Intelli"; }e analyst
{index = "8"; user_id = "2EFC6A4e77FaEaC"; first_name = "Ricardo"; last_name = "Hinton"; sex = "Male"; email = "wyattbishop@example.com"; phone = "001-447-699-7998x88612"; birth_date = "1924-03-26"; job_title = "Hydrogeo"; }st
{index = "9"; user_id = "baDcC4DeefD8dEB"; first_name = "Dave"; last_name = "Farrell"; sex = "Male"; email = ""; }ann@example.net"; phone = "603-428-2429x27392"; birth_date = "2018-10-06"; job_title = "Lawyer
{index = "10"; user_id = "8e4FB470FE19bF0"; first_name = "Isaiah"; last_name = "Downs"; sex = "Male"; email = "virginiaterrell@example.org"; phone = "+1-511-372-1544x8206"; birth_date = "1964-09-20"; job_title = ""Engineer"; }

The soa_persons struct of arrays is:
Person[1]: first_name= Shelby, last_name= Terrell, job_title= Games developer
Person[2]: first_name= Phillip, last_name= Summers, job_title= Phytotherapist
Person[3]: first_name= Kristine, last_name= Travis, job_title= Homeopath
Person[4]: first_name= Yesenia, last_name= Martinez, job_title= Market researcher
Person[5]: first_name= Lori, last_name= Todd, job_title= Veterinary surgeon
Person[6]: first_name= Erin, last_name= Day, job_title= Waste management officer
Person[7]: first_name= Katherine, last_name= Buck, job_title= Intelligence analyst
Person[8]: first_name= Ricardo, last_name= Hinton, job_title= Hydrogeologist
Person[9]: first_name= Dave, last_name= Farrell, job_title= Lawyer
Person[10]: first_name= Isaiah, last_name= Downs, job_title= "Engineer
*/
```

Then we add each of these Person structs to a dynamic array persons, so that we now have an array of structs.

We turn this into an SOA (struct of arrays), by using the technique explained in § 26.10.2

## 27.3 Deleting sub-folders
The following program provides a way to recursively delete directories with a specific name.

See *27.3_del_dirs.jai*:
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
    folder_to_delete := args[1];
    print("Working directory: %\nRemoving directories named '%'...\n", you_are_here, folder_to_delete);
    
    delete_proc :: (using info: *File_Visit_Info, folder_to_delete : string) {
        if short_name == folder_to_delete {
            success := delete_directory(full_name);
            if !success {
                print("Failed to delete directory %!\n", full_name);
                exit(-1);
            }
            descend_into_directory = false;
        }
    }
    complete := visit_files(you_are_here, true, folder_to_delete, delete_proc, visit_files = false, 
    visit_directories = true);
    
    if !complete {
        print("There was an error while traversing the directory tree! Oh no!\n");
        exit(-2);
    } else {
        print("Removed all directories named '%' from %!\n", folder_to_delete, you_are_here);
    }
}
```

The `File_Visit_Info` struct as well as the `visit_files` proc are defined in module *File_Utilities*.  
In line (1) we get the current folder with `get_working_directory()`.
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

Look also at jai/examples/beta_key_mailer for more examples on how to work with files.