include <mixin.scad>

$fn = 64;

module tube() {
  difference() {
    union() {
    translate([board_width / 2, 0, 0]) color("#d6a731")
        cylinder(h=2, d=tube_diameter + 15, $fn=32);

  translate([(enclosure_width + wall * 2) / 2 - tube_diameter / 2 - wall*3 - 3.55, -10, 0.1]) cube([5, enclosure_length, 4.4]);
  translate([(enclosure_width - wall / 2) / 2 + tube_diameter / 2 + 0.55+wall, -10, 0.1]) cube([5, enclosure_length, 4.4]);
        }

    translate([0,3,-0.1]) cube(200);

    union() {
      translate([board_width / 2, 0, -1]) color("#d6a731")
        cylinder(h=45, d=tube_diameter+0.1, $fn=32);

      translate([board_width / 2 + 11.7, 0, -1]) color("#d6a731")
          cylinder(h=45, d=m3-0.1, $fn=32);

      translate([board_width / 2 - 11.7, 0, -1]) color("#d6a731")
          cylinder(h=45, d=m3-0.1, $fn=32);
    }
  }
}

tube();
