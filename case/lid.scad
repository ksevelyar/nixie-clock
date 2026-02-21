include <mixin.scad>

$fn = 128;

module m3_cutout(height) {
  difference() {
    cylinder(h=height, d=5.5, $fn=32);
    cylinder(h=height + 1, d=3, $fn=32);
  }
}

module cutout(leg_height = 8) {
  cylinder(h=leg_height, d=m3, $fn=32);
}

module lid() {
  difference() {
    translate([wall + 0.25, wall + 0.25, wall]) rounded_box(
        [enclosure_width - 0.5, enclosure_length - 0.5, lid_height], r=corner_radius
      );

    union() {
      translate([wall, wall, 0]) {
        translate([leg_padding, leg_padding, 0]) cutout(enclosure_leg_height);
        translate([enclosure_width - leg_padding, leg_padding, 0]) cutout(enclosure_leg_height);
        translate([enclosure_width - leg_padding, enclosure_length - leg_padding, 0]) cutout(enclosure_leg_height);
        translate([leg_padding, enclosure_length - leg_padding, 0]) cutout(enclosure_leg_height);
      }

      translate([wall, wall, wall + 1]) {
        translate([leg_padding, leg_padding, 0]) m3_cutout(enclosure_leg_height);
        translate([enclosure_width - leg_padding, leg_padding, 0]) m3_cutout(enclosure_leg_height);
        translate([enclosure_width - leg_padding, enclosure_length - leg_padding, 0]) m3_cutout(enclosure_leg_height);
        translate([leg_padding, enclosure_length - leg_padding, 0]) m3_cutout(enclosure_leg_height);
      }
    }
  }
}

lid();
