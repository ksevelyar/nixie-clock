board_length = 100;
board_width = 60;
regulator_length = 25;
regulator_width = 30;
board_leg_height = 16;
wall = 2;

enclosure_width = board_width + 0.5;
enclosure_length = 162;
enclosure_leg_height = 18 + wall;
enclosure_height = enclosure_leg_height;

tube_diameter = 16.4;
socket_diameter = 25;
lid_height = 3;
m3 = 3.12;

regulator_leg_height = 3;

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
