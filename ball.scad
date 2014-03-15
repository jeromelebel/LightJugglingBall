mysize = 35;
thickness = 3;
batteryLength = 44;
batteryRadius = 5;
batteryDelta = 2;
threadHolderHeight = 5;
threadHolderThickness = 2;
openBall = true;
ball_a = true;
ball_b = true;
ballCenter = false;

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
		cylinder(h = (threadHolderHeight / 2) + mysize, r = mysize - threadHolderThickness);
		translate([0, 0, -1]) cylinder(h = (threadHolderHeight / 2) + mysize + 2, r = mysize - (threadHolderThickness * 2));
	}
}

module outsideThreadMask()
{
	translate([0, 0, threadHolderHeight / 2]) difference() {
		cylinder(h = threadHolderHeight * 2, r = mysize - threadHolderThickness, center = true);
		cylinder(h = threadHolderHeight * 3, r = mysize - (threadHolderThickness * 2), center = true);
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
			halfBall(threadHolderHeight / 2);
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
