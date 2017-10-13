
use Understand;

$db = Understand::open("bash-3.2.udb");

foreach my $function ($db->ents("function ~unknown ~unresolved"))
{
	#print $function->name(),",  ";
	#print $function->parent()->relname(), "\n";
}


my @bugFiles = ();



for($i = 1;$i <= 57; $i++)
{
	#读取文件
	print $i,"+++++++++++++++++++++++++++++++++++++++\n";
	my $filename = "batchs/bash32-00" . $i . ".patch";
	if( $i >= 10)
	{
		$filename = "batchs/bash32-0" . $i . ".patch";
	}
	open my $filehandle, '<', $filename;


	my $i = 0, $j = 0;

	while( my $line = <$filehandle> )
	{
		if( $line =~ /^\*\*\* / and $line !~ /\*\*\*\*$/ )  #查找每处bug的文件行
		{
			$bugFiles[$i] = $line;
			#print $line, "\n";
		}
		if( $line =~ /^--- / and $line =~ /----$/ )  #查找bug对应行
		{
			print $line,"\n";
		}
	}
	close $filehandle or die "无法关闭文件\n";
	#print "\n\n文件结束\n";
}




