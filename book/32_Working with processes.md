# 32 Working with processes

Here we discuss module _Process_, which deals with starting, ending, writing to, and reading from processes. Obviously you need a `#import "Process";` if you want to use this functionality.


## 32.1 Running a process within a program
The procedure that starts a process from within a program is named `run_command`. Arguments are passed to the function through the args parameter.

```
run_command :: (args: .. string, working_directory := "", capture_and_return_output := false,  
print_captured_output := false, timeout_ms := -1, arg_quoting := Process_Argument_Quoting.QUOTE_IF_NEEDED) ->  
(process_result: Process_Result, output_string := "", error_string := "", timeout_reached := false);
```

A complicated signature, but except the 1st one, all arguments have default values and need not be supplied, and you don't need to capture the return values.

We have used this procedure before as   
`run_command(target_options.output_executable_name);`  
where only the 1st ..string argument is supplied.
( see § 30.7 in program `30.6_build_and_run.jai` / § 30.8 in program `30.7_build_and_run2.jai` / §31.2 in program `31.2_build_threads.jai`) 

## 32.2 Creating a process
This is done with the procedure:  
```
create_process :: (process: *Process, args: .. string, working_directory := "",  
capture_and_return_output := false, arg_quoting := Process_Argument_Quoting.QUOTE_IF_NEEDED, kill_process_if_parent_exits := true)  
-> success: bool;
```

Because of the returned bool value, you can use it as follows:
```c++
if create_process(process1) {
    // further processing
} else {
    print("Error creating process, exiting...");
    exit(-1);
}
```

## 32.3 Writing to a process
This is done with the following procedure, which writes an array of bytes to a process:

```
write_to_process :: (process: *Process, data: [] u8) -> success: bool, bytes_written: int;
```

## 32.4 Reading from a process
This is done with the following procedure, which reads an array of bytes from a process:
  
```
read_from_process :: (process: *Process, output_buffer: [] u8, error_buffer: [] u8, timeout_ms := -1)
-> success: bool, output_bytes: int, error_bytes: int;
```