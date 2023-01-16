#import "Basic";

hello :: (name: string, phrase: string) {
  print("My name is %.  %\n", name, phrase);
};

main :: () {
    hello("fred", "booya"); 
    hello("booya", "fred"); 
    hello(phrase = "booya", name = "fred"); 
    hello("fred", phrase = "booya"); 
    hello(name = "fred", "booya");
    hello("fred", 3.14);  
}

/*
My name is fred.  booya
My name is booya.  fred  /* compiler can't help us. */
My name is fred.  booya
My name is fred.  booya
My name is fred.  booya
/* Error: Type mismatch. Type wanted: string; type given: float32. */
*/