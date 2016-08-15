#!/usr/bin/perl -w 
#piemon^2016.8.15
use strict;
use File::Basename;
use Getopt::Long;
my  ($dis,$out);
GetOptions(
	'i=s' => \$dis,
	'o=s' => \$out,
	);

die "usage:perl -i <distribution name> -o <outdir>
	distribution : norm,binom,beta,cauchy,chisp,exp,geom,lnorm.. \n\n" unless ($dis and $out);

if (-e $out){
	print "the file $out is already exist. Please rename the file.\n";
	exit;
}

my $dir = dirname $out;
my @dis = split ",",$dis;

my %hash = (
	'norm'    =>  "rnorm(100)", 		  						# norm
	'binom'   =>  "rbinom(100,10,0.1)", 						# binom
	'beta'    =>  "rbeta(100,1,2,ncp=0)",       				# beta 
	'cauchy'  =>  "rcauchy(100,location=0,scale = 1)",			# Cauchy
	'chisp'	  =>  "rchisq(100, 1, ncp = 0)",					# chisp
	'exp'     =>  "rexp(100, rate = 1)",						#
	'geom'    =>  "rgeom(100, 0.1)",							#
	'lnorm'   =>  "rlnorm(100, meanlog = 0, sdlog = 1)",		#
	
	);


open T,'>',"$dir/run.R";
for (@dis){
	print T "setwd('$dir')\n";
	print T "df<-$hash{$_}\n";
	print T "avg<-mean(df)\n";
	print T "cat(\"$_ average: \",avg,\"\\n\")\n";
	print T "mid<-median(df)\n";
	print T "cat(\"$_ median: \",mid,\"\\n\")\n";
	print T "std<-sd(df)\n";
	print T "cat(\"$_ Standard Deviation: \",std,\"\\n\")\n";
	print T "sort<-sort(df)\n";
	print T "cat(\"$_ number 10: \",sort\[10\],\"\\n\")\n";
	print T "cat(\"$_ number 90: \",sort\[90\],\"\\n\")\n";
	print T "write.table(df,\"$_\.txt\")\n";
	print T "cat(\"\\n\")\n";
}
system("Rscript $dir/run.R");

open T,'>',"$dir/merge.txt" or die $!;
print T "count\tvalue\ttype\n";
for my $name(@dis){
	open IN,"$dir/$name\.txt" or die $!;
	<IN>;
	while(<IN>){
		chomp;
		my @line = split;
		$line[0] =~ s/"//g;
		print T "$line[0]\t$line[1]\t$name\n";
	}
}

open T,'>',"$dir/run_2.R" or die $!;

print T "library('ggplot2')\n";
print T "setwd('$dir')\n";
print T "df<-read.table('merge.txt',header=T)\n";
print T "pdf(\"$out\")\n";
print T "ggplot(data=df) + geom_jitter(aes(x=count,y=value,size=value,position = \"jitter\",color=type)) + geom_boxplot(aes(x=25,y=value,position='dodge',fill=type)) + geom_violin(aes(x=75,y=value,fill=type))+labs(size='size',fill='')+xlab('')+ylab('value') + facet_wrap(~type)\n";
print T "dev.off()\n";

system("Rscript $dir/run_2.R");
