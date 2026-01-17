corner_radius = 8;
lid_height = 3;
m3 = 3.12;
socket_diameter = 25;
tube_diameter = 16.4;
wall = 2;

board_length = 100;
board_width = 60;
board_leg_height = 16;

regulator_length = 25;
regulator_width = 30;
regulator_leg_height = 3;

enclosure_width = board_width + 0.5;
enclosure_length = 162;
enclosure_leg_height = 18 + wall;
enclosure_height = enclosure_leg_height;

leg_padding = corner_radius/2+0.4;

module rounded_box(size = [10, 10, 5], r) {
  translate([size[0] / 2, size[1] / 2, 0]) {
    linear_extrude(height=size[2]) {
      minkowski() {
        square([size[0] - 2 * r, size[1] - 2 * r], center=true);
        circle(r=r);
      }
    }
  }
}
