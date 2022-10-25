# 26 - Metaprogramming

A 'metaprogram' is a piece of code that alters (or 'programs') an existing program (another piece of code).
In Jai, this takes place at compile-time.

In order to do metaprogramming, full type-information is needed. Jai has that available at compile-time (see§ 5.1.4, § 9,),  but also retains static type information for every structure available at runtime.
In § 13.6 we discussed some useful reflection methods for enums.

Using type info to metaprogram is also called _reflection_ or _introspection_ in other languages.

We already talked about running code at compile time as early as § 3.2.4. Jai provides full compile-time code execution, meaning that all Jai code can also be executed while compiling.