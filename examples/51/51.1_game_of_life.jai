#import "Basic";
#import "Math";

M :: 16;
gol_grid: [M][M] s8;

main :: () {
  // set initial state:
  gol_grid[M/2][M/2] = 1;
  gol_grid[M/2][M/2 - 1] = 1;
  gol_grid[M/2][M/2 + 1] = 1;

  show_gol();    // print initial state:
 
  while true {                 // game event loop
    next_generation();
    show_gol();
    sleep_milliseconds(1000);
  }
}

next_generation :: () {                     
  temp: [M][M] s8 = ---;
  for i: 0..M-1 {
    for j: 0..M-1 {
      count := neighbors_count(i, j);
      if gol_grid[i][j] == 1 {
        if count < 2 || count > 3 then
          temp[i][j] = 0;
        else
          temp[i][j] = 1;
        } else {
          if count == 3
            temp[i][j] = 1;
          else
            temp[i][j] = 0;
        }
    }
  }

  for i: 0..M-1 {               // (6)
    for j: 0..M-1 {
      gol_grid[i][j] = temp[i][j];
    }
  }

  neighbors_count :: (i: int, j: int) -> s8 {
    if (i==0 || j == 0 || i == 15 || j == 15) return 0;
    count: s8 = 0;
    count += gol_grid[i-1][j-1];
    count += gol_grid[i-1][j];
    count += gol_grid[i-1][j+1];

    count += gol_grid[i][j-1];
    count += gol_grid[i][j+1];

    count += gol_grid[i+1][j-1];
    count += gol_grid[i+1][j];
    count += gol_grid[i+1][j+1];
    return count;
  }
}

show_gol :: () {
    for i: 0..M-1 {
        for j: 0..M-1 {
            print("%", gol_grid[i][j]);    
        }
        print("\n");
    }
    print("\n\n\n\n\n");
}


