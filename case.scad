board_length = 100;
board_width = 60;
height = 2;
tube_diameter = 25;

regulator_length = 26.2;
regulator_width = 31.2;

wall = 1;

enclosure_width = board_width;
enclosure_length = enclosure_width * 2;
enclosure_height = board_width;
enclosure_leg_height = 20;
regulator_leg_height = 2;
board_leg_height = regulator_leg_height + 13;

module leg(leg_height = 8) {
  difference() {
    cylinder(h = leg_height, d = 5.5, $fn = 32);

    color("#b1a531") cylinder(h = leg_height + 1, d = 3.1, $fn = 32);
  }
}

module board() {
  // color("#4f7270") cube([ board_width, board_length, height ]);

  translate([ 3, 3, 0 ]) color("#b1a531") leg(board_leg_height);
  translate([ board_width - 3, 3, 0 ]) color("#b1a531") leg(board_leg_height);
  translate([ board_width - 3, board_length - 3, 0 ]) color("#b1a531")
      leg(board_leg_height);
  translate([ 3, board_length - 3, 0 ]) color("#b1a531") leg(board_leg_height);
}

module tube() {
  translate([ board_width / 2, 0, height ]) color("#d6a731")
      cylinder(h = 45, d = tube_diameter, $fn = 32);
}

module tubes() {
  k = 10;
  translate([ 0, enclosure_length / k * 1.3 ]) tube();
  translate([ 0, enclosure_length / k * 3.5 ]) tube();

  translate([ 0, enclosure_length / k * 6.5 ]) tube();
  translate([ 0, enclosure_length / k * 8.7 ]) tube();
}

module regulator() {
  difference() {
    cube([ regulator_width + wall * 2, regulator_length + wall * 2, 4.5 ]);
    translate([ wall, wall, -1 ])
        cube([ regulator_width, regulator_length, 20 ]);
  }
  translate([ wall + regulator_width - 3, regulator_length - 3 + wall, -0.1 ])
      color("#b1a531") leg(regulator_leg_height);
}

module rounded_box(size = [ 10, 10, 5 ], r = 3) {
  translate([ size[0] / 2, size[1] / 2, 0 ]) {
    linear_extrude(height = size[2]) {
      minkowski() {
        square([ size[0] - 2 * r, size[1] - 2 * r ], center = true);
        circle(r = r);
      }
    }
  }
}

module enclosure() {
  difference() {
    color("#2f2270") rounded_box(
        [ board_width + wall * 2, enclosure_length + wall * 2, wall ]);
    // translate([ wall, wall, wall ]) color("#2f2270")
    //     rounded_box([ board_width, enclosure_length, enclosure_height ]);
  }

  translate([ wall, wall, 0 ]) {
    translate([ 3, 3, 0 ]) color("#b1a531") leg(enclosure_leg_height);
    translate([ enclosure_width - 3, 3, 0 ]) color("#b1a531")
        leg(enclosure_leg_height);
    translate([ enclosure_width - 3, enclosure_length - 3, 0 ]) color("#b1a531")
        leg(enclosure_leg_height);
    translate([ 3, enclosure_length - 3, 0 ]) color("#b1a531")
        leg(enclosure_leg_height);
  }
}

enclosure();

translate([ (board_width - regulator_width) / 2, wall * 2, wall ]) regulator();

// tubes();
translate([ wall, enclosure_length / 2 - board_length / 2 + wall, 0.1 ]) {
  board();
}
