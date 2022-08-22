# Chapter 2 - Setting up a Jai Development Environment.

## 2.1 Opening up the Jai compiler toolkit

Until this moment (Aug 17 2022, version 1.0.036), Jai is still closed beta .
The group members can download the compiler as a zip file (size +- 220 Mb).
Unzipping this file shows the following contents:

![Jai folder structure](https://github.com/Ivo-Balbaert/The_Way_to_Jai/tree/main/images/jai_folder.png)

Here is what these folders contain:

- _bin_: this contains the Jai compiler executables (jai.exe for Windows, jai-linux for Linux) and the LLVM linker lld (see section # ??).
- *how_to*: this contains some examples with explanatory comments.
- _examples_: this contains some more advanced example programs.
- _modules_: this contains Jai’s standard library, we'll discuss this in more detail here: ??
We'll discuss the purpose of _editor_support_ and _redist_ later (see ?? and § 2.2.4).

## 2.2 Setting up the Jai compiler

### 2.2.1 Copying the compiler to its destination folder

You can use the extracted folder structure as-is, no installation is needed!
Unpack the zip file in a temporary folder using:

    - on Windows: RIGHT-CLICK the file and select Extract All... 
    - on Linux (or WSL2 in Windows): use tar -xvf in a terminal

Now copy the _jai_ subfolder in its entirety to its destination (let's call this the _Jai root folder_), as follows:

    - on Windows: for example on the C-drive to c:\jai 
    - on Linux (or WSL2 in Windows): for example to /usr/local/bin/jai or /opt/jai or $HOME/jai 
    (assuming $HOME is /home/your_username)
        Rename jai-linux to jai:  mv jai-linux jai
        You also have to make jai and the link program executable with the following commands 
        (perhaps using sudo):
          chmod +x jai
          chmod +x lld-linux

Now open a terminal in your Jai root folder, and type the command:
    - on Windows: `jai -version`
    - on Linux (or WSL2 in Windows): `./jai -version`
, it will show the following output (for your actual version):

_Version: beta 0.1.036, built on 17 August 2022._

But of course you'll want to be able to use Jai from any directory, let's see how this can be done. 

### 2.2.2 Making the jai command system-wide available

To achieve this, do the following:

    - on Windows: add the path to where jai.exe lives (for example c:\jai\bin) to the PATH system 
    environment variable; here is how to do that:
        • open Explorer, right-click This PC, Properties, then the System settings window appears
        • click Advanced system settings, then button Environment variables
        • choose System Variables, Path, click button New, add c:\jai
        • click OK on all open windows 

    - on Linux (or WSL2 in Windows): make a symbolic link like ln -s /path/to/jai/bin/jai /usr/bin/jai
        (for example: ln -s $HOME/jai/bin/jai /usr/bin/jai)

        Or add this line to your /etc/profile or $HOME/.profile:
        export PATH="$HOME/jai/bin/:$PATH"

        After creating the link, you can run Jai on Linux also with: `jai`

Test this out by moving in a terminal to another folder than the Jai root folder and typing in the command: `jai -version`. You should see the same output as in the previous section.
    
### 2.2.3 Updating Jai

Remove the current _jai_ folder (make sure that you have backed up any files you have added or changed in there) or rename it to _jai_old_.
Then just drop the most recent _jai_ folder as the new Jai root folder, and you're done!

### 2.2.4 Prerequisite for Windows 

> (from the distribution README.txt) In order to compile on Windows, you need to have installed on your machine at least one Windows SDK (which is how we link to stuff like kernel32, user32, etc) and one Visual C++
> Redistributable (which has various C-related libraries). If you
> compile C++ programs on your computer, you probably already have this.
> If you don't, run vs_BuildTools.exe, and select the option to install C++ build tools.
> (It is the box in the upper-left corner).

### 2.2.5 Windows as development platform

Windows is the primary development platform for Jai, because most games are written to run on Windows first. Jonathan Blow also uses Visual Studio as IDE for the compiler.


## 2.3 Editor help for coding Jai
Writing a program's source code is easier when you have some support such as syntax highlighting in your code editor. Support exists for vim, Sublime Text 3 and VSCode, see: [Tooling Ecosystem](https://github.com/Jai-Community/Jai-Community-Library/wiki/References#tooling-ecosystem). 

### 2.3.1 Overview

1) **vim**: [Jai.vim](github.com/rluba/jai.vim): Vim syntax highlighting for the Jai programming language.  			
     
2) **Emacs**:  [Jai-mode.el](https://github.com/krig/jai-mode/blob/master/jai-mode.el)

3) **Sublime Text 3**: [RobinWragg/JaiTools](https://github.com/RobinWragg/JaiTools)
 Syntax highlighting, autocompletion, and Goto Symbol/Anything for the Jai language 

4) **Visual Studio Code**: (see § 2.2.2)
Iain King: [The Language - Visual Studio Marketplace - v0.0.85](https://marketplace.visualstudio.com/items?itemName=onelivesleft.the-language) – 

5) **Visual Studio**: [Jai Revolution](https://inductive.no/jai/jai-revolution/) 
   plugin for Visual Studio 2013 / 2015 from Inductive AS, published 2015
	Syntax highlighting (cannot be installed in VS 2017).

6) **Language server**:	[Pyromuffin/jai-lsp](https://github.com/Pyromuffin/jai-lsp)

At this time I recommend the VSCode plugin, because it probably has the most functionality.
### 2.3.2  Using the Visual Studio Code plugin

Visual Studio Code (VSCode) is one of the most popular programmer’s editors today and can be installed from: [VSCode](https://code.visualstudio.com/), it offers lots of basic functionality (code folding, brace pairing, numbering lines, and so on) and a myriad number of extensions.
There is a VS Code plugin for Jai named _The Language_, which provides basic IDE functionality: [The Language](https://marketplace.visualstudio.com/items?itemName=onelivesleft.the-language).

VSCode is very helpful for editing you source code. Compiling is usually done from the command-line (cmd on Windows or a terminal in Linux), but you can do it also from within VSCode by opening up a New Terminal.

### 2.3.3 How to edit, build and run a Jai program in VS-Code through CodeRunner

Install the [CodeRunner](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)  extension.
Then in File, Preferences, Settings:
  Edit Jai settings by Searching for:  Jai
    If necessary, set the Path to Jai executable.
    Search for:  Run code configuration:
		Custom command: `jai $fileName -exe a.exe & a`
	
This is the same as editing in settings.json:
		 `"code-runner.executorMap": { "jai": "jai $fileName -exe a.exe && a",` 
			...
	
Now you can RIGHT-click on the code window and select the 1st command: `Run code`, and it will execute this command, which will compile and then run the generated executable.
We'll show an image of this in chapter 3.

### 2.3.4 The compiler command

Now open up a terminal and type `jai` and ENTER. You get the following message:

_You need to provide an argument telling the compiler what to compile!  Sorry._

`jai` is a compiler, so it needs at a minimum the path to some source code (file) to compile! 
In the next chapter; we're going to compile our first Jai program, and learn some more about the compiler.

If you're curious about which other command-line options exist for the compiler, see section 2B.

