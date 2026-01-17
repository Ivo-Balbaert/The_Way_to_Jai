#import "Basic";

main :: () {
    start_time := seconds_since_init();
    sleep_milliseconds(100);
    elapsed := seconds_since_init() - start_time;
    print("Sleep 100 ms took % ms\n", elapsed * 1000); 
    // => Sleep 100 ms took 114.5402 ms
   
    // Apollo time:    
    start := current_time_monotonic();              // (3)
    sleep_milliseconds(100);
    end := current_time_monotonic();
    duration :=  end - start; // (3B)
    // duration := operator - (current_time_monotonic(), start); // (3C)
    print("Sleep 100 ms Apollo took %\n",  duration); 
    // =>  {109085200000000, 0}
    print("%\n",  to_float64_seconds(duration) * 1000 ); 
    // This is 109,0852 ms
}