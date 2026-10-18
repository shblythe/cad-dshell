include <NopSCADlib/lib.scad>

thickness = 1.5;
cable_dia = 6;
screw_pilot = 1.6;
screw_clearance = 2.4;
d_clearance_y = 11;
solid_overlap = 0.001;
screw_pos_x = 23.5;
screw_pos_z1 = -3;
screw_pos_z2 = -27;

module screw_countersink(
        dh = 4.5,   //head dia
        ds = screw_clearance,  //shaft dia
        angle = 90,
        )
{
    head_length = (dh-ds)/2*sin(angle/2);
    union() {
        cylinder(h=head_length, r1=dh/2, r2=ds/2, $fn=10);
    }
}

module screw_pilot_pillar()
    translate([0,-d_clearance_y/4-solid_overlap/2,0])
        rotate([90,0,0])
            tube(thickness+screw_pilot/2,screw_pilot/2,d_clearance_y/2+solid_overlap,center=true);

module screw_clearance_pillar()
    translate([0,-d_clearance_y/4-thickness/2,0])
        rotate([90,0,0])
            cylinder(r=thickness+screw_pilot/2,h=d_clearance_y/2+thickness,center=true);

// For differencing
module screw_clearance_hole()
    translate([0,-d_clearance_y/4-thickness/2,0])
        rotate([90,0,0])
        {
            poly_cylinder(h=d_clearance_y/2+thickness+solid_overlap,r=screw_clearance/2,center=true,sides=10);
            translate([0,0,(d_clearance_y/2+thickness)/2+solid_overlap])
                rotate([0,180,0])
                    screw_countersink();
        }

module shell_stl() {
    stl("shell");
    rotate([90,0,0])
    difference() {
        union() {
            if ($preview)
                d_socket(DCONN25);
            // Screw holes, front ones are located to stop lateral movement of socket
            translate([screw_pos_x,0,screw_pos_z1])
                screw_pilot_pillar();
            translate([-screw_pos_x,0,screw_pos_z1])
                screw_clearance_pillar();
            translate([-screw_pos_x,0,screw_pos_z2])
                screw_pilot_pillar();
            translate([screw_pos_x,0,screw_pos_z2])
                screw_clearance_pillar();
            // Locating lip on one side
            translate([53/2-thickness*3/2+solid_overlap,-(d_clearance_y/2+solid_overlap-thickness)/2,(screw_pos_z1+screw_pos_z2)/2])
                cube([thickness,d_clearance_y/2+thickness,screw_pos_z1-screw_pos_z2-thickness*2-screw_pilot/2-screw_clearance/2],center=true);
            // Main structure
            translate([0,0,-35])
                difference() {
                    // Main tube of shell
                    union() {
                        rectangular_tube([53,d_clearance_y+thickness*2,35],center=false,thickness=thickness);
                        translate([0,0,thickness/2])
                        {
                            tube(cable_dia/2+thickness,cable_dia/2,thickness+2);
                            difference() {
                                cube([52,12,thickness],center=true);
                                cylinder(h=thickness+1,r=cable_dia/2,center=true);
                            }
                        }
                    }
                    // But we only want half of it!
                    translate([0,6.5,18])
                        cube([60,13,40],center=true);
                }
                // D-socket locating lips, top/bottom
                d_socket_plate_thickness = 2;
                translate([-20,-(d_clearance_y/2+thickness),0])
                    cube([40,thickness/2,1.5+thickness/2],center=false);
                translate([0,-(d_clearance_y/2+thickness)+1,d_socket_plate_thickness])
                    cube([40,2,thickness/2],center=true);
        }
        translate([-screw_pos_x,0,screw_pos_z1])
            screw_clearance_hole();
        translate([screw_pos_x,0,screw_pos_z2])
            screw_clearance_hole();
    }
}

module main_assembly()
    assembly("main") {
        shell_stl();
    }

if ($preview)
    main_assembly();

