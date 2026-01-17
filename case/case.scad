include <mixin.scad>

$fn = 64;

module board() {
  color("#8ec5ff") {
    translate([4, 4, 0]) leg(board_leg_height);
    translate([board_width - 4, 4, 0]) leg(board_leg_height);
    translate([board_width - 4, board_length - 4, 0]) leg(board_leg_height);
    translate([4, board_length - 4, 0]) leg(board_leg_height);
  }
}

module leg(leg_height) {
  difference() {
    cylinder(h=leg_height, d=6.24, $fn=32);
    cylinder(h=leg_height + 1, d=3.12, $fn=32);
  }
}

module tube() {
  translate([board_width / 2, 0, -1])
    cylinder(h=45, d=tube_diameter, $fn=32);

  translate([board_width / 2 + 11.7, 0, -1])
    cylinder(h=45, d=m3, $fn=32);

  translate([board_width / 2 - 11.7, 0, -1])
    cylinder(h=45, d=m3, $fn=32);
}

module tubes() {
  socket_radius = socket_diameter / 2;

  end_gap = (enclosure_length - 4 * socket_diameter) / 3;
  pair_pitch = socket_diameter;

  first_pair_first_center = end_gap + socket_radius;
  second_pair_first_center = first_pair_first_center + 2 * pair_pitch + end_gap;

  tube_centers_y = [
    first_pair_first_center,
    first_pair_first_center + pair_pitch,
    second_pair_first_center,
    second_pair_first_center + pair_pitch,
  ];

  for (center_y = tube_centers_y) translate([0, center_y]) tube();
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
  color("#9b8cff") {
    translate([(enclosure_width + wall * 2) / 2 - tube_diameter / 2 - wall - 0.2, wall, 0.1]) cube([2, enclosure_length, 4.6]);
    translate([(enclosure_width - wall / 2) / 2 + tube_diameter / 2 + wall + 0.2, wall, 0.1]) cube([2, enclosure_length, 4.6]);

    difference() {
      rounded_box(
        [enclosure_width + wall * 2, enclosure_length + wall * 2, enclosure_height + lid_height + 0.2],
        r=corner_radius
      );
      translate([wall, wall, wall]) rounded_box(
          [enclosure_width, enclosure_length, enclosure_height * 2], r=corner_radius
        );

      translate([board_width, wall, 0]) type_c_cutout();

      translate([wall, wall, 0]) tubes();
    }

    translate([wall, wall, 0.1]) {
      translate([leg_padding, leg_padding, 0]) leg(enclosure_leg_height);
      translate([enclosure_width - leg_padding, leg_padding, 0]) leg(enclosure_leg_height);
      translate([enclosure_width - leg_padding, enclosure_length - leg_padding, 0]) leg(enclosure_leg_height);
      translate([leg_padding, enclosure_length - leg_padding, 0]) leg(enclosure_leg_height);
    }
  }
}

module regulator() {
  color("#bf7ad1") {
    difference() {
      cube([regulator_width + wall * 2, regulator_length + wall * 2, board_leg_height - wall]);
      translate([-wall, 0, -wall]) cube([regulator_width * 2, regulator_length + wall, 20]);

      translate([(regulator_width - tube_diameter) / 2 + wall - 0.2, 13, -1]) cube([tube_diameter - 0.1, tube_diameter, 18]);
    }

    translate([regulator_width - wall, regulator_length - wall, -0.1]) leg(regulator_leg_height);
  }
}

translate([(enclosure_width - regulator_width) / 2, wall, wall]) regulator();
enclosure();
translate([wall, enclosure_length / 2 - board_length / 2 + wall, 0.1]) {
  board();
}
