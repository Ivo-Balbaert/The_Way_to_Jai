#import "Basic";
#import "Random";

main :: () {
    a := current_time_monotonic();              // (1)
    print("%\n", a);
    a = operator-(current_time_monotonic(), a); // (2)
    print("%\n", a);

    r := random_seed(current_time_monotonic().low); // (3)
    print("%\n", r); // => void
}

/*
{155922876271345152, 3}
{313400000000, 0}
void
*/

