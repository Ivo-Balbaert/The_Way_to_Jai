# 36 Plugins.

## 36.1 What are plugins and how to use them?
In § 2B we described the following command-line option:  
`-plug name` or `-plugin name`  
This imports module 'name' into the meta-program and uses it as a plugin.

A plugin is a module called by the metaprogram to implement a certain functionality. So all plugins are to be used by the metaprogram.

The *Default_MetaProgram* (see § 30.1) scans for -plug arguments, then initializes and imports those plugins (it uses the module *Metaprogram_Plugins*).

**How to use a plugin?**
In the following line we invoke a plugin `TestRunner`:  
jai main.jai -plug TestRunner`   



## 36.2 Plugins in the standard distribution

* the *Check* module is a plugin that performs error checking, such as checking `print()` has the correct number of user arguments.




