
sub hello {
	print "Follow is my introduction:\n";
	print "My name is ", $_[0], "\n";
	print "My age is ", $_[1], "\n";
	print "My gender is ", $_[2], "\n\n";	
}

#hello("gzq", 23, 'm');
#hello("ttt", 20, 'f');

sub Average {
	#获取所有传入的参数
	$n = scalar(@_);   #数字个数
	$sum = 0;

	foreach (@_)
	{
		$sum += $_;
	}
	$average = $sum / $n;
	print "Average of @_ is : $average\n";
}

#Average(10, 20, 30);



sub change_args {
	$new = 12;
	$_[0] = $new;
}

my $a = 10;
#print "$a\n";
change_args($a);
#print "$a\n";


#Define a function
sub PrintList {
	my @list = @_;
	print "List is : @list\n";
}

@b = (1, 2, 3, 4);

#list arguments
#PrintList($a, @b);


# Define a function
sub PrintHash {
	my (%hash) = @_;

	foreach my $key ( keys %hash )
	{
		my $value = $hash{$key};
		print "$key :  $value\n";
	}
}
%hash = ('name' => 'gzq', 'age' => 23);

# Pass hash
#PrintHash(%hash);

# Define a function
sub add_a_b {
	# Don't use return
	$_[0] + $_[1];

	# Use return
	#return $_[0] + $_[1];
}

#print add_a_b(1, 2);

$info = "Cai	ne Mi	chael Ac		tor		 14 LeafyDrive";

@personal = split(' ', $info);
#print "@personal\n";



$str1 = "abc
sdnfksjnfksdnfsd";
$str2 = "abc
s";
if( $str1 =~ /$str2/ )
{
	print "yes\n";
}
else
{
	print "no\n";
}

for($i=0;$i<100; $i++)
{
	print "hello $i\n";
}
