board_length = 100;
board_width = 60;
height = 2;
tube_diameter = 25;

regulator_length = 25;
regulator_width = 30;

wall = 1;

module leg(leg_height = 8) {
  difference() {
    cylinder(h = leg_height, d = 5.5, $fn = 32);

    color("#b1a531") cylinder(h = leg_height + 1, d = 3, $fn = 32);
  }
}

module board() {
  // color("#4f7270") cube([ board_width, board_length, height ]);

  translate([ 3, 3, 0 ]) color("#b1a531") leg();
  translate([ board_width - 3, 3, 0 ]) color("#b1a531") leg();
  translate([ board_width - 3, board_length - 3, 0 ]) color("#b1a531") leg();
  translate([ 3, board_length - 3, 0 ]) color("#b1a531") leg();
}

module tube() {
  translate([ board_width / 2, 0, height ]) color("#d6a731")
      cylinder(h = 45, d = tube_diameter, $fn = 32);
}

module tubes() {
  k = 10;
  translate([ 0, enclosure_length / k * 1.3 ]) tube();
  translate([ 0, enclosure_length / k * 3.5]) tube();

  translate([ 0, enclosure_length / k * 6.5 ]) tube();
  translate([ 0, enclosure_length / k * 8.7 ]) tube();
}

module regulator() {
  difference() {
    cube([ regulator_width + wall * 2, regulator_length + wall * 2, 5 ]);
    translate([ wall, wall, -1])
        cube([ regulator_width, regulator_length, 20 ]);
  }
  translate([ wall + regulator_width - 3, regulator_length - 3 + wall, - 0.1]) color("#b1a531") leg(3);
}

enclosure_width = board_width;
enclosure_length = enclosure_width * 2;
enclosure_height = board_width;
enclosure_leg_height = 10;
module enclosure() {
  difference() {
    color("#2f2270")
        cube([ board_width + wall * 2, enclosure_length + wall * 2, 5 ]);
    translate([ wall, wall, wall ]) color("#2f2270")
        cube([ board_width, enclosure_length, enclosure_height ]);
  }

  translate([ wall, wall, 0 ]) {
    translate([ 3, 3, 0 ]) color("#b1a531") leg(enclosure_leg_height);
    translate([ enclosure_width - 3, 3, 0 ]) color("#b1a531")
        leg(enclosure_leg_height);
    translate([ enclosure_width - 3, enclosure_length - 3, 0 ])
        color("#b1a531") leg(enclosure_leg_height);
    translate([ 3, enclosure_length - 3, 0 ]) color("#b1a531")
        leg(enclosure_leg_height);
  }
}

enclosure();

translate([ (board_width - regulator_width) / 2, wall * 2, wall ]) regulator();

//tubes();
translate([ wall, enclosure_length / 2 - board_length / 2, 0.1 ]) {
  board();
}
