#!/usr/bin/perl -w
#piemon^2016.8.13 蒙特卡罗法
use strict;
die "usage:perl $0 <iteration number>
	perl $0 1000000\n\n" unless @ARGV == 1;

my ($num) = @ARGV;
my $m;
for (my $i=1;$i<=$num;$i++){
	my $x = rand(1);
	my $y = rand(1);
	#print $x,"\t",$y,"\n";
	my $sum = $x**2 + $y**2;
	if ($sum <= 1){
		$m ++;
	}
}

my $pi = 4*$m/$num;
printf "pi: ",$pi;
print "\n";
