# **Chapter 1 – What is Jai?**

**1.1 What type of language is Jai?**

**1.1.1 Goals and priorities**

Blow described his new language as a _better and modern day C_, and also as _C++ done right_. Its primary focus is high-performance **game programming** , but it is also suited for **general-purpose** and **low-level systems programming,** like C/C++, D or Rust. Jai is lower-level than Java or C#, and it is not an object-oriented language like these with classes and inheritance. Jai also allows programmers to get as low-level as they desire.

Jai is an **ahead of time (AOT) compiled, imperative, static** and **strongly-typed** language, with strong **meta-programming and compile-time code execution support**. Moreover it allows you to fine-tune execution optimizations.

Here are the _priorities_ of Jai in this order:

**developer productivity (quality of life, simplicity, expressive power and joy)**

**\> performance**

**\> safety**

Jai was designed with these _goals_ in mind:

1. A simple, clean, consistent syntax and a lot of expressive power.
2. A very high-speed compiler.
3. Excellent performance, on par with C++, or similar to C, or even faster.
4. Safety in execution and useful and pleasant compiler error-messages.

To realize these goals, Jai has the following _properties_:

1. Putting _data at the center_ of the design (see ??).

2. The compiler is written in C++. There are no header files, and no forward declarations. Also builds can be controlled from within the language, the process is the same for all platforms (see ??); make-files or any other external build-systems are not needed. Jai has extensive compile time meta programming functionality, even to the point of being able to run programs at compile time (see ??). It also has compile time polymorphism (see ??), and a powerful macro system ( see ??).

The goal is to compile 1M lines of code in \< 1s (from scratch, without delta builds). The official compilation speed of the compiler is 250,000 lines of code per second using the x64 backend, according to the CHANGELOG of beta 0.0.045 (using Sokoban as a benchmark).

3. Explicit control over optimization and performance characteristics: things like inlining (see ??) and LLVM optimizations (see ??). Jai also effectively uses pointers and it has an implicit context system to switch memory allocation schemes.

4. Bounds checking (see ??), and initialization (see ??).

In order to increase performance, Jai has NO:

- garbage collection (GC)
- automatic memory management
- exceptions (too complex, weighs too heavy on performance)
- RAII (Resource Acquisition Is Initialization), like: a struct has to have a copy constructor, move constructor, iterator, and so on, which leads to high friction

All this _results_ in:

1. An increase in developer's productivity (20 – 50 %) and joy and fun in programming, making the developer cycle more enjoyable: editing code, compiling, testing is very streamlined, fluid and low-friction, easy to refactor.

2. No problems with different build tools on different OS's.

3. Happy developers/users of Jai programs.

4. Reducing the need for debugging.  

Jai is specifically meant to be a game programming language, where a game is defined as a program which:  
- Runs in real-time.
- Is interactive.
- Renders some sort of 3D scene.
- Is targeted at modern gaming hardware like PCs and consoles.  
So Jai should be useable and be able to replace C++ for projects on the AAA scale. 

Keep in mind that the language is _designed for good programmers; it_ has no training wheels for beginners. For example: developers have to take care of manual memory management, handling memory is all important.

**1.1.2 Jai tries to be a better C/C++**

Jai is meant as a _C/C++ replacement_, providing a simpler and consistent syntax.

C++ is from the 1980's, and it has accumulated so much concepts which complicate things and sometimes work against each other. Language concepts should be _orthogonal_, not sometimes conflicting with each other.

Jai also has macros, these are not preprocessor macros like C/C++, but they are more like Lisp macros.

C code and Jai code can live side by side; C and Jai interoperate seamlessly. Jai code can be built on top of existing C libraries. This makes it possible to gradually migrate a C project or application to Jai.

Jai is like C, also an _imperative, statically and strongly typed_ language, but with a variety of modern language features that C lacks, and with another skin and techniques that are more suitable for game development, where performance, stability and productivity are of the utmost importance.

**1.2 Comparisons with other languages**

Jai obviously belongs to the C-family of languages, together with C++, Objective C, Java, C#, and so on. For example: it uses semicolons ; to mark the end of a code-line, and encloses a block of code lines within curly braces { }. However, it clearly attempts to provide a simpler and more enjoyable syntax than C/C++.

