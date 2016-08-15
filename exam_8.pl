#!/usr/bin/perl -w
#piemon^2016.8.13 泰勒级数
use strict;

die "usage:perl $0 <iteration number>
	perl $0 1000000 \n\n" unless @ARGV == 1;

my ($num,$p) = @ARGV;
my $m;
for (my $i=1;$i<=$num;$i++){
	$m += (-1)**($i-1) * 1** (2*$i-1)/(2*$i -1);
}

my $pi = $m*4;

printf "pi: %.100f",$pi;
print "\n";
