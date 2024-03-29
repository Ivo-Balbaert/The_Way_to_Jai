# The Way to Jai
A lightweight way to discover and learn the Jai programming language. All programs work with the latest version of the Jai compiler.

This is a work in progress. It grew out of my personal Jai notes from the Jai videos and other Jai primers that emerged over time.
If you find mistakes, ambiguities, things that are not clear, please create an issue.

The text is backed by some 300 complete working Jai examples and growing. They are all tested at each new version of the Jai compiler, so this text and code will never get outdated.

Many thanks to Daniel Tan for setting up the [Jai-Community](https://jai.community/) and the [Jai Wiki](https://github.com/Jai-Community/Jai-Community-Library/wiki).
Also thanks to mehlian, seneca, ramin-asadi-2021 and Jakub Arnold(@darthdeus) for their remarks and contributions.

[Text content adapted and code tested to compile/run with Jai version beta 0.1.072]

_Table of Contents_

   [0 -  Preface](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/0_Preface.md)  
   [1 -  What is Jai?](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/1_What_is_Jai.md)   
   [2 -  Setting up a Jai development environment](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/2_Setting_up_a_Jai_Development_Environment.md)  
   [3 - Compiling and running your first program](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/3_Compiling_and_running_your_first_program.md)  
   [4 - More info about the compiler](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/4_More_info_about_the_compiler.md)  
   [5 - Constants, variables, types and operations](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/5_Constants%2C%20variables%2C%20types%20and%20operations.md)  
   [6 - Bool and number types](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/6_bool_and_number_types.md)  
   [7 - Scope of variables](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/7_Scope_of_Variables.md)  
   [8 - Modules - Structuring the code of a project](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/8_Modules_-_Structuring_the_code_of_a_project.md)      
   [9 - More about types](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/9_More_about_types.md)  
   [10 - What are pointers?](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/10_What_are_pointers.md)  
   [11 - Memory allocations](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/11_Allocating%20and%20freeing%20memory.md)  
   [12 - Basics of structs](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/12_Basics%20of%20structs.md)    
   [13 - Unions and enums](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/13_Unions%20and%20enums.md)     
   [14 - Branching with if else](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/14_Branching_with_if_else.md)  
   [15 - Looping with while and for](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/15_Looping%20with%20while%20and%20for.md)     
   [16 - Types in depth](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/16_Types%20in%20depth.md)    
   [17 - Basics of procedures](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/17_Basics%20of%20procedures.md)  
   [18 - Arrays](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/18_Arrays.md)  
   [19 - Working with strings](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/19_Working_with_Strings.md)  
   [20 - Debugging](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/20_Debugging.md)    
   [21 - Memory Allocators and Temporary Storage](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/21_Memory_Allocators_and_Temporary_Storage.md)  
   [22 - Polymorphic procedures](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/22_Polymorphic%20procedures.md)  
   [23 - Polymorphic arrays and structs](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/23_Polymorphic%20arrays_and_structs.md)  
   [24 - Operator overloading](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/24_Operator_Overloading.md)  
   [25 - Context](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/25_Context.md)  
   [26 - Metaprogramming](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/26_Metaprogramming.md)  
   [26B - Macros](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/26B_Macros.md)   
   [26C - Applications of Metaprogramming](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/26C_Applications%20of%20Metaprogramming.md)        
   [27 - Working with files](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/27_Working_with_Files.md)       
   [28 - Inline assembly](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/28_Inline_Assembly.md)  
   [29 - Interacting with C](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/29_Interacting%20with%20C.md)    
   [30 - Integrated build system](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/30_Integrated_build_system.md)  
   [30B - Manipulating the build process](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/30B_Manipulating%20the%20build%20process.md)      
   [31 - Working with threads](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/31_Working%20with%20threads.md)  
   [32 - Working with processes](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/32_Working%20with%20processes.md)  
   [33 - Graphical(GUI) modules](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/33_Graphical%20modules.md)    
   [35 - External modules](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/35_External_modules.md)      
   [36 - Plugins](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/36_Plugins.md)    

   [50 - The guessing game](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/50_The%20guessing%20game.md)      
   [51 - The game of life](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/51_The%20Game%20of%20Life.md)   
   [52 - The pong game](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/52_The%20Pong%20game.md)  

   [65 - Applications written in Jai](https://github.com/Ivo-Balbaert/The_Way_to_Jai/blob/main/book/65_Applications%20written%20in%20Jai.md)  

     
 
