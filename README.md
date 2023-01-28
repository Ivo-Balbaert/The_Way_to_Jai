# The Way to Jai
A lightweight way to discover and learn the Jai programming language. All programs work with the latest version of the Jai compiler.

This is a work in progress. It grew out of my personal Jai notes from the Jai videos and other Jai primers that emerged over time.
If you find mistakes, ambiguities, things that are not clear, please create an issue.

The text is backed by more than 200 complete working Jai examples and growing. They are all automatically tested at each new version of the Jai compiler, so this text and code will never get outdated.

Many thanks to Daniel Tan for setting up the [Jai-Community](https://jai.community/) and the [Jai Wiki](https://github.com/Jai-Community/Jai-Community-Library/wiki).
Also thanks to mehlian and Jakub Arnold(@darthdeus) for their remarks and contributions.

[Code tested to compile/run with Jai version beta 0.1.055b, built on Jan 27 2023]

_Table of Contents_

   [0 -  Preface](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/0_Preface.md)  
   [1 -  What is Jai?](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/1_What_is_Jai.md)   
   [2 -  Setting up a Jai development environment](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/2_Setting_up_a_Jai_Development_Environment.md)  
   [3 - Compiling and running your first program](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/3_Compiling_and_running_your_first_program.md)  
   [4 - More info about the compiler](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/4_More_info_about_the_compiler.md)  
   [5 - Constants, variables, types and operations](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/5_Constants%2C%20variables%2C%20types%20and%20operations.md)  
   [6 - Bool and number types](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/6_bool_and_number_types.md)  
   [6B - Times and dates](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/6B_Times_and_dates.md)   
   [7 - Scope of variables](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/7_Scope_of_Variables.md)  
   [8 - Modules - Structuring the code of a project](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/8_Modules_-_Structuring_the_code_of_a_project.md)  
   [8B - The #scope directives](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/8B_The_scope_directives.md)    
   [9 - More about types](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/9_More_about_types.md)  
   [10 - What are pointers?](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/10_What_are_pointers.md)  
   [11 - Memory allocations](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/11_Memory_allocations.md)  
   [12 - Basics of structs](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/12_Basics%20of%20structs.md)    
   [13 - Unions and enums](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/13_Unions%20and%20enums.md)     
   [14 - Branching with if else](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/14_Branching_with_if_else.md)  
   [15 - Looping with while and for](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/15_Looping%20with%20while%20and%20for.md)     
   [16 - Types in depth](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/16_Types%20in%20depth.md)    
   [17 - Basics of procedures](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/17_Basics%20of%20procedures.md)  
   [18 - Arrays](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/18_Arrays.md)  
   [18B - Ordered remove in Arrays](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/18B_Ordered%20remove%20in%20arrays.md)  
   [18C - Copy a struct with memcpy](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/18C_Copying%20a%20struct%20with%20memcpy.md)    
   [19 - Working with strings](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/19_Working_with_Strings.md)  
   [19B - Get command-line arguments](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/19B_Get%20command-line%20arguments.md)
   [19C - Comparing field names of structs](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/19C_Comparing%20field%20names%20of%20structs.md)  
   [20 - Debugging](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/20_Debugging.md)    
   [21 - Memory Allocators and Temporary Storage](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/21_Memory_Allocators_and_Temporary_Storage.md)  
   [22 - Polymorphic procedures](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/22_Polymorphic%20procedures.md)  
   [23 - Polymorphic arrays and structs](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/23_Polymorphic%20arrays_and_structs.md)  
   [23B - A showcase of inheritance](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/23B_A%20showcase%20of%20inheritance%20using%20structs%2C%20as%20and%20polymorphism.md)  
   [24 - Operator overloading](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/24_Operator_Overloading.md)  
   [25 - Context](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/25_Context.md)  
   [26 - Meta-programming and macros](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/26_Metaprogramming%20and%20macros.md)       
   [27 - Working with files](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/27_Working_with_Files.md)       
   [28 - Inline assembly](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/28_Inline_Assembly.md)  
   [29 - Interacting with C](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/29_Interacting%20with%20C.md)    
   [30 - Integrated build system](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/30_Integrated_build_system.md)    
   [31 - Working with threads](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/31_Working%20with%20threads.md)  
   [32 - Working with processes](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/32_Working%20with%20processes.md)  
   [33 - Graphical(GUI) modules](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/33_Graphical%20modules.md)    
   [34 - Other useful modules](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/34_Other_useful_modules.md)  

   [50 - The guessing game](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/50_The%20guessing%20game.md)      
   [51 - The game of life](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/51_The%20Game%20of%20Life.md)    
