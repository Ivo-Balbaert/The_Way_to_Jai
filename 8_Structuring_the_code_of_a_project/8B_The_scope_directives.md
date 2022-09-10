8B – The #scope directives

§ 7 talked about scope of definitions, and in § 8 we saw how files and modules are loaded and imported. Jai cleans up the mess of header-files and namespaces in C/C++  

## 8B.1 The #scope_file and #scope_export directives
Declarations of a source file are exported into application scope. If you want some definitions to only be visible in the file itself (in _file_scope_), place these behind the **#scope_file;** directive, like this inside a `file1.jai`:  

```
#scope_file;

tango :: "File Scope (in file1)";
```

So it is advisable to place these declarations after all exported definitions. If you do want to change from file scope again to application (exported) scope, you can do this by writing:  
```
#scope_export;
```
followed by the declarations that should be in application scope.

## 8B.2 Scope in a module
Each module has its own scope that is completely sealed off: it cannot see the application scope of your project, and it cannot see other modules.
If you want to have some definitions only visible within the module, use the `#scope_module;` directive before these definitions.

## 8B.3 An example of using the #scope directives
See _8.2_file_and_global_scopes.jai_ (this is the howto 151_file_and_global_scopes example):  

```c++
#import "Basic";

#load "file_alpha.jai";
#load "file_beta.jai";

whiskey :: "Application Scope (from the main file).";
tango   :: "Application Scope (from the main file).";

file_and_application_scope :: () {
    print("From the main file:\n");
    print("Whiskey: %\n", whiskey);
    print("Tango:   %\n", tango);
    print("Foxtrot: %\n", foxtrot);  
    print("\n");

    print("From file alpha:\n");
    file_and_application_scope_in_file_alpha();
    print("\n");
    
    print("From file beta:\n");
    file_and_application_scope_in_file_beta();
    print("\n");
}

main :: () {
    file_and_application_scope();
}
```

_file_alpha.jai_:
```c++
file_and_application_scope_in_file_alpha :: () {
    print("Whiskey: %\n", whiskey);
    print("Tango:   %\n", tango);
    print("Foxtrot: %\n", foxtrot);
}

foxtrot :: "Application Scope (from file alpha).";

#scope_file;
tango :: "File Scope        (in file alpha)";
foxtrot :: "File Scope        (from file alpha).";
```

_file_beta.jai_:
```c++
file_and_application_scope_in_file_beta :: () {
    print("Whiskey: %\n", whiskey);
    print("Tango:   %\n", tango);
    print("Foxtrot: %\n", foxtrot);
}

#scope_file;
tango   :: "File Scope        (in file beta)";
```

Compiling `8.2_file_and_global_scopes.jai` and running the executable gives as output:  

```
From the main file:
Whiskey: Application Scope (from the main file).
Tango:   Application Scope (from the main file).
Foxtrot: Application Scope (from file alpha).

From file alpha:
Whiskey: Application Scope (from the main file).
Tango:   File Scope        (in file alpha)
Foxtrot: File Scope      (from file alpha).

From file beta:
Whiskey: Application Scope (from the main file).
Tango:   File Scope        (in file beta)
Foxtrot: Application Scope (from file alpha).
```