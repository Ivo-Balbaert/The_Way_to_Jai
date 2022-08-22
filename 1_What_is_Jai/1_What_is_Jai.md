# Chapter 1 – What is Jai?

## 1.1 Some context and history.

Jai is a programming language developed by Jonathan Blow, who is well-known as a game designer and developer.  His best known games are Braid (2008) and The Witness (2016), both written in C++.

Out of frustration with using C++ for game-development, Blow started working on a new game programming language called **Jai** in late September 2014.  Later his team at Thekla Inc. joined in its development.

Around January 2020, a closed beta program started in which a small but slowly growing number of people got access to a binary distribution of the compiler. At end 2021, there were about 100 beta users, and that amount doubled in May 2022. This small community has already produced lots of interesting Jai libraries and apps.
 
Eventually, the aim is to open-source the language coinciding with the launch of the first commercial Sokoban-like game written in Jai.

## 1.2 What type of language is Jai?

Blow described his new language as a better and modern day C, and also as C++ done right. Its primary focus is *game programming*, but it is also suited for *systems programming* like C/C++, D or Rust. Jai is lower level than Java or C#, and it is not an object-oriented language.

Jai is an **ahead of time (AOT) compiled** language, with strong *meta-programming and compile-time code execution* support. Moreover it allows you to fine-tune execution optimizations.
 
It was designed with these goals in mind:

    • A simple, consistent syntax and a lot of expressive power leading to an increase
     in developer’s productivity and joy and fun in programming.
    • A very high-speed compiler, to make the developer cycle more productive and enjoyable.
    • Excellent performance, on par with C++, or even C.
    • Safety in execution and useful compiler error-messages, to reduce the need for debugging.
    
To realize these goals, Jai for example has no garbage collection (GC) and no exception handling mechanism like Java or C#.

Why is Jai ground-breaking? Jai is so important because it is an effort to build a modern systems programming language from the ground up by a very gifted and experienced developer. With his knowledge of all C/C++ shortcomings, he rethought every one of these problems to give them an easier to use, more elegant or more performant solution. In this way Jai really is _a better and modern day C_, and also a _C++ done right_.

Don’t worry if some concepts are not yet clear! We will experience these characteristics first hand as we grow more and more acquainted with Jai in the coming chapters. 