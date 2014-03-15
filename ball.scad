mysize = 35;
thickness = 3;
batteryLength = 44;
batteryRadius = 5;
batteryDelta = 2;
threadHolderHeight = 8;
threadHolderThickness = 4;
openBall = true;

module halfBall(extraLength)
{
	difference() {
		sphere(r = mysize);
		sphere(r = mysize - thickness);
		translate([0, 0, mysize + extraLength]) cube([mysize * 2, mysize * 2, mysize * 2], center = true);
	}
}

module insideThreadHolder()
{
	translate([0, 0, -threadHolderHeight / 2]) difference() {
		cylinder(h = threadHolderHeight * 2, r = mysize - threadHolderThickness, center = true);
		cylinder(h = threadHolderHeight * 3, r = mysize - (threadHolderThickness * 2), center = true);
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

translate([0, 0, 10]) rotate(a = [0, 180, 90]) difference () {
	a_ball();
	if (openBall) translate([0, -mysize * 2, -mysize]) cube([mysize * 2, mysize * 2, mysize * 2]);
}
difference () {
	b_ball();
	if (openBall) translate([0, -mysize * 2, -mysize]) cube([mysize * 2, mysize * 2, mysize * 2]);
}

allBatteries();