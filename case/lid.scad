include <mixin.scad>

$fn = 128;

module leg(leg_height = 8) {
  difference() {
    cylinder(h=leg_height, d=5.5, $fn=32);

    color("#b1a531") cylinder(h=leg_height + 1, d=3, $fn=32);
  }
}

module cutout(leg_height = 8) {
  cylinder(h=leg_height, d=m3, $fn=32);
}

module tube() {
  translate([board_width / 2, 0, height]) color("#d6a731")
      cylinder(h=45, d=tube_diameter, $fn=32);
}

module lid() {
  difference() {
    translate([wall + 0.25, wall + 0.25, wall]) rounded_box(
        [enclosure_width - 0.5, enclosure_length - 0.5, lid_height], r=4
      );

    union() {
      translate([wall, wall, 0]) {
        translate([3, 3, 0]) color("#b1a531") cutout(enclosure_leg_height);
        translate([enclosure_width - 3, 3, 0]) color("#b1a531") cutout(enclosure_leg_height);
        translate([enclosure_width - 3, enclosure_length - 3, 0]) color("#b1a531") cutout(enclosure_leg_height);
        translate([3, enclosure_length - 3, 0]) color("#b1a531") cutout(enclosure_leg_height);
      }

      translate([wall, wall, wall + 3 - 2]) {
        translate([3, 3, 0]) color("#b1a531") leg(enclosure_leg_height);
        translate([enclosure_width - 3, 3, 0]) color("#b1a531") leg(enclosure_leg_height);
        translate([enclosure_width - 3, enclosure_length - 3, 0]) color("#b1a531") leg(enclosure_leg_height);
        translate([3, enclosure_length - 3, 0]) color("#b1a531") leg(enclosure_leg_height);
      }
    }
  }
}

lid();
