#!/usr/bin/perl -w 
#piemon^2016.8.13
use strict;
die "usage:perl $0 <vcf> <genotype> <out>\n\n" unless @ARGV == 3;
my ($vcf,$geno,$out) = @ARGV;

my %bases=(
	"A" => "A A",
	"G" => "G G",
	"C" => "C C",
	"T" => "T T",
	"M" => "A C",
	"K" => "G T",
	"Y" => "C T",
	"R" => "A G",
	"W" => "A T",
	"S" => "C G",
	"-" => "- -",
	"N" => "N N",
);

if ($vcf =~ /\.gz$/){
	open IN,"gzip -dc $vcf|" or die $!;
}
else{
	open IN,$vcf or die $!;
}
my %hash;
while(<IN>){
	next if (/^#/);
	$_ =~ /AF1=([^;]+);/;
	my $AF = $1;
	#print $AF,"\n";
	my ($chr,$pos) = (split /\t/,$_)[0,1];
	my $k = join "\t",($chr,$pos);
	$hash{$k} = $AF;
}
print "vcf done\n";

open IN,$geno or die $!;
open T,'>',$out or die $!;
while(<IN>){
	chomp;
	my @line = split;
	my ($chr,$pos,$ref) = @line[0..2];
	my $str = join "\t",@line[3..$#line];
	#print $str,"\n";
	my %re = &allele($str);
	my @keys;
	my @count;
	for (sort {$re{$b} <=> $re{$a}} keys %re){
		push @keys,$_;
		push @count,$re{$_};
	}
	#print "@count\n";
	next if ($count[2] != 0);##there are three alleles;actually,only $count[0] and $count[1] have the value;
	next if ($count[1] == 0);##This is not SNP.
	my $major = shift @keys;
	my $minor = shift @keys;

	my $last = $hash{join "\t",($chr,$pos)};
	print T "$chr\t$pos\t$ref\t";
	print T "$major\t",$count[0]/($count[0]+$count[1]),"$minor\t";
	print T $count[1]/($count[0]+$count[1]),"\t$last\n";
}

sub allele{
	my ($str) = @_;
	for (keys %bases){
		$str =~ s/$_/$bases{$_}/g;
	}
	#print $str;
	my %frequency = ('A' => 0,'G' => 0,'C' => 0,'T' => 0);
	$frequency{'A'} += $str =~ tr/A//;
	$frequency{'G'} += $str =~ tr/G//;
	$frequency{'C'} += $str =~ tr/C//;
	$frequency{'T'} += $str =~ tr/T//;
	
 	return %frequency;
}
