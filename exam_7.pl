#!/usr/bin/perl -w
#piemon^2016.8.13
use strict;
die "usage:perl $0 <sample1> <sample2> <sample3> <out>
	eg.perl exam_7.pl a-vs-b.sig.xls a-vs-c.sig.xls b-vs-d.sig.xls exam_7.out.xls\n\n" unless @ARGV ==4;

my @sample = @ARGV[0..2];
my $out = $ARGV[3];

my %hash;
my %head;
for my $sample(@sample){
	open IN,$sample or die $!;
	my $first = <IN>;
	my @tmp = split /\s+/,$first;
	$tmp[6] =~ s/\-std$//;
	$tmp[7] =~ s/\-std$//;
	$head{$tmp[6]} = 1;
	$head{$tmp[7]} = 1;
	while(<IN>){
		my ($pairwise,$name,$std_1,$std_2) = (split /\s+/,$_)[0,1,6,7];
		my ($n1,$n2) = split /\-/,$pairwise;
		$hash{$name}{$n1} = $std_1;
		$hash{$name}{$n2} = $std_2;
	}
}

open T,'>',$out or die $!;
print T "miRNAid\t";
my @order = sort keys %head;
print T (join "\t",@order),"\n";

for my $k1(keys %hash){
	print T "$k1";
	for my $k2(@order){
		$hash{$k1}{$k2} = 0.01 if (not exists $hash{$k1}{$k2});
		print T "\t$hash{$k1}{$k2}";
	}
	print T "\n";
}
