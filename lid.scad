board_length = 100;
board_width = 60;
height = 2;
tube_diameter = 25;

regulator_length = 25;
regulator_width = 30;

wall = 1;

module leg(leg_height = 8) {
    color("#b1a531") cylinder(h = leg_height + 1, d = 3.1, $fn = 32);
}

module tube() {
  translate([ board_width / 2, 0, -1 ]) color("#d6a731") cylinder(h = 45, d = 16, $fn = 32);

  translate([ board_width / 2 + 11.5, 0, -1 ]) color("#d6a731") cylinder(h = 45, d = 3, $fn = 32);

  translate([ board_width / 2 - 11.5, 0, -1 ]) color("#d6a731") cylinder(h = 45, d = 3, $fn = 32);
}

module tubes() {
  k = 10;
  translate([ 0, enclosure_length / k * 1.7 ]) tube();
  translate([ 0, enclosure_length / k * 3.6]) tube();

  translate([ 0, enclosure_length / k * 6.4 ]) tube();
  translate([ 0, enclosure_length / k * 8.3 ]) tube();
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

  translate([ wall, wall, -3 ]) {
    translate([ 3, 3, 0 ]) color("#b1a531") leg(enclosure_leg_height);
    translate([ enclosure_width - 3, 3, 0 ]) color("#b1a531")
        leg(enclosure_leg_height);
    translate([ enclosure_width - 3, enclosure_length - 3, 0 ])
        color("#b1a531") leg(enclosure_leg_height);
    translate([ 3, enclosure_length - 3, 0 ]) color("#b1a531")
        leg(enclosure_leg_height);
  }

  tubes();
  }

}

enclosure();

