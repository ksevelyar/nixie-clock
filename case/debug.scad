include <mixin.scad>

$fn = 64;

module board() {
  translate([4, 4, 0]) color("#b1a531") leg(board_leg_height);
  translate([board_width - 4, 4, 0]) color("#b1a531") leg(board_leg_height);
  translate([board_width - 4, board_length - 4, 0]) color("#b1a531") leg(board_leg_height);
  translate([4, board_length - 4, 0]) color("#b1a531") leg(board_leg_height);
}

module leg(leg_height) {
  difference() {
    color("#b1a531") cylinder(h=leg_height, d=6.24, $fn=32);
    cylinder(h=leg_height + 1, d=3.12, $fn=32);
  }
}

module tube() {
  translate([board_width / 2, 0, -1]) color("#d6a731")
      cylinder(h=45, d=tube_diameter, $fn=32);

  translate([board_width / 2 + 11.7, 0, -1]) color("#d6a731")
      cylinder(h=45, d=m3, $fn=32);

  translate([board_width / 2 - 11.7, 0, -1]) color("#d6a731")
      cylinder(h=45, d=m3, $fn=32);
}

module type_c_cutout() {
  hull() {
    translate(
      [-5, enclosure_length / 2 + 2.9, board_leg_height]
    )
      rotate([0, 90, 0]) cylinder(h=10, d=3.7, $fn=64);
    translate(
      [-5, enclosure_length / 2 - 2.9, board_leg_height]
    )
      rotate([0, 90, 0]) cylinder(h=10, d=3.7, $fn=64);
  }
}

module test() {
  enclosure_height = 4;
  enclosure_leg_height = 8;

  difference() {
    color("#2f2270") rounded_box(
        [
          30,
          30,
          enclosure_height + wall,
        ],
        r=4
      );
    translate([wall, wall, wall]) rounded_box(
        [30 - wall * 2, 30 - wall * 2, enclosure_height * 2], r=4
      );
  }
  enclosure_width = 30 - wall * 2;
  enclosure_length = 30 - wall * 2;

  translate([wall, wall, 0.1]) {
    translate([3, 3, 0]) color("#b1a531") leg(enclosure_leg_height);
    translate([enclosure_width - 3, 3, 0]) color("#b1a531") leg(enclosure_leg_height);
    translate([enclosure_width - 3, enclosure_length - 3, 0]) color("#b1a531") leg(enclosure_leg_height);
    translate([3, enclosure_length - 3, 0]) color("#b1a531") leg(enclosure_leg_height);
  }
}
test();
