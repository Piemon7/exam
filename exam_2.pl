#!/usr/bin/perl -w 
#piemon^2016.8.12
use strict;
die "usage:perl $0 <in fasta> <min length> <max length> <length range> <out_1.stat> <out_2.result>
	eg. perl $0 PstI_MseI.fa 100 1000 25 out_1.stat out_2.result\n\n" unless @ARGV == 6;
my ($in,$min,$max,$step,$out,$out2) = @ARGV;

my %type = ();
my %len = ();
my $sum = ();
my %title = ();
open IN,$in or die $!;
$/ = ">";
<IN>;
while(<IN>){
	chomp;
	my $head = (split "\n",$_)[0];
	$_ =~ s/^$head//;
	$_ =~ s/\s+//g;
	my $len = length($_);
	$type{$len} += 1;
	$len{$len} = 1;
	$head =~ s/\_//g;
	push @{$title{$len}},$head;
	$sum += 1;
}
$/ = "\n";

open OUT,'>',$out or die $!;

print OUT "Total_num_of_frags:$sum\n";
print OUT "Total_type_of_frags:",scalar keys %type,"\n";
my @len = sort {$a<=>$b} keys %len;
print OUT "The_shortest_frag:",$len[0],"\n";
print OUT "The_longest_frag:",$len[-1],"\n";

my %region = ();
for my $k (sort {$a<=>$b} keys %type){
	next if ($k < $min or $k >= $max);
	my $k1 = int(($k - $min)/$step) + 1;
	$region{$k1} += $type{$k};
}

open T,'>',$out2 or die $!;
for my $k(sort {$a<=>$b} keys %region){
	print OUT "region_[",$min+($k-1)*$step,",",$min+$k*$step,"):",$region{$k},"\n";
	print T "region_[",$min+($k-1)*$step,",",$min+$k*$step,"):\n";
	my @unsort = ();
	for (($min+($k-1)*$step)..($min+$k*$step)){
		push @unsort,@{$title{$_}};
	}
	my @sort = map { $_->[0] } 
		sort { $a->[1]->[0] <=> $b->[1]->[0] or 
		$a->[1]->[1] <=> $b->[1]->[1] } 
		map {[$_,[ $_=~/\w+\[(\d+)\]\[(\d+)\]/]]} @unsort;
	
	print T (join "|",@sort),"\n";
}
