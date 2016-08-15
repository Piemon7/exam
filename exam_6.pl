#!/usr/bin/perl -w
#piemon^2016.8.13
use strict;
die "usage:perl $0 <fa> <gff> <out> 
	eg. perl exam_6.pl test.fa test.gff exam_out.txt\n\n" unless @ARGV ==3;
my ($fa,$gff,$out) = @ARGV;

my %ref;
open IN,$fa or die $!;
$/ = ">";
<IN>;
while(<IN>){
	chomp;
	my $head = (split /\n/,$_)[0];
	$_ =~ s/^$head//;
	$_ =~ s/\s+//g;
	$_ =~ tr/[agctn]/[AGCTN]/;
	$ref{$head} = $_;
}
$/ = "\n";


open IN,$gff or die $!;
open T,'>',$out or die $!;
$/ = "\tmRNA\t";
<IN>;
while(<IN>){
	chomp;
	my @line = split "\n",$_;
	$line[0] =~ /^(\d+)\t(\d+)\t.*ID=([^;]+);/;
	my $start = $1;
	my $end = $2;
	my $id = $3;
	my $chrome;
	my @utr;
	for(1..$#line-1){
		my ($chr,$type,$pos1,$pos2) = (split /\t/,$line[$_])[0,2..4];
		$chrome = $chr;
		push @utr,(join "\t",($pos1,$pos2)) if ($type eq 'UTR_5' or $type eq 'UTR_3');
	}

	my $mrna = substr ($ref{$chrome},$start-1,$end-$start+1);
	
	print T ">$id\n";
	if (scalar @utr == 0){
		print T $mrna,"\n";
	}
	else{
		for(@utr){
			my ($pos1,$pos2) = split /\t/,$_;
			my $UTR = substr($ref{$chrome},$pos1-1,$pos2-$pos1+1);
			my $utr = $UTR;
			$utr =~ tr/[AGCTN]/[agctn]/;
			$mrna =~ s/$UTR/$utr/;
			#$mrna = substr($mrna,$pos1-$start,$pos2-$pos1+1);
		}
		print T $mrna,"\n";
	}
}
$/ = "\n";