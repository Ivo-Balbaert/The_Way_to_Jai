#import "Basic";

report :: ($header: string, $body: string, $footer: string, n: int) {
    #insert header;
    for 1..n {
        #insert body;
    }
    #insert footer;
}

header :: #string DONE
    count := 0;
    print("Start of the report:\n");
DONE

body :: #string DONE
    print("    ... one iteration! Incrementing!\n");
    count += 1;
DONE

footer :: #string DONE
    print("End of the report - count is: %.\n", count);
DONE

main :: () {
    report(header, body, footer, 5);
}

/*
Start of the report:
    ... one iteration! Incrementing!
    ... one iteration! Incrementing!
    ... one iteration! Incrementing!
    ... one iteration! Incrementing!
    ... one iteration! Incrementing!
End of the report - count is: 5.
*/