# 36 Plugins.

## 36.1 What are plugins and how to use them?
In § 2B we described the following command-line option:  
`-plug Name` or `-plugin Name`  
This imports module 'Name' into the meta-program and uses it as a plugin.

A plugin is a module called by the metaprogram to implement a certain functionality. So all plugins are to be used by the metaprogram.

The *Default_MetaProgram* (see § 30.1) scans for `-plug` arguments, then initializes and imports those plugins (it uses the module *Metaprogram_Plugins*).

**How to use a plugin?**  
In the following line we invoke a plugin `TestRunner`:    
`jai main.jai -plug TestRunner`   


## 36.2 How to make your own plugin?
The module *Example_Plugin* was made to show you what is needed. Basically you need to copy the `get_plugin` procedure and adapt it to your needs.

The `Default_MetaProgram` communicates with the plugins it has loaded  through the following code:
```c++
message_loop :: (w: Workspace) {
    while true {
        message := compiler_wait_for_message();
        // Pass the message to all plugins.
        for plugins if it.message it.message(it, message);
        
        if message.kind == .COMPLETE break;
    }
}
```
## 36.3 Plugins in the standard distribution

* The *Check* module is a plugin that performs error checking, such as checking `print()` has the correct number of user arguments.
* The *Polymorph_Report* module is a plugin that gives you a report on how many polymorphs were deduplicated and which call sites resulted in unique polymorphs of a procedure. Use this option to invoke it from the Default Metaprogram:  
`-plug Polymorph_Report`  
* The *Program_Print* module is a plugin that prints types when encountering a TYPE_DEFINITION. Use this option to invoke it from the Default Metaprogram:  
`-plug Program_Print`
* The *IProf* module is a plugin that instruments the main program, as well as imported modules. This means that profiles the program: it gathers info on procedure calls, and can reports this. Use this option to invoke it from the Default Metaprogram:    
`-plug IProf`  
* The *Autorun* module is a plugin that runs your program when it's done compiling. Use this option to invoke it from the Default Metaprogram:    
`-plug Autorun`  
For example: `jai test.jai -plug Autorun` results in:
```  
[Autorun] Running: d:/Jai/testing/test
Hello, Sailor from Jai!
```




