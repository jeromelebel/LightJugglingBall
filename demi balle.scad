mysize = 35;
thickness = 5;
batteryLength = 44;
batteryRadius = 5;
batteryDelta = 2;

module halfBall()
{
	difference() {
		sphere(r = mysize);
		sphere(r = mysize - thickness);
		translate([0, 0, mysize]) cube([mysize * 2, mysize * 2, mysize * 2], center = true);
	}
}

module electronicsHolder()
{
	difference () {
		translate([0, 0, -thickness / 2]) cube([mysize * 2, 80, thickness + (batteryRadius * 2)], center = true);
		translate([0, 0, 5]) cube([batteryLength + batteryDelta, batteryRadius * 2 * 3 + batteryDelta, (batteryRadius * 2) + 10], center = true);
		difference() {
			sphere(r = mysize * 2);
			sphere(r = mysize - thickness + 1);
			//translate([0, 0, mysize]) cube([mysize * 2, mysize * 2, mysize * 2], center = true);
		}
		cylinder(h = ((batteryRadius * 2 + thickness) * 2), r = 2.5, center = true);
	}
}

module battery()
{
	cylinder(h = batteryLength, r = batteryRadius);
}

union()
{
	halfBall();
	electronicsHolder();
// battery
	translate([-22, 10, 0]) rotate(a=[0, 90, 0]) battery();
	translate([-22, -10, 0]) rotate(a=[0, 90, 0]) battery();
	translate([-22, 0, 0]) rotate(a=[0, 90, 0]) battery();
}
