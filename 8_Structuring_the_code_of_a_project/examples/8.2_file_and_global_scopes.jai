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

/*
From the main file:
Whiskey: Application Scope (from the main file).
Tango:   Application Scope (from the main file).
Foxtrot: Application Scope (from file alpha).

From file alpha:
Whiskey: Application Scope (from the main file).
Tango:   File Scope        (in file alpha)
Foxtrot: File Scope        (from file alpha).

From file beta:
Whiskey: Application Scope (from the main file).
Tango:   File Scope        (in file beta)
Foxtrot: Application Scope (from file alpha).
*/


