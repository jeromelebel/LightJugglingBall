mysize = 35;
thickness = 3;
batteryLength = 44;
batteryRadius = 5;
batteryDelta = 2;
threadHolderHeight = 5;
threadHolderThickness = 3;
openBall = true;
ball_a = true;
ball_b = true;
ballCenter = false;

use <threads.scad>

module halfBall(extraLength)
{
	difference() {
		sphere(r = mysize);
		sphere(r = mysize - thickness);
		translate([0, 0, mysize + extraLength]) cube([mysize * 2, mysize * 2, mysize * 2], center = true);
	}
	if (ballCenter) translate([0, 0, -mysize]) cylinder(r = 2, h = mysize);
}

module insideThreadHolder()
{
	translate([0, 0, -mysize])
	difference() {
		union() {
			cylinder(h = mysize - (threadHolderHeight / 2), r = mysize - threadHolderThickness);
			cylinder(h = mysize - (threadHolderHeight / 2), r = mysize + 10);
			translate([0, 0, mysize - (threadHolderHeight / 2)]) metric_thread(length = threadHolderHeight, diameter = (mysize - threadHolderThickness) * 2);
		}
		translate([0, 0, -1]) cylinder(h = (threadHolderHeight / 2) + mysize + 2, r = mysize - (threadHolderThickness * 2));
	}
}

module outsideThreadMask()
{
	translate([0, 0, threadHolderHeight / 2]) difference() {
		cylinder(h = threadHolderHeight * 2, r = mysize - threadHolderThickness, center = true);
		cylinder(h = threadHolderHeight * 3, r = mysize - threadHolderThickness - thickness, center = true);
	}
}

module a_ball()
{
	intersection() {
		sphere(r = mysize);
		union()
		{
			halfBall(-threadHolderHeight / 2);
			insideThreadHolder();
		}
	}
}

module b_ball()
{
	intersection() {
		sphere(r = mysize);
		difference()
		{
			union() {
				halfBall(threadHolderHeight / 2);
				translate([0, 0, -mysize]) difference() {
					cylinder(h = mysize + (threadHolderHeight / 2), r = mysize);
					translate([0, 0, -1]) cylinder(h = mysize + (threadHolderHeight / 2) + 2, r = mysize - threadHolderThickness);
				}
				translate([0, 0, -mysize]) difference() {
					cylinder(h = mysize - (threadHolderHeight / 2), r = mysize);
					translate([0, 0, -1]) cylinder(h = mysize + (threadHolderHeight / 2) + 2, r = mysize - (threadHolderThickness * 2));
				}
			}
			outsideThreadMask();
		}
	}
}

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

module thread(r=4, pitch=1, length=1, internal=false, n_starts=1)
{
   h = pitch * cos(30);
   if (internal) {
      metric_thread(r * 2 + h*5/4, pitch, length, internal, n_starts);
   } else {
      metric_thread(r * 2 + h*5.3/4, pitch, length, internal, n_starts);
   }
}

if (ball_a) {
	translate([0, 0, 10]) rotate(a = [0, 180, 90])
	difference () {
		a_ball();
		if (openBall) translate([0, -mysize * 2, -mysize]) cube([mysize * 2, mysize * 2, mysize * 2]);
	}
}
if (ball_b) difference () {
	b_ball();
	if (openBall) translate([0, -mysize * 2, -mysize]) cube([mysize * 2, mysize * 2, mysize * 2]);
}

//allBatteries();
