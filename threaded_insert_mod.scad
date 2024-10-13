include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = $preview ? 24 : 48 * 4;
EXTRA = 0.01 + 0;

knurling_height = 8.5;
knurling_height_clearance = 0.2;
above_knurling_height = 2;

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
center_depth_ratio = 0.225;
bottom_thickness = 1;
total_depth = bottom_thickness + max([for (tip = tip_diameters) tip[0]]) * (1 - center_depth_ratio);
spacing = 4;
rounding = 1;

num_tips = len(tip_diameters);

function if_def(x) = is_undef(x) ? 0 : x;
x_offsets = [
    for (i=0,
            cum_sum=spacing + tip_diameters[0][0] / 2;
         i < num_tips;
         i = i + 1,
            cum_sum = cum_sum + spacing + tip_diameters[i-1][0] / 2 + if_def(tip_diameters[i][0]) / 2)
    cum_sum];
echo(x_offsets=x_offsets);
total_width = x_offsets[num_tips - 1] + tip_diameters[num_tips - 1][0] / 2 + spacing;

module tip_cylinders() {
    for (i = [0:num_tips - 1]) {
        knurling_diameter = tip_diameters[i][0] + knurling_diameter_clearance;
        above_knurling_diameter = tip_diameters[i][1] + above_knurling_diameter_clearance;
        cur_x_offset = x_offsets[i];
        cur_z_offset = knurling_diameter * center_depth_ratio;
        translate([cur_x_offset, EXTRA, cur_z_offset - knurling_diameter / 2]) {
            ycyl(d=knurling_diameter, h=knurling_height + knurling_height_clearance + EXTRA, anchor=BACK);
            fwd(knurling_height + knurling_height_clearance)
                ycyl(d=above_knurling_diameter, h=above_knurling_height + 2 * EXTRA, anchor=BACK)
                    attach(CENTER)
                    cuboid([above_knurling_diameter, above_knurling_height + 2 * EXTRA, knurling_diameter], anchor=BOTTOM);
        }
    }
}

difference() {
    cuboid(
        [total_width, knurling_height + knurling_height_clearance + above_knurling_height, total_depth],
        rounding=rounding,
        edges=[LEFT + FRONT + TOP, RIGHT + FRONT + TOP],
        anchor=TOP + BACK + LEFT);
    tip_cylinders();
}