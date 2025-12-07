board_length = 100;
board_width = 60;
height = 2;
tube_diameter = 25;

regulator_length = 25;
regulator_width = 30;

wall = 1;

enclosure_width = board_width + 0.5;
enclosure_length = 162;
enclosure_leg_height = 13 + 2 + wall;
enclosure_height = enclosure_leg_height;

regulator_leg_height = 13 - 3;
board_leg_height = 13;

$fn = 64;

module board() {
  // FIXME legs distances
  // validate with 60*100 cube
  // color("#4f7270") cube([board_width, board_length, height]);

  translate([4, 4, 0]) color("#b1a531") leg(board_leg_height);
  translate([board_width - 4, 4, 0]) color("#b1a531") leg(board_leg_height);
  translate([board_width - 4, board_length - 4, 0]) color("#b1a531") leg(board_leg_height);
  translate([4, board_length - 4, 0]) color("#b1a531") leg(board_leg_height);
}

module leg(leg_height) {
  difference() {
    color("#b1a531") cylinder(h=leg_height, d=7, $fn=32);
    cylinder(h=leg_height + 1, d=3.2, $fn=32);
  }
}

module tube() {
  translate([board_width / 2, 0, -1]) color("#d6a731")
      cylinder(h=45, d=16.4, $fn=32);

  translate([board_width / 2 + 11.7, 0, -1]) color("#d6a731")
      cylinder(h=45, d=3.12, $fn=32);

  translate([board_width / 2 - 11.7, 0, -1]) color("#d6a731")
      cylinder(h=45, d=3.12, $fn=32);
}

module tubes() {
  k = 10;
  translate([0, 120 / k * 1.3]) tube();
  translate([0, 120 / k * 3.4]) tube();

  translate([0, 120 / k * 6.6]) tube();
  translate([0, 120 / k * 8.7]) tube();
}

module rounded_box(size = [10, 10, 5], r = 3) {
  translate([size[0] / 2, size[1] / 2, 0]) {
    linear_extrude(height=size[2]) {
      minkowski() {
        square([size[0] - 2 * r, size[1] - 2 * r], center=true);
        circle(r=r);
      }
    }
  }
}

module power_cutout() {
  hull() {
    translate(
      [-5, enclosure_length / 2 + 4.4 - 3.8 / 2, board_leg_height]
    )
      rotate([0, 90, 0]) cylinder(h=10, d=4, $fn=64);
    translate(
      [-5, enclosure_length / 2 - 4.4 + 3.8 / 2, board_leg_height]
    )
      rotate([0, 90, 0]) cylinder(h=10, d=4, $fn=64);
  }
}

module enclosure() {
  // FIXME: relative position
  translate([wall + 20, wall, 0.1]) cube([2, enclosure_length, 3.6]);
  translate([wall + 38, wall, 0.1]) cube([2, enclosure_length, 3.6]);

  difference() {
    color("#2f2270") rounded_box(
        [
          enclosure_width + wall * 2,
          enclosure_length + wall * 2,
          enclosure_height + wall,
        ],
        r=4
      );
    translate([board_width, 0, 0]) power_cutout();

    translate([wall, wall, wall]) rounded_box(
        [board_width + 0.5, enclosure_length, enclosure_height * 2], r=4
      );

    translate([wall, (enclosure_length - 120) / 2, 0]) tubes();
  }

  translate([wall, wall, 0.1]) {
    translate([3, 3, 0]) color("#b1a531") leg(enclosure_leg_height);
    translate([enclosure_width - 3, 3, 0]) color("#b1a531") leg(enclosure_leg_height);
    translate([enclosure_width - 3, enclosure_length - 3, 0]) color("#b1a531") leg(enclosure_leg_height);
    translate([3, enclosure_length - 3, 0]) color("#b1a531") leg(enclosure_leg_height);
  }
}

enclosure();

translate([wall, enclosure_length / 2 - board_length / 2 + wall, 0.1]) {
  board();
}

module regulator() {
  wall = 1;
  difference() {
    cube([regulator_width + 2, regulator_length + 2, regulator_leg_height]);
    translate([-1, wall - 1, -1])
      cube([regulator_width + 4, regulator_length + 1, 20]);
  }
  translate([wall + regulator_width - 3, regulator_length - 3 + wall, -0.1])
    color("#b1a531") leg(5);
}

translate([1 + enclosure_width / 2 - regulator_width / 2, wall, wall]) regulator();
