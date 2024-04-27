echo(version=version());

// MakerCoin parameteric model

// The resolution of the curves. 
//$fa=3; // 360/$fa = 120 facets max
//$fs=1; // prefered facet length
$fn=80; // set the number of fragments to draw an arc
convexity=10;
// Parameters
Rad1 = 6; // height of the center 6
Rad2 = 5; // height at the external 5
D = 20; // size of the coin 20
NbDent = 8; // number of dent
RadDent = 7; // radius of each dent
Pen = 4.5; // dent penetratrion 20+5+7-55/2

// Calculation of cutting circle
// ||(R3+R2)² = (y3-y2)²+(x3-x2)²
// || R3 = y3-y1 >> y3 = R3+y1
// || X3 = 0
//
//  R3 = R1² -2.R1.R2 + d² / [2 . (2.R2-R1)]
//
// Rad3 = 47;
Rad3 = (pow(Rad1,2)-2*Rad1*Rad2+pow(D,2))/(2*(2*Rad2-Rad1));
//echo("Rad3=",Rad3);

// Calculation of tangent point
// ||(xt-x3)²+(yt-y3)² = R3²
// ||(xt-x2)²+(yt-y2)² = R2²
//
// xt = 18.08;
// yt = 9.62;
x2 = D;
y2 = Rad2;
x3 = 0;
y3 = Rad1+Rad3;
K = pow(Rad3,2)-pow(Rad2,2)-((pow(x3,2)+pow(y3,2))-(pow(x2,2)+pow(y2,2)));
//echo("K=",K);
a = (y3-y2)/(x2-x3);
//echo("a=",a);
b = K/(2*(x2-x3));
//echo("b=",b);
yt = -(a*(b-x2)-y2)/(2*(a+1));
//echo("yt=",yt);
xt = a*yt+b;
//echo("xt=",xt);

// Calculation of dent's linear pattern
RadExtDent = D+Rad2+RadDent-Pen;

// Modelling

// dent module
module dent() {
  cylinder(2*Rad2,r=RadDent, center = false);
}
//dent();

module coinbody() {
    // coin
    rotate_extrude(angle=360, convexity=10)
    //section to revolute
    difference(){
        union(){
            // base
            // color("red") 
            square([D,yt]);
            // external rounding
            // color("green") 
            translate([D,Rad2,0]) circle(r=Rad2);
        }
        // cutting circle
        // color("blue") 
        translate([0,Rad1+Rad3,0]) circle(r=Rad3, $fn=120);
    }
}

module dentedbody() {
    difference(){
        coinbody();
         // polar pattern of the dent
        step = 360/NbDent;
        r = RadExtDent;
        for (i=[0:step:359]){
            angle = i;
            dx = r*cos(angle);
            dy = r*sin(angle);
            translate([dx,dy,0]) dent();
        }
    }
}

module vertround() {
    difference() {
        translate([0,0,-1]) cylinder(h=2*Rad2+2, r=2*D+4, $fn=30);
        
        linear_extrude(height = 2*Rad2, center = false, convexity = 10)
            offset(r=3.01) offset(r=-3) projection(cut=false) dentedbody();
    }
}

difference(){   
    dentedbody();
    vertround();
    // Engraving
    translate([0,0,2*Rad2-Pen]) linear_extrude(Pen) text("OS",size = 14, halign = "center", valign="center");
}    
