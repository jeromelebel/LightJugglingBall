mysize = 35;
thickness = 3;
batteryLength = 45;
batteryRadius = 5.5;
batteryDelta = 2;
threadHolderHeight = 6;
threadHolderThickness = 3;
threadRadiusDelta = 0.5;
threadPitch = 3;
plateThickness = 2;
plateHoleRadius = 1.5;
boxThickness = 2;
ball_a = true;
ball_b = false;
plate = false;
ballCenter = false;
delta = 0.0001;
myscale = 1.02;
angle = 0;
min_angle = 2;
flat_height = 1;

explodedPosition = false;
printingPosition = true;
openBall = true;
threadOnly = false;

function facets_count() = printingPosition ? 100 : 30;
$fn = facets_count();

use <threads.scad>

function ball_a_thread_radius(inside) = inside ? thread_inner_radius(diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, pitch = threadPitch, internal = false) : thread_outer_radius(diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, pitch = threadPitch, internal = false);
function ball_b_thread_radius(inside) = myscale * (inside ? thread_inner_radius(diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, pitch = threadPitch, internal = true) : thread_outer_radius(diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, pitch = threadPitch, internal = true));
function height_for_length(length) = tan(angle) * length;
function length_for_height(height) = height / tan(angle);

function plate_angle_thickness() = height_for_length(ball_b_thread_radius(false) - mysize + threadHolderThickness * 2);
function real_plate_thickness() = plateThickness + plate_angle_thickness();

module halfBall(extraLength)
{
	difference() {
		sphere(r = mysize);
		sphere(r = mysize - thickness);
		translate([0, 0, mysize + extraLength]) cube([mysize * 2, mysize * 2, mysize * 2], center = true);
		translate([0, 0, -mysize * 2 + flat_height]) cube([mysize * 2, mysize * 2, mysize * 2], center = true);
	}
	if (ballCenter) translate([0, 0, -mysize]) cylinder(r = 2, h = mysize);
}

module insideThreadHolder()
{
	translate([0, 0, -mysize])
	difference() {
		union() {
			cylinder(h = mysize - (threadHolderHeight / 2), r = ball_a_thread_radius(true));
			translate([0, 0, mysize - threadHolderHeight]) metric_thread(pitch = threadPitch, length = threadHolderHeight + threadHolderHeight / 2, diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2);
		}
		translate([0, 0, -1]) cylinder(h = (threadHolderHeight / 2) + mysize + 2, r = mysize - (threadHolderThickness * 2));
	}
}

module a_ball_without_thread()
{
  intersection() {
    sphere(r = mysize);
    union()
    {
      halfBall(-threadHolderHeight / 2);
      translate([0, 0, -mysize / 2 - threadHolderHeight / 2]) difference() {
        cylinder(h = mysize / 2, r = mysize);
        translate([0, 0, - mysize / 4]) cylinder(h = mysize, r = ball_a_thread_radius(true));
      }
    }
    if (angle >= min_angle) {
      translate([0, 0, -mysize - threadHolderHeight / 2]) cylinder(h = mysize, r1 = length_for_height(mysize) + ball_a_thread_radius(true), r2 = ball_a_thread_radius(true));
    }
  }
}

module a_ball()
{
	intersection() {
		sphere(r = mysize);
		union()
		{
		  a_ball_without_thread();
			insideThreadHolder();
		}
	}
}

function a_ballTranslation() = printingPosition ? [0, 0, threadHolderHeight / 2] : (explodedPosition ? [0, 0, batteryRadius * 2 + threadHolderHeight + 10] : [0, 0, 0]);
function a_ballRotation() = [0, 180, 90];

module b_ball()
{
  union() {
    difference() {
      sphere(r = mysize);
      union() {
        translate([0, 0, -threadHolderHeight / 2 - real_plate_thickness()]) scale([myscale, myscale, myscale]) metric_thread(pitch = threadPitch, length = threadHolderHeight * 2 + real_plate_thickness(), diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, internal = true);
        difference() {
          sphere(r = mysize - thickness);
          translate ([0, 0, -mysize]) difference() {
            cylinder(h = mysize * 2, r = mysize);
            cylinder(h = mysize * 4, r = mysize - threadHolderThickness * 2);
          }
        }
        if (angle >= min_angle) {
          translate([0, 0, threadHolderHeight / 2]) cylinder(h = mysize, r1 = ball_b_thread_radius(true), r2 = length_for_height(mysize) + ball_b_thread_radius(true));
        } else {
          translate([0, 0, threadHolderHeight / 2]) cylinder(h = mysize, r = mysize);
        }
      }
  		translate([0, 0, -mysize * 2 + flat_height]) cube([mysize * 2, mysize * 2, mysize * 2], center = true);
    }
    if (angle >= min_angle) {
      intersection () {
        translate([0, 0, -threadHolderHeight / 2 - real_plate_thickness()]) difference() {
          cylinder(h = plate_angle_thickness(), r = mysize);
          translate([0, 0, -1]) cylinder(h = plate_angle_thickness() + 2, r1 = mysize - threadHolderThickness * 2 - length_for_height(1), r2 = ball_b_thread_radius(false) + length_for_height(1));
        }
        sphere(r = mysize);
      }
    }
  }
}

