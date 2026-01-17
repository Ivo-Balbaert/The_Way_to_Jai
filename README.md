# The Way to Jai
A lightweight way to discover and learn the Jai programming language. All programs work with the latest version of the Jai compiler.

This is a work in progress. It grew out of my personal Jai notes from the Jai videos and other Jai primers that emerged over time.
If you find mistakes, ambiguities, things that are not clear, please create an issue.

The text is backed by some 300 complete working Jai examples and growing. They are all tested at each new version of the Jai compiler, so this text and code will never get outdated.

Many thanks to Daniel Tan for setting up the [Jai-Community](https://jai.community/) and the [Jai Wiki](https://github.com/Jai-Community/Jai-Community-Library/wiki).
Also thanks to mehlian, seneca, ramin-asadi-2021 and Jakub Arnold(@darthdeus) for their remarks and contributions.

[Text content adapted and code (up and including § 6B) tested to compile/run with Jai version beta 0.2.024, built on 31 December 2025]

_Table of Contents_

   [0 -  Preface](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/00A_Preface.md)  
   [1 -  What is Jai?](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/01A_What_is_Jai.md)   
   [2 -  Setting up a Jai development environment](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/02A_Setting_up_a_Jai_Development_Environment.md)  
   [3 - Compiling and running your first program](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/03A_Compiling_and_running_your_first_program.md)  
   [4 - More info about the compiler](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/04A_More_info_about_the_compiler.md)  
   [5 - Constants, variables, types and operations](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/05A_Constants_variables_types_and_operations.md)  
   [6 - Bool and number types](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/06A_bool_and_number_types.md)  
   [7 - Scope of variables](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/07A_Scope_of_Variables.md)  
   [8 - Modules - Structuring the code of a project](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/08A_Modules_-_Structuring_the_code_of_a_project.md)      
   [9 - More about types](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/09A_More_about_types.md)  
   [10 - What are pointers?](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/10A_What_are_pointers.md)  
   [11 - Memory allocations](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/11A_Allocating_and_freeing_memory.md)  
   [12 - Basics of structs](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/12A_Basics_of_structs.md)    
   [13 - Unions and enums](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/13A_Unions_and_enums.md)     
   [14 - Branching with if else](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/14A_Branching_with_if_else.md)  
   [15 - Looping with while and for](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/15A_Looping_with_while_and_for.md)     
   [16 - Types in depth](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/16A_Types_in_depth.md)    
   [17 - Basics of procedures](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/17A_Basics_of_procedures.md)  
   [18 - Arrays](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/18A_Arrays.md)  
   [19 - Working with strings](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/19A_Working_with_Strings.md)  
   [20 - Debugging](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/20A_Debugging.md)    
   [21 - Memory Allocators and Temporary Storage](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/21A_Memory_Allocators_and_Temporary_Storage.md)  
   [22 - Polymorphic procedures](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/22A_Polymorphic_procedures.md)  
   [23 - Polymorphic arrays and structs](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/23A_Polymorphic_arrays_and_structs.md)  
   [24 - Operator overloading](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/24A_Operator_Overloading.md)  
   [25 - Context](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/25A_Context.md)  
   [26 - Metaprogramming](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/26A_Metaprogramming.md)  
   [26B - Macros](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/26B_Macros.md)   
   [26C - Applications of Metaprogramming](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/26C_Applications_of_Metaprogramming.md)        
   [27 - Working with files](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/27A_Working_with_Files.md)       
   [28 - Inline assembly](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/28A_Inline_Assembly.md)  
   [29 - Interacting with C](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/29A_Interacting_with_C.md)    
   [30 - Integrated build system](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/30A_Integrated_build_system.md)  
   [30B - Manipulating the build process](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/30B_Manipulating_the_build_process.md)      
   [31 - Working with threads](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/31A_Working_with_threads.md)  
   [32 - Working with processes](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/32A_Working_with_processes.md)  
   [33 - Graphical(GUI) modules](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/33A_Graphical_modules.md)    
   [35 - External modules](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/35A_External_modules.md)      
   [36 - Plugins](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/36A_Plugins.md)    

   [50 - The guessing game](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/50A_The_guessing_game.md)      
   [51 - The game of life](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/51A_The_Game_of_Life.md)   
   [52 - The pong game](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/52A_The_Pong_game.md)  

   [65 - Applications written in Jai](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/65A_Applications_written_in_Jai.md)  

     
 
