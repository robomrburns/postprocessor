#!/usr/bin/perl -i

#Postprocess script created by Robert Bernhard - Clausthaler Zentrum für Materialtechnik
use Math::Trig;
use Math::Round;
use strict;
use POSIX;
use warnings;

my $E = 0;
my $laseron = 0;
my $line = 100;
my $pre = 1;
my $layer = 0;
my $holdoff = 0 ;
my $EOF = 0;
my @powerramp = (1);	#Leistungsrampe hier einstellen	
my @powderramp = (1);	#Pulverrampe hier einstellen


my $X = 0;
my $Y = 0;
my $Z = 0;
my $F = 0;
my $Xo = 1;
my $Yo = 1;
my $Zo = 0;
my $Xn = 0;
my $Yn = 0;
my $dir = 0;
my $olddir = 1;
my $laseroffpath=99;
my $directiondelta = 0;
my $laserpower = 0;
my $pathlenght = 0;


my $induktorXoffset = 30;
my $induktorYoffset = 56;
my $induktorZoffset = -3;
my $xmax = 15;
my $ymax = 15;
my $xmax2 = 0;
my $ymax2 = 0;
my $indulength =0;

my $zdiff=0;
my $induction = 0;

$^I = '.bak';
# read stdin and any/all files passed as parameters one line at a time
while (<>) {
	
# Präambel	
	if ($pre==1){
	print ";Postprocessor V24.04.19\n";
	#print ";Power:  ";
	foreach my $n (@powerramp) {
	#print $n;
	#print ", ";
	}
	#print "\n;Powder: ";
	foreach my $n (@powderramp) {
		#print $n;
		#print ", ";
		}
	print "\n";
	$pre=0;
	}

#Layererkennung
	
	if (((/layer/)||(/G1 Z/&&/F/))&& $EOF==0){
		$layer=$layer+1;	
		print "; Layer $layer\n";
	}
	
	
# Induktorroutine
	
	
	if ($xmax<abs($X)){$xmax=abs($X)}
	if ($ymax<abs($Y)){$ymax=abs($Y)}
	if ((/Induktion/)&&($EOF==0)){
		$induction=1;
		print "N$line IF (R11>0) ; Induktor Aktivieren?\n";
		$line=$line+10;
		if($laseron!=0){
		print "N$line M15 H0 ;Temcon OFF\n";
		$line=$line+10;
		print "N$line M18 H0 ;Laser OFF wegen Induktor\n";
		$line=$line+10;
		}
		$zdiff=$Z+$induktorZoffset;
		print "N$line G00 X$induktorXoffset Y$induktorYoffset ; XY-Induktoroffset\n";
		$line=$line+10;
		print "N$line G00 Z$zdiff ; Z-Offset\n";
		$line=$line+10;
		print "N$line M53 H1 ; Induktor ein\n";
		$line=$line+10;
		$indulength=60*ceil($xmax+sqrt($xmax**2+$ymax**2));
		print "N$line G1 F=$indulength/R11 ; Induktionsvorschub\n";
		$line=$line+10;
		print "N$line G1 X$induktorXoffset Y$induktorYoffset ; XY-Induktoroffset\n";
		$line=$line+10;
		$xmax2=$induktorXoffset+$xmax/2;
		$ymax2=$induktorYoffset+$ymax/2;
		print "N$line G1 X$xmax2 Y$ymax2 ; XY-Induktoroffset\n";
		$line=$line+10;
		$xmax2=$induktorXoffset-$xmax/2;
		$ymax2=$induktorYoffset+$ymax/2;
		print "N$line G1 X$xmax2 Y$ymax2 ; XY-Induktoroffset\n";
		$line=$line+10;
		$xmax2=$induktorXoffset+$xmax/2;
		$ymax2=$induktorYoffset-$ymax/2;
		print "N$line G1 X$xmax2 Y$ymax2 ; XY-Induktoroffset\n";
		$line=$line+10;
		$xmax2=$induktorXoffset-$xmax/2;
		$ymax2=$induktorYoffset-$ymax/2;
		print "N$line G1 X$xmax2 Y$ymax2 ; XY-Induktoroffset\n";
		$line=$line+10;
		print "N$line G1 X$induktorXoffset Y$induktorYoffset ; XY-Induktoroffset\n";
		$line=$line+10;
		print "N$line M53 H0 ; Induktor aus\n";
		$line=$line+10;
		print "N$line G1 F$F ; Vorschub reset\n";
		$line=$line+10;
		print "N$line G0 Z$Z; zurueck zur Z-Ausgangsposition\n";
		$line=$line+10;
		print "N$line G0 X$X Y$Y; zurueck zur XY-Ausgangsposition\n";
		$line=$line+10;
		if($laseron!=0){
		print "N$line M18 H1 ;Laser ON nach Induktor\n";
		$line=$line+10;
		print "N$line M15 H1 ;Temcon ON\n";
		$line=$line+10;
		
		}
		print "N$line ENDIF\n";
		$line=$line+10;
	}
	
	
	
# Rampenfunktion der Laserleistung und der Pulverzufuhr pro Schicht	
	
	#if (($layer!=$holdoff)&&($#powderramp+1>=$layer)&&($#powerramp+1>=$layer))
	#{print "N$line M39 H=";
	#$laserpower = $powerramp[$layer-1];
	#print $laserpower;
	#print "*R0 ; Laser Leistung Schicht\n";
	#$line=$line+10;
	#print "N$line M32 H=";
	#print $powderramp[$layer-1];
	#print "*R1 ; Pulver\n";
	#$line=$line+10;
	#$holdoff = $layer;
	#}

	
# Zentrale Abfrage der Koordinaten	
	# Erfassung von E X Y Z F
		$E = $1 if /E\s*(\d+(\.\d+)?)/;
		$X = $1 if /X\s*(\d+(\.\d+)?)/;
		$Y = $1 if /Y\s*(\d+(\.\d+)?)/;
		$X = -$1 if /X-\s*(\d+(\.\d+)?)/;
		$Y = -$1 if /Y-\s*(\d+(\.\d+)?)/;
		$Z = $1 if /Z\s*(\d+(\.\d+)?)/;
		$Z = -$1 if /Z-\s*(\d+(\.\d+)?)/;
		$F = $1 if /F\s*(\d+(\.\d+)?)/;
		
# Druckprozess anhand von E-Achse erkennen und Laser An- bzw. ausschalten
	if ($laseron==0  && /E/ && (/G1/ || /G2/ || /G3/) && $E != 0 && $EOF==0) {
		print "N$line M174 ;Laser ON\n";
		$line=$line+10;
		#print "N$line M15 H1 ;Temcon ON\n";
		#$line=$line+10;
		$laseron=1;
		
	}
	elsif ($laseron!=0 && (/G0/ || /G1/ || /G2/ || /G3/) && !/E/ && $EOF==0 ) {
		#lohnt es sich, den laser auszuschalten?
		$laseroffpath = sprintf("%.2f",sqrt((($X-$Xo)**2)+(($Y-$Yo)**2)+(($Z-$Zo)**2)));
		print "; Laser AUS Travel $laseroffpath mm \n";

		if ($laseroffpath>1){
		#print "N$line M15 H0 ;Temcon OFF\n";
		#$line=$line+10;
		print "N$line M175 ;Laser OFF\n";
		$laseron=0;
		$line=$line+10;
		}
		else{
		print "; Laser bleibt an\n";
			}
	}

	s/E\s*(\d+(\.\d+)?)//es; #RegEX Entfernt Extrusion
	


if($laseron==1){$laseron=2;}

$Xo=$X;
$Yo=$Y;
$Zo=$Z;
$olddir=$dir;
$induction=0;


	if (!(/M83/||/M84/||/M104/||/G21/||/G92/||/; generated/)&& $EOF==0 )  #Liste unterdrückter Befehler
	{
	
	#line number
	if ((/M/ || /G/)&&$EOF==0) {
		print "N$line ";
		$line=$line+10;
	}
	
		
	print or die $!;}
	
	if (/M17;/||/M30;/){$EOF=1};
	
}

print "Press ANY key to exit.";
#<STDIN>;

