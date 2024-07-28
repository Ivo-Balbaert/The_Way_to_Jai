# 37 Testing.

Software needs automated testing. From videos we now that Jon Blow has an automatic testing system in place, for example to test the Sokoban game.
Unfortunately until now, this didn't make its way into a Test module in the standard library.

## 37.1 Basic testing
Assert can be used to test if a variable or condition is true. If not, the program aborts with a "Assertion Failed" message and a stack trace.  
We use:
* `assert` during runtime (see § 6.1.3 and § 20.1.2)
  After testing, assert statements can be left in code without incurring a compiling or performance penalty, if you import the Basic module as:  
  `#import "Basic"()(ENABLE_ASSERT=false);`
* `#assert` during compile-time (see § 20.2.1)  
Both forms of assert can used together.

## 37.2 Testing design in Jai
A common way is to make separate procedures with the assertion functions. The procedures are then tagged with notes like `@Test` or `@TestProcedure`.
During project building, a metaprogram plugin gathers all these procedures into an array, and runs them one by one. This is probably also the way the internal testing in Jai itself works.  

This is exactly what is done in the code below, written by Jai developer Sl3dge. The procedure `get_test_procedures` called in line (1) after every `.TYPECHECKED` message gathers all test procedures in a dynamic array `all_tests`.  
After the message `.TYPECHECKED_ALL_WE_CAN`, in procedure `get_test_call` a build string is made to execute every test procedure (in line (3)) while compiling.

## 37.3 A unit testing module: Stubborn
A [unit testing module](https://github.com/rluba/stubborn) was written by Raphael Luba.