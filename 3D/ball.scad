mysize = 35;
thickness = 3;
batteryLength = 44;
batteryRadius = 5;
batteryDelta = 2;
threadHolderHeight = 5;
threadHolderThickness = 4;
threadRadiusDelta = 0;
threadPitch = 3;
plateThickness = 0;
openBall = true;
ball_a = true;
ball_b = true;
ballCenter = false;
delta = 0.0001;

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
			cylinder(h = mysize - (threadHolderHeight / 2) + (delta * 2), r = mysize - threadHolderThickness);
			cylinder(h = mysize - (threadHolderHeight / 2), r = mysize + 10);
			translate([0, 0, mysize - (threadHolderHeight / 2) + delta]) metric_thread(pitch = threadPitch, length = threadHolderHeight - delta, diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2);
		}
		translate([0, 0, -1]) cylinder(h = (threadHolderHeight / 2) + mysize + 2, r = mysize - (threadHolderThickness * 2));
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
	union() {
		halfBall(-threadHolderHeight / 2 - plateThickness);
		intersection () {
			sphere(r = mysize);
			difference() {
				translate([0, 0, -mysize]) cylinder(r = mysize, h = mysize + threadHolderHeight / 2);
				translate([0, 0, - threadHolderHeight / 2 - plateThickness]) metric_thread(pitch = threadPitch, length = threadHolderHeight * 2 + plateThickness, diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, internal = true);
				translate([0, 0, -mysize - mysize / 2]) cylinder(r = mysize - threadHolderThickness * 2, h = mysize * 2);
  
			}
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
