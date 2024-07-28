# 4B - Options for giving code at the command-line
With `-run arg`, you can start a #run directive that parses and runs 'arg' as code.  
      Example:  `jai -run write_string(\"Hello!\n\")`   
The string Hello! is then shown at the start of the compiler output.

With `-add arg`, you can add the string 'arg' to the target program as code.  
       Example: `jai -add "a := 42" 4.1_hello_sailor.jai`  
Now the variable a is know in the program, and we can print it out with for example:  `print("%", a);`

See *4.1_hello_sailor.jai*
```c++
#import "Basic";

main :: () {
    print("Hello, Sailor from Jai!\n");
    print("a is %\n", a);
}
```

Which produces as output when run:
```
Hello, Sailor from Jai!
a is 42
```

The `-verbose` option gives some extra information about what the meta-program is doing, for example:  
	`jai -run write_string(\"Hello!\n\") -add "a := 42" -verbose 4.1_hello_sailor.jai`  
shows the following at the start of the compiler output:
            
```c++
4.1_hello_sailor.jai
options.output_path = "D:/Jai/The_Way_to_Jai/examples/4/";
options.output_executable_name = "4.1_hello_sailor";
Changing working directory to 'D:/Jai/The_Way_to_Jai/examples/4/'.
Input files: ["D:\Jai\The_Way_to_Jai\examples\4\4.1_hello_sailor.jai"]
Add strings: ["a := 42"]
Run strings: ["write_string("Hello!\n")"]
Plugins:     [2ee_65e8]
Hello!
Running linker: … (abbreviated)_
```