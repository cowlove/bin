#!/usr/bin/perl
$first = 1;
$showRms = 0;

if ($ARGV[0] =~ /--rms/) {
	$showRms = 1;
	shift;
}
$period = shift;

while(<>) {
	push @hist, $_;
	@tokens = split ' ';
	for my $n (0 .. $#tokens) {
		if ($first == 1) { 
			$sums[$n] = 0;
			$ssq[$n] = 0;
		}
		$sums[$n] += $tokens[$n];
		$ssq[$n] += $tokens[$n] * $tokens[$n];
	}
	$first = 0;
	if ($#hist + 1 == $period) {
		@tokens = split ' ', shift @hist;
		for my $n (0 .. $#tokens) {
			$avg = $sums[$n] / $period;
			print $avg;
			print " ";
			if ($showRms) { 
				print $ssq[$n] / $period - $avg * $avg;
				print " ";
			}
			$sums[$n] -= $tokens[$n];
			$ssq[$n] -= $tokens[$n] * $tokens[$n];
		}
		print "\n";
	}
	

}


