board_length = 100;
board_width = 60;
height = 2;
tube_diameter = 25;

regulator_length = 25;
regulator_width = 30;

wall = 1;

enclosure_width = board_width;
enclosure_length = enclosure_width * 2;
enclosure_leg_height = 20;
enclosure_height = enclosure_leg_height;

regulator_leg_height = 2;
board_leg_height = regulator_leg_height + 13;

$fn = 64;

module leg(leg_height = 8) {
  color("#b1a531") cylinder(h = leg_height + 1, d = 3.1, $fn = 32);
}

module tube() {
  translate([ board_width / 2, 0, -1 ]) color("#d6a731")
      cylinder(h = 45, d = 16.4, $fn = 32);

  translate([ board_width / 2 + 11.7, 0, -1 ]) color("#d6a731")
      cylinder(h = 45, d = 3.12, $fn = 32);

  translate([ board_width / 2 - 11.7, 0, -1 ]) color("#d6a731")
      cylinder(h = 45, d = 3.12, $fn = 32);
}

module tubes() {
  k = 10;
  translate([ 0, enclosure_length / k * 1.3 ]) tube();
  translate([ 0, enclosure_length / k * 3.4 ]) tube();

  translate([ 0, enclosure_length / k * 6.6 ]) tube();
  translate([ 0, enclosure_length / k * 8.7 ]) tube();
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

module power_cutout() {
  hull() {
    translate(
        [ -5, enclosure_length / 2 + 4.4 - 3.8 / 2, board_leg_height ])
        rotate([ 0, 90, 0 ]) cylinder(h = 10, d = 3.8, $fn = 64);
    translate(
        [ -5, enclosure_length / 2 - 4.4 + 3.8 / 2, board_leg_height ])
        rotate([ 0, 90, 0 ]) cylinder(h = 10, d = 3.8, $fn = 64);
  }
}

module enclosure() {
  difference() {
    color("#2f2270") rounded_box(
        [
          board_width + wall * 2, enclosure_length + wall * 2,
          enclosure_height + wall * 2
        ],
        r = 4);
    translate([ 0, 0, 0 ]) power_cutout();

    translate([ wall, wall, wall ]) rounded_box(
        [ board_width, enclosure_length, enclosure_height + 2 ], r = 4);

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
