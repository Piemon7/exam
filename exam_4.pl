#!/usr/bin/perl -w 
#piemon^2016.8.12
use strict;
die "usage:perl $0 <snp> <fasta> <gff> <exam_4.out.xls>
	eg. perl $0 Cd_Root_530M.snp.xls TAIR10_chr_all.fa TAIR10_GFF3_genes.gff3.gff.filter.gff exam_4.out.xls\n\n" unless @ARGV == 4;
my ($snp,$fasta,$gff,$out) = @ARGV;

## code
my %CODE = (
	'GCA' => 'A', 'GCC' => 'A', 'GCG' => 'A', 'GCT' => 'A',                               # Alanine
	'TGC' => 'C', 'TGT' => 'C',                                                           # Cysteine
	'GAC' => 'D', 'GAT' => 'D',                                                           # Aspartic Acid
	'GAA' => 'E', 'GAG' => 'E',                                                           # Glutamic Acid
	'TTC' => 'F', 'TTT' => 'F',                                                           # Phenylalanine
	'GGA' => 'G', 'GGC' => 'G', 'GGG' => 'G', 'GGT' => 'G',                               # Glycine
	'CAC' => 'H', 'CAT' => 'H',                                                           # Histidine
	'ATA' => 'I', 'ATC' => 'I', 'ATT' => 'I',                                             # Isoleucine
	'AAA' => 'K', 'AAG' => 'K',                                                           # Lysine
	'CTA' => 'L', 'CTC' => 'L', 'CTG' => 'L', 'CTT' => 'L', 'TTA' => 'L', 'TTG' => 'L',   # Leucine
	'ATG' => 'M',                                                                         # Methionine
	'AAC' => 'N', 'AAT' => 'N',                                                           # Asparagine
	'CCA' => 'P', 'CCC' => 'P', 'CCG' => 'P', 'CCT' => 'P',                               # Proline
	'CAA' => 'Q', 'CAG' => 'Q',                                                           # Glutamine
	'CGA' => 'R', 'CGC' => 'R', 'CGG' => 'R', 'CGT' => 'R', 'AGA' => 'R', 'AGG' => 'R',   # Arginine
	'TCA' => 'S', 'TCC' => 'S', 'TCG' => 'S', 'TCT' => 'S', 'AGC' => 'S', 'AGT' => 'S',   # Serine
	'ACA' => 'T', 'ACC' => 'T', 'ACG' => 'T', 'ACT' => 'T',                               # Threonine
	'GTA' => 'V', 'GTC' => 'V', 'GTG' => 'V', 'GTT' => 'V',                               # Valine
	'TGG' => 'W',                                                                         # Tryptophan
	'TAC' => 'Y', 'TAT' => 'Y',                                                           # Tyrosine
	'TAA' => 'U', 'TAG' => 'U', 'TGA' => 'U'                                              # Stop
);

## bases 
my %bases=(
	"M" => "AC",
	"K" => "GT",
	"Y" => "CT",
	"R" => "AG",
	"W" => "AT",
	"S" => "CG",
	"-" => "--",
	"N" => "NN",
);
## chr number
my %chr = ();
open IN,$snp or die $!;
<IN>;
while(<IN>){
	my ($chr) = (split "\t",$_)[0];
	$chr{$chr} = 1;
}

## ref
my %ref = ();
$/ = ">";
open IN,$fasta or die $!;
<IN>;
while(<IN>){
	chomp;
	my $head = (split "\n",$_)[0];
	$_ =~ s/^$head//;
	$_ =~ s/\s+//g;
	$head = (split /\s+/,$head)[0];
	$ref{$head} = $_;
}
$/ = "\n";
print "ref done.\n";