function b_ballTranslation() = (printingPosition && ball_a) ? [0, mysize * 2.2, threadHolderHeight / 2] : (explodedPosition ? [0, 0, 0] : [0, 0, 0]);
function b_ballRotation() = printingPosition?[0, 180, 90]:[0, 0, 0];

module plate()
{
  difference () {
    union() {
      intersection() {
        translate([0, 0, -plate_angle_thickness()]) metric_thread(pitch = threadPitch, length = real_plate_thickness(), diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2);
        if (angle >= min_angle) {
          translate([0, 0, -plate_angle_thickness()]) cylinder(h = real_plate_thickness(), r1 = mysize - threadHolderThickness * 2, r2 = mysize - threadHolderThickness * 2 + length_for_height(real_plate_thickness()));
        }
      }
      if (!threadOnly) translate([0, 0, batteryRadius + plateThickness]) cube(size = [ batteryLength + boxThickness * 2, batteryRadius * 6 + boxThickness * 2, batteryRadius * 2], center = true);
    }
    translate([0, 0, batteryRadius + plateThickness + 1]) cube(size = [ batteryLength, batteryRadius * 6, batteryRadius * 2 + 2], center = true);
    translate([batteryLength / 4, batteryRadius * 3 + boxThickness * 3, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([-batteryLength / 4, batteryRadius * 3 + boxThickness * 3, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([batteryLength / 4, -batteryRadius * 3 - boxThickness * 3, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([-batteryLength / 4, -batteryRadius * 3 - boxThickness * 3, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([batteryLength / 2 + boxThickness * 2, 0, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([-batteryLength / 2 - boxThickness * 2, 0, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    if (threadOnly) translate([0, 0, -plateThickness / 2]) cylinder(h = mysize, r = mysize * 0.7);
    translate([0, 0, plateThickness]) difference() {
      cylinder(h = batteryRadius * 2.5, r = mysize);
      cylinder(h = batteryRadius * 3, r = (sqrt(batteryRadius * batteryRadius * 9 + batteryLength * batteryLength / 4)));
    }
  }
}

function plateTranslation() = printingPosition ? ((ball_a || ball_b) ? [mysize * 2.2, 0, 0] : [0, 0, 0]) : (explodedPosition ? [0, 0, threadHolderHeight / 2 + 5] : [0, 0, - threadHolderHeight / 2 - plateThickness]);
function plateRotation() = [0, 0, 0];

module battery()
{
	cylinder(h = batteryLength, r = batteryRadius);
}

module allBatteries()
{
	translate([-22, 10, 0]) rotate(a=[0, 90, 0]) battery();
	translate([-22, -10, 0]) rotate(a=[0, 90, 0]) battery();
	translate([-22, 0, 0]) rotate(a=[0, 90, 0]) battery();
}

if (ball_a) {
	translate(a_ballTranslation()) rotate(a = a_ballRotation())
	difference () {
		rotate(a = [0, 0, 290]) a_ball();
		if (openBall && !printingPosition) translate([0, -mysize * 2, -mysize]) cube([mysize * 2, mysize * 2, mysize * 2]);
		if (threadOnly) translate([-mysize, -mysize, - mysize * 2 - threadHolderHeight]) cube([mysize * 2, mysize * 2, mysize * 2]);
	}
}
if (ball_b) {
	translate(b_ballTranslation()) rotate(a = b_ballRotation())
	difference () {
		b_ball();
		if (openBall && !printingPosition) translate([0, -mysize * 2, -mysize]) cube([mysize * 2, mysize * 2, mysize * 2]);
		if (threadOnly) translate([-mysize, -mysize, - mysize * 2 - threadHolderHeight * 1.4]) cube([mysize * 2, mysize * 2, mysize * 2]);
	}
}

if (plate) {
  translate(plateTranslation()) rotate(a = plateRotation())
	difference () {
    rotate(a = [0, 0, 290]) plate();
		if (openBall && !printingPosition) translate([0, -mysize * 2, -mysize]) cube([mysize * 2, mysize * 2, mysize * 2]);
  }
}

//allBatteries();
