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

module tubes() {
  D = socket_diameter;
  r = D / 2;
  corner_r = 4;
  L = enclosure_length - 2 * corner_r;
  gap = (L - 4 * D) / 3;
  pitch = D;
  start = corner_r + gap + r;

  y1 = start;
  y2 = y1 + pitch;
  y3 = y2 + (D + gap);
  y4 = y3 + pitch;

  translate([0, y1]) tube();
  translate([0, y2]) tube();
  translate([0, y3]) tube();
  translate([0, y4]) tube();
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

module enclosure() {
  translate([(enclosure_width + wall * 2) / 2 - tube_diameter / 2 - wall - 0.2, wall, 0.1]) cube([2, enclosure_length, 3.6]);
  translate([(enclosure_width - wall / 2) / 2 + tube_diameter / 2 + wall + 0.2, wall, 0.1]) cube([2, enclosure_length, 3.6]);

  difference() {
    color("#2f2270") rounded_box(
        [enclosure_width + wall * 2, enclosure_length + wall * 2, enclosure_height + lid_height + 0.2],
        r=4
      );
    translate([wall, wall, wall]) rounded_box(
        [enclosure_width, enclosure_length, enclosure_height * 2], r=4
      );

    translate([board_width, wall, 0]) type_c_cutout();

    translate([wall, wall, 0]) tubes();
  }

  translate([wall, wall, 0.1]) {
    translate([3, 3, 0]) color("#b1a531") leg(enclosure_leg_height);
    translate([enclosure_width - 3, 3, 0]) color("#b1a531") leg(enclosure_leg_height);
    translate([enclosure_width - 3, enclosure_length - 3, 0]) color("#b1a531") leg(enclosure_leg_height);
    translate([3, enclosure_length - 3, 0]) color("#b1a531") leg(enclosure_leg_height);
  }
}

module regulator() {
  difference() {

    cube([regulator_width + wall * 2, regulator_length + wall * 2, board_leg_height-wall]);
    translate([-wall, 0, -wall]) cube([regulator_width * 2, regulator_length + wall, 20]);

    translate([(regulator_width - tube_diameter) / 2 + wall - 0.2, 13, -1]) cube([tube_diameter - 0.1, tube_diameter, 18]);
  }

  translate([regulator_width - wall, regulator_length - wall, -0.1]) color("#b1a531") leg(regulator_leg_height);
}

translate([(enclosure_width - regulator_width) / 2, wall, wall]) regulator();
enclosure();
translate([wall, enclosure_length / 2 - board_length / 2 + wall, 0.1]) {
  board();
}
