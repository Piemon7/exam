#!/usr/bin/perl -w
#piemon^2016.8.13
use strict;
die "usage:perl $0 <user name>
	eg. perl $0 shichunwei
		perl $0 \n\n" unless @ARGV >= 0;

my $usr = ();
if (scalar @ARGV == 0){
	$usr = `whoami`;
	chomp $usr ;
}
else{
	$usr = $ARGV[0];
}

my %queue;
my @qhost = `/opt/gridengine/bin/linux-x64/qhost`;
for(3..$#qhost){
	chomp;
	my ($q,$cpu,$mem) = (split /\s+/,$qhost[$_])[0,2,4];
	$queue{$q} = [$cpu,$mem];
}
#for (keys %queue){
#	print $_,"\t","@{$queue{$_}}\n";
#}

#print "username: $usr\n";
print "Job_Name\tJob_ID\tStatus\tCPU_Time\tRAM/VF\tExe_Host\tExe_Info\tError\n";

my @qstat_2 = `/opt/gridengine/bin/linux-x64/qstat -u $usr`;
my %job;

for (2..$#qstat_2){
	my ($id,$stat,$queue) = (split /\s+/,$qstat_2[$_])[0,4,7];
	my @qstat_3 = `/opt/gridengine/bin/linux-x64/qstat -j $id`;
	my ($mem_used,$mem_request,$cpu_time,$job_name,$error);
	for (@qstat_3){
		if ($_ =~ /virtual_free=(\S+)/){
			$mem_request = $1;
		}
		if ($_ =~ /cpu=(\S+),.*maxvmem=(\S+)/){
			$cpu_time = $1;
			$mem_used = $2;
		}
		if ($_ =~ /job_name:\s+(\S+)/){
			$job_name = $1;
		}
	}
	$error = "NA";
	if ($stat ne 'r'){
		$queue = "NA";
		$cpu_time = "NA";
		$mem_used = "NA";
		$error = "Error for STH" if ($stat ne 'qw');
	}

	my $list_5 = "$mem_used/$mem_request";
	
	$queue =~ /^.*@(.*)\.local$/;
	my $k = $1;
	#print $k,"\n\n\n";
	my $info = "${$queue{$k}}[1]/${$queue{$k}}[0]";
	my $out = (join "\t",($job_name,$id,$stat,$cpu_time,$list_5,$queue,$info,$error));
	print $out,"\n";
	#print "id:$id\n";
}