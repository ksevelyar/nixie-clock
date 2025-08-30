depth = 100;
width = 40;
height = 20;
wall = 2;

module base() {
  color("#4f7270") cube([ width, depth, height ]);
}

module tube() {
  color("#d6a731") cylinder(h = 55, d = 18, $fn = 8);
}

base();
translate([ 20, 15 ]) tube();
translate([ 20, 35 ]) tube();

translate([ 20, 65 ]) tube();
translate([ 20, 85 ]) tube();
