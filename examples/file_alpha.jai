file_and_application_scope_in_file_alpha :: () {
    print("Whiskey: %\n", whiskey);
    print("Tango:   %\n", tango);
    print("Foxtrot: %\n", foxtrot);
}

foxtrot :: "Application Scope (from file alpha).";

#scope_file;
tango :: "File Scope        (in file alpha)";
foxtrot :: "File Scope        (from file alpha).";