# Preface - Goals of this Jai tutorial.

This tutorial is meant to help people hit the ground running when The Language (Jai) is released. This text is based upon notes taken while watching Jonathan Blows videos starting from Sep 2014, and from primers and tutorials that appeared in the course of the years.

It is called **"The Way to Jai"**. While this will not be so useful at this moment when the compiler is still in a closed beta phase (Jan 2026), at some point in time it will be. We'll make sure this text and the accompanying code stays up to date.  

The game _Order of the Sinking Star_ will be released by Thekla Inc. in 2026. Jonathan Blow, who is the main designer/developer of this game, also created the Jai language, in which this game was written! This 'tour de force' was 12 years in the making. Jonathan Blow also affirmed that the Jai game-engine and the latest Jai binary will be released not much longer after the game itself. This will finally enable every interested developer to start working in and with this language!  

The [Jai Community Library Wiki](https://github.com/Jai-Community/Jai-Community-Library/wiki) does an excellent job in providing many details about the Jai language, and a lot of useful code snippets. However the wiki intentionally addresses more experienced developers.

This tutorial on the other hand is intended for more novice programmers who want to learn this fascinating and promising language. We will try to explain from the ground up how Jai is elegantly constructed to attain its goals, and how it works internally, with an emphasis on insight and best practices.  
In that sense it resembles the _how_to_ tutorials from Jonathan Blow which are distributed with the compiler. But here we'll generally use simpler code examples, and not get into  much edge-case details.  
At the same time, parallel guides with more in-depth information will also be provided, but they are not needed to learn basic Jai programming.

We carefully wanted to avoid introducing a subject before all concepts needed to understand that subject where discussed. This for example resulted in strings being discussed as late as in § 19, because a string is defined as a struct, and is in fact also an array view ([] u8). Arrays are explored in § 18, after structs, because they are also defined as a struct. So structs, being more fundamental, were discussed in § 12. It turns out, conceptually at least, that structs are the most fundamental type in Jai.  
Probably you will want to know more about how to work with strings before reaching § 19; it's not a problem to look up what you need.  

To find specific material, you could start at the front page of the GitHub repo, which lists all Chapter links. But there is also a Table of Contents pdf document, which also lists all subsections, which makes it easier to find something in particular. To find the most detail, use a "Finding in Files" tool to search in the .md documents, like the find tool (Edit/ Find in Files) in VSCode. We also paid a lot of attention to cross-referencing (both forward an backward) in the text. The appendices might also be useful to search for a specific keyword or directive.

The material is divided into numbered chapters **1_**, **2_**, and so on; **2B_** , **2C_** is the numbering for the more detailed info, in this case after chapter 2. Each chapter has an accompanying folder _examples/N_  (where N is the chapter's number) with working code examples, and in some cases also a subfolder _exercises/N_, containing solutions to questions / exercises in the text. Code examples are also numbered like **2.1_**, **2.2_**, and so on, and each contains a complete working program, showing only one newly discussed item each. We'll often leave off the n.m_ prefix for readability in the text.
(Note that compiling a 2.1_program.jai file will result in a 2.exe or 2 executable file - which is easy for testing ;-))
This numbering scheme results in a great number of small examples, but it simplifies and enhances the learning experience.

Within code listings, important code lines will be indicated with **// (1)**, **// (2)** and so on, after the code. These numbers are referred to in the text discussion. Any output of a program will be shown in the text as well as in the snippet itself, after a **// =>** in the code line itself or on the following line if needed. If the output is too big, it will be shown within /*  */ after the last code line.
Code examples are always completely shown in the text (unless otherwise stated), so you don't need to switch between files.
Keep the examples close by when you are going through the text, to see the entire context and for quick compiling and testing.

Here are some conventions we'll use in the text:

```c++
Code will be shown in a grey background.
```

like this:
```c++
#import "Basic";

main :: () {
    assert(5 == 5.0);
}
```

We'll use _italics_ for folder names, module names, other packages, and also for the output of running programs.  
We'll use **bold** for important concepts, new keywords and directives.

Sometimes comparisons will be made with other programming languages, to better engage experienced developers, but these will be outside the main text.

We'll take great care in introducing every new concept step by step, and we will try to maintain a strict rule of not using anything in code examples which hasn't been discussed yet. This will also result in many examples like: "this thing can also be used in this way, or together with this other thing", but again we believe that this eases the learning curve.
If we absolutely need to mention something which has not been explained yet, we'll make sure to add a forward reference to where it is discussed.

Also for those of you who are beginning their programming journey, do speak out code internally when reading a program, and explain to yourself all that happens in the code. 
Later on this becomes automatic, but in the beginning stages it is very helpful to not be overwhelmed by code which seems more complex at first.

Nobody else than Jonathan Blow himself can express it in a better way, so here is an excerpt from how_to/200_memory_management (a must-read, together with 999_temperance):
```
This language is designed for you, the individual. We expect you to enjoy
that magical part of programming where the computer is made to do new and
interesting functionality; we don't make you fill out income tax forms
all day. Many software products are made by teams, but we see these teams
as collections of individuals, each of whom has their own strengths and
weaknesses, each of whom has their own personal style; we don't view
a software project as a statistical combination of generic code typed
by gray stone people who do not differ from each other.

We have designed this language so that its basic functionality is 
fast by default and simple by default. This leaves a lot of room
for you to build your own personal style on what is here. If you do it the
C++ way, where things start out slow because you have smart-pointered
std::string all over the place calling copy constructors that then
get maybe elided because you use std::move all the time, this is something
that is slow by default and has to get very complicated in the pursuit
of eventually being fast. We don't have to do that! Let's just make
better choices to begin with!
```

I want to express my sincere admiration to **Jonathan Blow** for creating this superb language. Welcome to the wonderful world of developing in Jai!


**This book is dedicated to the memory of Jef Inghelbrecht, a close friend who passed away too soon.
He was also a great software developer, adhering to conservative and noble principles of software development.
That's why I am very sure he would have been a big fan of Jai.**
