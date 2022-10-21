#import "Basic";

main :: () {
    str := sprint("%","The quick brown fox");
    for i: 0..str.count/2-1 {
        Swap(*str[i], *str[str.count-1-i]);
    }
    print("str reversed is %\n", str); 
    // => str reversed is xof nworb kciuq ehT 
}