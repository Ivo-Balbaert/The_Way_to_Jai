#import "Basic";

Step_Iterator :: struct {
    min:  int;
    max:  int;
    step: int;
}

step_iterator :: (min: int, max: int, step: int) -> Step_Iterator {
    return .{ min, max, step };
}

for_expansion :: (iterator: Step_Iterator, body: Code, flags: For_Flags) #expand {
    iteration_count := -1;
    for i: iterator.min..iterator.max {
        iteration_count += 1;
        if iteration_count % iterator.step != 0 continue;

        `it       := i;
        `it_index := void;

        #insert body;
    }
}

main :: () {
    for step_iterator(0, 10, 2) {
        print("% - ", it); // => 0 - 2 - 4 - 6 - 8 - 10 - 
    }
}