See also: [Overview · Jai-Community/Jai-Community-Library Wiki (github.com)](https://github.com/Jai-Community/Jai-Community-Library/wiki/Overview#comparison-with-other-languages)  
for comparisons with C, C++, Java, Go, Rust, Functional Languages (Lisp, Haskell, Scheme,), Scripting Languages (PHP, JavaScript, Ruby, Python, etc.)  
With C3: [Comparisons with other languages - C3 Documentation (c3-lang.org)](http://www.c3-lang.org/compare/)

**1.3 Some steps in Jai's history**

The video talk that started Jai development was called: _Ideas about a new programming language for games_ and was posted on Sep 17 2014 **(**[https://www.youtube.com/watch?v=TH9VCN6UkyQ&index=1&list=PLmV5I2fxaiCKfxMBrNsU1kgKJXD3PkyxO](https://www.youtube.com/watch?v=TH9VCN6UkyQ&index=1&list=PLmV5I2fxaiCKfxMBrNsU1kgKJXD3PkyxO)).  
In Apr 2017, Blow showed a small demo of the language at Reboot Development 2017, ["Making Game Programming Less Terrible"](https://www.youtube.com/watch?v=gWv_vUgbmug)(https://www.youtube.com/watch?v=gWv\_vUgbmug).  
In Jan 2018 a status update video was published ([https://www.youtube.com/watch?v=rFaBs-CUX5w](https://www.youtube.com/watch?v=rFaBs-CUX5w)).  
In Mar 2018, Jai was given to a few close associates of Blow.  
Blow fired the compiler team in early 2019 because they didn't understand Jon's intentions with Jai (they wanted to open it up earlier).

A _closed beta program_ (the compiler/docs were send to a limited number of people) started Dec 21 2019: this was the first beta with 10 people. Apr 2020: 20 people.    
This reached version 0.0.30 on Oct 25 2020. Nov 2020: 40 people. Beta 37 was issued on Jan 1 2021, and had 51 participants.    
On Dec 24 2021, beta 100 was shipped, with around 100 beta users.  
A new way of _transitive invites_ to grow the beta user group was introduced.  
On May 2022, the beta reached v 0.1.025 and extended to around 200 users.  
On August 2022, the beta reached v 0.1.036 and extended to around 250 users.

In the 2014-2018 period, Jonathan Blow frequently did educational video overviews of Jai's development ((a series of talks/demos about the language here: [Jonathan Blow - YouTube](https://www.youtube.com/user/jblow888/videos)), and got feedback from people through Q & A sessions and mail. In the closed-beta period, Blow switched to videos of working on the compiler and the game and got user feedback mostly through mail.

Jai's robustness and usability is extensively tested through the Sokoban game which is being developed in Jai (some 250 K LOC Lines Of Code), but also through the many projects undertaken by the beta users.

The business-model is based on the commercial release of games written in Jai by the Thekla company, starting with the Sokoban game.  

Jai will be released gradually, as in this order:  
- a closed beta release (from Dec 2019 until ??)
- an open binary distribution release
- an open-source release on GitHub of the compiler code, a game-engine and (part of) the Sokoban game, but with no open-source contributions by pull requests in the beginning period
- a full open-source release  
The Sokoban game will be commercially released.

### As to licensing:

- The compiler is currently proprietary, and the compiler should not be distributed to anyone outside of beta testers
- When the compiler source code is released, it will have a permissive software license (e.g. BSD or MIT license)
- Licensing to prevent `embrace, extend, extinguish `tactics of larger companies will be added.

The name "Jai" means victory in Hindi, Indian languages, or also "Just Another Idea". The Jai language is also often called The Language by Jon Blow, indicating that the name could be changed.

**1.4 Specific Jai features**

These are some unique, essential, killer features of Jai:

- Reflection (introspection) and run-time type information
- Low-level memory management tools for memory allocation and freeing
- Explicit control over optimization and performance characteristics
- Full compile-time code execution
- Integrated build process

**1.5 Some wrong ideas in software development**

1- Implementation details don't matter, like managing memory, how data structures look like, …

2- Scripting languages, interpreted-ness (Perl, Python, Ruby, …), managed-ness (Java, .NET) make a language more powerful, and because computers will be so fast, all will be fine!  
All this leads to conflation of slowness (heavy run-times) and lack of control.

3- More layers of software are good:  
but: more layers are harder to understand, to debug, to install, to use.   
They have more badly-fitting couplings, take longer to compile, etc.  

4- You want a complicated, slow IDE to get between you and your programming (Visual Studio, Eclipse, Xcode, …) – the same goes for: a big complicated "ecosystem" of tools, package manager, and so on.

5- You should use RAII / ARC, GC etc.  
Programs are 100x slower, harder to understand, …


**1.6 Jai community and communication channels**

Jonathan Blow is CEO of a game-developing company called Thekla ([The Witness](www.thekla.com)](http://www.thekla.com/)).  
Blow receives and sometimes answers discussions and issues about Jai on [_language@thekla.com_](mailto:language@thekla.com).  

Reddit discussions on the language happen on:  [Jai Reddit](https://www.reddit.com/r/Jai/)  

There is a Jai Community wiki at:    
[Home · Jai-Community/Jai-Community-Library Wiki (github.com)](https://github.com/Jai-Community/Jai-Community-Library/wiki)   and [Jai Community - A place to learn about Jai programming language](https://jai.community/)

A Discord channel called SB (Secret Beta): [https://discord.gg/wB52e2ND](https://discord.gg/wB52e2ND)

**1.7 Jai's popularity**

Blow's videos about the design and making of Jai are very popular: They get viewing numbers ranging from a few K to 55 K, even 229 K for the very first video.

**Reddit / Discord / Twitter JB / Youtube JB / Jai Community Library Wiki / SB**  
(members) ( followers) (abonnees) / (watch - stars)  
2022 Feb 25: **1.4 K /** / 122.4 K / **62.3 K / 40 - 129**  
2022 May 21: **1.4 K / 199 /** 122.3 K / **62.3 K / 42 - 151**  
2022 Jul 4: **1.5 K / 236 /** 122.6 K / **63.7 K / 46 – 177 / 45**  
2022 Jul 27: **1.6 K / 255 /** 123 K / **64.3 K / 48 – 186 / 49**  