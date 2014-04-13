mysize = 35;
thickness = 3;
batteryLength = 45;
batteryRadius = 5;
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
plate = true;
ballCenter = false;
delta = 0.0001;
myscale = 1.02;

explodedPosition = false;
printingPosition = false;
openBall = false;
threadOnly = true;

//$fn=100;

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

function a_ballTranslation() = printingPosition ? [0, 0, threadHolderHeight / 2] : (explodedPosition ? [0, 0, batteryRadius * 2 + threadHolderHeight + 10] : [0, 0, 0]);
function a_ballRotation() = [0, 180, 90];

module b_ball()
{
	union() {
		halfBall(-threadHolderHeight / 2 - plateThickness);
		intersection () {
			sphere(r = mysize);
			difference() {
				translate([0, 0, -mysize]) cylinder(r = mysize, h = mysize + threadHolderHeight / 2);
				scale([myscale, myscale, myscale]) translate([0, 0, - threadHolderHeight / 2 - plateThickness]) metric_thread(pitch = threadPitch, length = threadHolderHeight * 2 + plateThickness, diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2, internal = true);
				translate([0, 0, -mysize - mysize / 2]) cylinder(r = mysize - threadHolderThickness * 2, h = mysize * 2);
  
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
      metric_thread(pitch = threadPitch, length = plateThickness, diameter = (mysize - threadHolderThickness + threadRadiusDelta) * 2);
      if (!threadOnly) translate([0, 0, batteryRadius + plateThickness]) cube(size = [ batteryLength + boxThickness * 2, batteryRadius * 6 + boxThickness * 2, batteryRadius * 2], center = true);
    }
    translate([0, 0, batteryRadius + plateThickness + 1]) cube(size = [ batteryLength, batteryRadius * 6, batteryRadius * 2 + 2], center = true);
    translate([batteryLength / 4, batteryRadius * 3 + boxThickness * 3, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([-batteryLength / 4, batteryRadius * 3 + boxThickness * 3, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([batteryLength / 4, -batteryRadius * 3 - boxThickness * 3, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([-batteryLength / 4, -batteryRadius * 3 - boxThickness * 3, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([batteryLength / 2 + boxThickness * 3, 0, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
    translate([-batteryLength / 2 - boxThickness * 3, 0, -plateThickness / 2]) cylinder(h = plateThickness * 2, r = plateHoleRadius);
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
		a_ball();
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
