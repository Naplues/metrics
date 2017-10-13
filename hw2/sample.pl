#!/usr/bin/perl
 
$string = "welcome to runoob site.";
$string =~ /run/;
print "匹配前的字符串: $`\n";
print "匹配的字符串: $&\n";
print "匹配后的字符串: $'\n";


@names = ();
$names[0] = 'John';
$names[1] = 'Mike';
$names[2] = 'gzq';

foreach my $name (@names)
{
	print $name, "  ";
}
print "\n";