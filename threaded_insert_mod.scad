include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = $preview ? 24 : 48 * 4;
EXTRA = 0.01 + 0;

knurling_height = 8.5;
default_knurling_height_clearance = 0.75;
above_knurling_height = 2;
default_knurling_diameter_clearance = 0.2;
default_above_knurling_diameter_clearance = 0.3;
default_center_depth_ratio = 0.23;

bottom_thickness = 1;
spacing = 5.5;
rounding = 0.75;
extra_block_size = 0.25;
label_y = -11;
label_font = "DejaVu Sans";
label_size = 3.25;

function Tip(name,
             knurling_diameter,
             diameter_above_knurling,
             knurling_diameter_clearance=default_knurling_diameter_clearance,
             above_knurling_diameter_clearance=default_above_knurling_diameter_clearance,
             knurling_height_clearance=default_knurling_height_clearance,
             center_depth_ratio=default_center_depth_ratio) =
    struct_set([], [
               "name", name,
               "knurling_diameter", knurling_diameter,
               "diameter_above_knurling", diameter_above_knurling,
               "knurling_diameter_clearance", knurling_diameter_clearance,
               "above_knurling_diameter_clearance", above_knurling_diameter_clearance,
               "knurling_height_clearance", knurling_height_clearance,
               "center_depth_ratio", center_depth_ratio,
            ]);

tip_info = [
    Tip("M2", 7, 3.2, knurling_diameter_clearance=0.3, knurling_height_clearance=0.9),
    Tip("M2.5", 7, 3.2, knurling_diameter_clearance=0.3, knurling_height_clearance=0.9),
    Tip("M3", 7, 4.7, knurling_diameter_clearance=0.225, knurling_height_clearance=0.85),
    Tip("M4", 7, 5.6),
    Tip("M5", 7, 6.4, above_knurling_diameter_clearance=0.2),
    Tip("M6", 7, 4.6),
    Tip("M8", 9, 6.2, knurling_diameter_clearance=0.3, knurling_height_clearance=1.15, center_depth_ratio=0.25),
];

/* [Hidden] */
NAME = "name";
KNURLING_DIAMETER = "knurling_diameter";
DIAMETER_ABOVE_KNURLING = "diameter_above_knurling";
KNURLING_DIAMETER_CLEARANCE = "knurling_diameter_clearance";
ABOVE_KNURLING_DIAMETER_CLEARANCE = "above_knurling_diameter_clearance";
KNURLING_HEIGHT_CLEARANCE = "knurling_height_clearance";
CENTER_DEPTH_RATIO = "center_depth_ratio";

num_tips = len(tip_info);
total_depth = bottom_thickness + max([for (tip = tip_info) struct_val(tip, KNURLING_DIAMETER) * (1 - struct_val(tip, CENTER_DEPTH_RATIO))]);
max_knurling_height_clearance = max([for (tip = tip_info) struct_val(tip, KNURLING_HEIGHT_CLEARANCE)]);

x_offsets = [
    for (i=0,
            cum_sum=spacing + struct_val(tip_info[0], KNURLING_DIAMETER) / 2;
         i < num_tips;
         i = i + 1,
            cum_sum = cum_sum + spacing + struct_val(tip_info[i-1], KNURLING_DIAMETER) / 2 + struct_val(tip_info[i], KNURLING_DIAMETER, 0) / 2)
    cum_sum];
total_width = x_offsets[num_tips - 1] + struct_val(tip_info[num_tips - 1], KNURLING_DIAMETER) / 2 + spacing;
label_x_offsets = [
    for (i=0,
            cum_sum=spacing / 2;
         i < num_tips;
         cum_sum = cum_sum + struct_val(tip_info[i], KNURLING_DIAMETER) + spacing,
            i = i + 1)
    cum_sum];

module tip_cylinders() {
    for (i = [0:num_tips - 1]) {
        knurling_diameter = struct_val(tip_info[i], KNURLING_DIAMETER) + struct_val(tip_info[i], KNURLING_DIAMETER_CLEARANCE);
        above_knurling_diameter = struct_val(tip_info[i], DIAMETER_ABOVE_KNURLING) + struct_val(tip_info[i], ABOVE_KNURLING_DIAMETER_CLEARANCE);
        knurling_height_clearance = struct_val(tip_info[i], KNURLING_HEIGHT_CLEARANCE);
        center_depth_ratio = struct_val(tip_info[i], CENTER_DEPTH_RATIO);
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

module labels() {
    for (i = [0:num_tips - 1]) {
        label_text = struct_val(tip_info[i], NAME);
        cur_x_offset = label_x_offsets[i];
        translate([cur_x_offset, label_y])
            text3d(label_text, h=0.5, spin=90, atype="ycenter", font=label_font, size=label_size, anchor=LEFT + BOTTOM);
    }

difference() {
    translate([-350, 0, 0])
        import("Tools Container.stl", convexity=10, $fn=$fn);
    // remove two of the short tip holders to make room for threaded insert holders
    translate([132, -3.58, 9.615])
        cuboid([80, 32.25, 15], rounding=3, edges=BACK + RIGHT);
}
translate([80.5, 12.5, 9.5])
    diff() {
        back(extra_block_size)
            cuboid(
                [total_width, knurling_height + max_knurling_height_clearance + above_knurling_height + extra_block_size, total_depth + extra_block_size],
                rounding=rounding,
                edges=[LEFT + FRONT + TOP, RIGHT + FRONT + TOP],
                anchor=TOP + BACK + LEFT)
                edge_mask(BACK + RIGHT)
                    rounding_edge_mask(l=$parent_size.z+EXTRA, r=5);
        tag("remove")
            tip_cylinders();
    }
translate([80.5, 12.5, 9.5])
    color("black") {
        labels();
        // the decimal point is small enough that Bambu Studio ignores it when
        // using the default settings with a 0.4 mm nozzle.  To fix that, we
        // manually add a slightly-larger-than-the-decimal-point cylinder over
        // the decimal point.
        translate([16.5, -3.55, 0])
            cyl(r=0.5, h=0.5, anchor=BOTTOM);
    }

