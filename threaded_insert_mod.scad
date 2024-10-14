include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = $preview ? 24 : 48 * 4;
EXTRA = 0.01 + 0;

knurling_height = 8.5;
default_knurling_height_clearance = 0.75;
above_knurling_height = 2;

// knurling diameter, diameter above knurling, optional: knurling diameter clearance, knurling_height_clearance, center depth ratio
tip_diameters = [
    [7, 3.2],
    [7, 3.2],
    [7, 4.7],
    [7, 5.6],
    [7, 6.4],
    [7, 4.6],
    [9, 6.2, 0.3, 1.25, 0.25],
];
default_knurling_diameter_clearance = 0.2;
above_knurling_diameter_clearance = 0.3;
default_center_depth_ratio = 0.23;
bottom_thickness = 1;
total_depth = bottom_thickness + max([for (tip = tip_diameters) tip[0] * (1 - default(tip[4], default_center_depth_ratio))]);
max_knurling_height_clearance = max([for (tip = tip_diameters) default(tip[3], default_knurling_height_clearance)]);
spacing = 4;
rounding = 0.75;
extra_block_size = 2;

num_tips = len(tip_diameters);

x_offsets = [
    for (i=0,
            cum_sum=spacing + tip_diameters[0][0] / 2;
         i < num_tips;
         i = i + 1,
            cum_sum = cum_sum + spacing + tip_diameters[i-1][0] / 2 + default(tip_diameters[i][0], 0) / 2)
    cum_sum];
total_width = x_offsets[num_tips - 1] + tip_diameters[num_tips - 1][0] / 2 + spacing;

module tip_cylinders() {
    for (i = [0:num_tips - 1]) {
        knurling_diameter = tip_diameters[i][0] + default(tip_diameters[i][2], default_knurling_diameter_clearance);
        above_knurling_diameter = tip_diameters[i][1] + above_knurling_diameter_clearance;
        knurling_height_clearance = default(tip_diameters[i][3], default_knurling_height_clearance);
        center_depth_ratio = default(tip_diameters[i][4], default_center_depth_ratio);
        cur_x_offset = x_offsets[i];
        cur_y_offset = max_knurling_height_clearance - knurling_height_clearance;
        cur_z_offset = knurling_diameter / 2 - knurling_diameter * center_depth_ratio;
        rounding_x_offset = sqrt((knurling_diameter / 2 + rounding)^2 - (cur_z_offset - rounding)^2);
        theta = asin((cur_z_offset - rounding)/(knurling_diameter / 2 + rounding));
        rounding_cube_angle = 90 - (90 - theta) / 2;
        rounding_cube_size = 2 * sin(45 + theta / 2) * rounding;
        translate([cur_x_offset, EXTRA - cur_y_offset, -cur_z_offset]) {
            // the cutout for the knurled part of the tip
            ycyl(d=knurling_diameter, h=knurling_height + knurling_height_clearance + EXTRA, anchor=BACK);
            // the cutout for the part of the tip just above the knurled portion
            fwd(knurling_height + knurling_height_clearance)
                ycyl(d=above_knurling_diameter, h=above_knurling_height + 2 * EXTRA, anchor=BACK)
                    attach(CENTER)
                    cuboid([above_knurling_diameter, above_knurling_height + 2 * EXTRA, cur_z_offset + EXTRA],
                           rounding=-rounding, edges=[TOP + LEFT, TOP + RIGHT], anchor=BOTTOM);
        }
        // round where the knurling cutout meets the top of the cube
        for (rounding_sign = [-1, 1]) {
            translate([cur_x_offset + rounding_sign * rounding_x_offset, EXTRA - cur_y_offset, 0])
                difference() {
                    yrot(rounding_sign * -rounding_cube_angle)
                        cuboid([rounding_cube_size, knurling_height + knurling_height_clearance + EXTRA, rounding_cube_size], anchor=BACK + BOTTOM + rounding_sign * RIGHT);
                    down(rounding)
                        ycyl(r=rounding, h=knurling_height + knurling_height_clearance + EXTRA, anchor=BACK);
                }
        }
    }
}

difference() {
    back(extra_block_size)
        cuboid(
            [total_width, knurling_height + max_knurling_height_clearance + above_knurling_height + extra_block_size, total_depth + extra_block_size],
            rounding=rounding,
            edges=[LEFT + FRONT + TOP, RIGHT + FRONT + TOP],
            anchor=TOP + BACK + LEFT);
    tip_cylinders();
}