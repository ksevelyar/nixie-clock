board_length = 100;
board_width = 60;
height = 2;
tube_diameter = 20;

regulator_length = 30;
regulator_width = 25;

module board() {
  color("#4f7270") cube([ board_width, board_length, height ]);

  translate([ 3, 3 ]) color("#b1a531") cylinder(h = 6, d = 3, $fn = 32);
  translate([ board_width - 3, 3 ]) color("#b1a531")
      cylinder(h = 6, d = 3, $fn = 32);
  translate([ board_width - 3, board_length - 3 ]) color("#b1a531")
      cylinder(h = 6, d = 3, $fn = 32);
  translate([ 3, board_length - 3 ]) color("#b1a531")
      cylinder(h = 6, d = 3, $fn = 32);
}

module tube() {
  translate([ board_width / 2, 0, height ]) color("#d6a731")
      cylinder(h = 45, d = tube_diameter, $fn = 32);
}

module tubes() {
  translate([ 0, 13.5 ]) tube();
  translate([ 0, 36.5 ]) tube();
  translate([ 0, 63.5 ]) tube();
  translate([ 0, 86.5 ]) tube();
}

module regulator() {
  cube([ regulator_width, regulator_length, 5 ]);
  translate([ 3, regulator_length - 3 ]) color("#b1a531")
      cylinder(h = 6, d = 3, $fn = 32);
}

board();
translate([ (board_width - regulator_width) / 2, 10, 0 ]) regulator();
