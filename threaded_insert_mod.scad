include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

knurling_height = 8.5;
knurling_height_clearance = 0.2;

// knurling diameter, diameter above knurling
tip_diameters = [
    [7, 3.2],
    [7, 3.2],
    [7, 4.7],
    [7, 5.6],
    [7, 6.4],
    [7, 4.6],
    [9, 6.2],
];
knurling_diameter_clearance = 0.2;
above_knurling_diameter_clearance = 0.25;
center_depth_ratio = 0.225
spacing = 4;

num_tips = len(tip_diameters);

module tip_cylinders() {
    
}