##  gff
$/ = "\tmRNA\t";
my %hash;
my %cds_fasta;
my %CDS;
open IN,$gff or die $!;
<IN>;
while(<IN>){
	chomp;
	my @line = split "\n",$_;
	my @new = @line[1..$#line-1];
	my ($tmp1,$tmp2) = (split /\s+/,$line[0])[0,1]; #test

	my @exon;
	my $CHR;
	my $Strand;
	my @cds;
	for my $new(@new){
		my ($chr,$type,$pos1,$pos2,$strand) = (split "\t",$new)[0,2,3,4,6];
		$CHR = $chr;
		$Strand = $strand;
		last if (not exists $chr{$chr});
		push @{$hash{$chr}{$type}},($pos1,$pos2);
		if ($type eq 'CDS'){
			push @cds,($pos1,$pos2);
			push @{$CDS{$chr}},($pos1,$pos2,$strand);
		}
		if ($type eq 'exon'){
			push @exon,($pos1,$pos2);
		}
	}

	push @{$hash{$CHR}{'mRNA'}},($tmp1,$tmp2);# test, the output file should not contain 'mRNA'.
	## exon region
	if (scalar @exon != 0 ){
		@exon = sort {$a<=>$b} @exon;
		for (my $i=1;$i<$#exon-1;$i+=2){
			push @{$hash{$CHR}{'intron'}},($exon[$i],$exon[$i+1]);
		}
	}
	## cds relative location.
	if (scalar @cds != 0){
		my @sort = sort {$a<=>$b} @cds;
		my $cds_1 = $sort[0];
		my $cds_2 = $sort[-1];
		my $cds_len = 0;

		if ($Strand eq '+'){
			for (my $i=0;$i<$#sort;$i+=2){
				my $k = join "\t",($sort[$i],$sort[$i+1]);
				$cds_fasta{$k} = $cds_len;
				$cds_len += $sort[$i+1] - $sort[$i] + 1;
			}
		}
		elsif($Strand eq '-'){
			for (my $i=$#sort-1;$i>=0;$i-=2){
				my $k = join "\t",($sort[$i],$sort[$i+1]);
				$cds_fasta{$k} = $cds_len;
				$cds_len += $sort[$i+1] - $sort[$i] + 1;
			}
		}
		else{
			warn;
		}
	}
}
$/ = "\n";
print "gff done.\n";


## output 
open T,'>',$out or die $!;
print T "chr\tpos\tref\talt\tfeature\taa1\taa2\n";

my @type = ('five_prime_UTR','three_prime_UTR','CDS','exon','intron','mRNA');

open IN,$snp or die $!;
<IN>;
while(<IN>) {
	my ($chr,$pos,$ref,$alt) = (split "\t",$_)[0..3];
	print T "$chr\t$pos\t$ref\t$alt\t";
	my $feature = ();
	for my $k1(@type){
		last if (defined $feature);
		next if (not exists $hash{$chr}{$k1});
		my @a = @{$hash{$chr}{$k1}};
		for (my $i=0;$i<$#a;$i+=2){
			if ($a[$i] <= $pos and $pos <= $a[$i+1]){
				$feature = $k1;
				last;
			}
		}
	}

	$feature = "intergenetic" if (!defined $feature);
	print T "$feature\t";
	#print T "\n";

	if ($feature eq 'CDS'){
		my @cds = @{$CDS{$chr}};
		my ($start,$end,$strand);
		for (my $i=0;$i<$#cds;$i+=3){
			if ($cds[$i] <= $pos and $pos <= $cds[$i+1] ){
				$start = $cds[$i];
				$end = $cds[$i+1];
				$strand = $cds[$i+2];
				last;
			}
		}
		### cds sequence 
		#my $cds_seq = $cds_fasta{join "\t",($start,$end)};

		### alt
		if (exists $bases{$alt}){
			my @a = split '',$bases{$alt};
			for(@a){
				$alt = $_ if ($_ ne $ref);
			}
			#print $ref,$alt,"\n";
		}
		### get aa1,aa2.
		my ($aa1,$aa2);
		if ($strand eq '+'){
			my $k = join "\t",($start,$end);
			if (not exists $cds_fasta{$k}){
				warn;
				exit;
			}
			my $location = $pos - $start + $cds_fasta{$k};
			my $repl = $location % 3;
			my $rep = int($location/3)*3;
			my $loc = $rep - $cds_fasta{$k} + $start;
			$aa1 = substr($ref{$chr},$loc-1,3);
			$aa1 =~ tr/acgtn/ACGTN/;
			## aa2.
			my @tmp = split '',$aa1;
			$tmp[$repl-1] = $alt;
			$aa2 = join '',@tmp;
			#print $aa1,"\t",$aa2,"\n";
		}
		elsif($strand eq '-'){
			my $k = join "\t",($start,$end);
			if (not exists $cds_fasta{$k}){
				warn;
				print $k;
				exit;
			}
			my $location = $cds_fasta{$k} + $end - $pos;
			my $repl = $location % 3;
			my $rep = int($location % 3) *3 + 3;
			my $loc = $end + $rep - $cds_fasta{$k};
			#my $loc = $end - int(($end - $pos)/3) *3 ;
			#my $rep = 2 - (($end - $pos) % 3);
			$aa1 = substr($ref{$chr},$loc-1,3);
			$aa1 =~ tr/acgtn/ACGTN/;
			$aa1 = reverse $aa1;
			$aa1 =~ tr/AGCT/TCGA/;
			
			my @tmp = split '',$aa1;
			$tmp[$repl] = $alt;
			$aa2 = join '',@tmp;
		}
		else{
			warn;
		}

		### judge synonymous mutation or not.
		if (not exists $CODE{$aa1} or  not exists $CODE{$aa2}){
			#print T "-\t-\n";
			#print "$aa1\t$aa2\n";
			next;
		}

		print T "$CODE{$aa1}\t";
		#print $aa1,"\t",$aa2,"\n";

		if ($CODE{$aa2} eq 'U'){
			print T "U\n";
		}
		elsif($CODE{$aa1} eq $CODE{$aa2}){
			print T "synonymous\n";
		}
		elsif($CODE{$aa1} ne $CODE{$aa2}){
			print T "$CODE{$aa2}\n";
		}
		else{
			warn;
		}
	}
	else{
		print T "-\t-\n";
	}
}