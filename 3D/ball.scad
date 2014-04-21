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
ball_a = false;
ball_b = true;
plate = false;
ballCenter = false;
delta = 0.0001;
myscale = 1.02;
angle = 30;

explodedPosition = false;
printingPosition = false;
openBall = true;
threadOnly = false;

function facets_count() = printingPosition ? 100 : 30;
$fn = facets_count();

use <threads.scad>

function ball_a_thread_radius(inside) = inside ? thread_inner_radius(diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, pitch = threadPitch, internal = false) : thread_outer_radius(diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, pitch = threadPitch, internal = false);
function ball_b_thread_radius(inside) = myscale * (inside ? thread_inner_radius(diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, pitch = threadPitch, internal = true) : thread_outer_radius(diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, pitch = threadPitch, internal = true));

module fullBall()
{
  union() {
    difference() {
      sphere(r = mysize);
      sphere(r = mysize - thickness);
    }
    difference() {
      translate ([0, 0, -mysize]) difference() {
        cylinder(h = mysize * 2, r = mysize);
        cylinder(h = mysize * 4, r = mysize - threadHolderThickness * 2);
      }
      difference () {
        sphere(r = mysize * 2);
        sphere(r = mysize);
      }
    }
  }
}

module halfBall(extraLength)
{
	difference() {
		sphere(r = mysize);
		sphere(r = mysize - thickness);
		translate([0, 0, mysize + extraLength])
    cube([mysize * 2, mysize * 2, mysize * 2], center = true);
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
    translate([0, 0, -mysize - threadHolderHeight / 2]) cylinder(h = mysize, r1 = mysize / tan(angle) + ball_a_thread_radius(true), r2 = ball_a_thread_radius(true));
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
  difference() {
    sphere(r = mysize);
    union() {
      translate([0, 0, -threadHolderHeight / 2 - plateThickness]) scale([myscale, myscale, myscale]) metric_thread(pitch = threadPitch, length = threadHolderHeight * 2 + plateThickness, diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, internal = true);
      translate([0, 0, -threadHolderHeight / 2 - plateThickness - (ball_b_thread_radius(true) - mysize + threadHolderThickness * 2) * tan(30)]) cylinder(h = (ball_b_thread_radius(true) - mysize + threadHolderThickness * 2) * tan(30), r2 = ball_b_thread_radius(true), r1 = mysize - threadHolderThickness * 2, $fn = 50);
      difference() {
        sphere(r = mysize - thickness);
        translate ([0, 0, -mysize]) difference() {
          cylinder(h = mysize * 2, r = mysize);
          cylinder(h = mysize * 4, r = mysize - threadHolderThickness * 2);
        }
      }
      translate([0, 0, threadHolderHeight / 2]) cylinder(h = mysize, r1 = ball_b_thread_radius(true), r2 = mysize / tan(30) + ball_b_thread_radius(true));
    }
  }
}

function b_ballTranslation() = (printingPosition && ball_a) ? [0, mysize * 2.2, threadHolderHeight / 2] : (explodedPosition ? [0, 0, 0] : [0, 0, 0]);
function b_ballRotation() = printingPosition?[0, 180, 90]:[0, 0, 0];

module plate()
{
  difference () {
    union() {
      metric_thread(pitch = threadPitch, length = plateThickness, diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2);
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
		rotate(a = [0, 0, 210]) a_ball();
		if (openBall) translate([0, -mysize * 2, -mysize]) cube([mysize * 2, mysize * 2, mysize * 2]);
		if (threadOnly) translate([-mysize, -mysize, - mysize * 2 - threadHolderHeight]) cube([mysize * 2, mysize * 2, mysize * 2]);
	}
}
if (ball_b) {
	translate(b_ballTranslation()) rotate(a = b_ballRotation())
	difference () {
		b_ball();
		if (openBall) translate([0, -mysize * 2, -mysize]) cube([mysize * 2, mysize * 2, mysize * 2]);
		if (threadOnly) translate([-mysize, -mysize, - mysize * 2 - threadHolderHeight]) cube([mysize * 2, mysize * 2, mysize * 2]);
	}
}

if (plate) {
	translate(plateTranslation()) rotate(a = plateRotation())
  plate();
}

//allBatteries();
