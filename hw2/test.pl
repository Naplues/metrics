
use Understand;


($db, $status) = Understand::open("bash-3.2.udb");
	die "Error status: ", $status, "\n" if $status;

#getFunction();
readPatch();

$db->close();



#readSource("bash-3.2/parse.y", 1, 3000);


########################子程序列表#########################

#读取patch补丁文件
sub readPatch {
	my @bugFiles = ();
	
	for($i = 5;$i<=15; $i++)
	{
		$bug_file_name = "";   #bug文件名
		$bug_contents = "";    #bug的文本内容
		$bug_flag = 0;
		#读取文件
		print $i,"+++++++++++++++++++++++++++++++++++++++\n";
		my $filename = "batchs/bash32-00" . $i . ".patch";
		if( $i >= 10)
		{
			$filename = "batchs/bash32-0" . $i . ".patch";
		}
		open my $filehandle, '<', $filename;

		while( my $line = <$filehandle> )
		{
			if( $line =~ /^\*\*\* / and $line !~ /\*\*\*\*$/ )  #查找每处bug的文件行
			{
				@substr = split(' ', $line);
				#修改文件名格式
				$bug_file_name = substr($substr[1], 3, length($substr[1]) - 3 ); #去除../
				$bug_file_name =~ s/\//\\/g;  #将/改为\
				$bug_file_name =~ s/-patched//g; #去掉-patched
				$bugFiles[$i] = $bug_file_name;    
				print $bug_file_name, "\n";

			}
			elsif( $line =~ /^\*\*\* / and $line =~ /\*\*\*\*$/ )  #原始bug对应行
			{
				$line =~ s/\*//g; #去掉*
				$line =~ s/ //g;
				@line_number = split(',', $line);
				$content = readSource($bug_file_name, @line_number);   #查找原文内容
				getFunction($bug_file_name, $content);  #查找对应函数

			}
		}

		close $filehandle or die "无法关闭文件\n";
	}

}


#读取源文件,返回源文件中变动的部分
sub readSource {
	my $filename = $_[0];
	my $start = int($_[1]);
	my $end = int($_[2]);
	print $start, " ", $end, "\n";
	my $l = 0;
	my $content = "";

	open my $filehandle, '<', $filename;
	while(my $line = <$filehandle>)
	{
		$l++;
		if( $l >= $start and $l <= $end )
		{
			$content .= $line;
		}
	}

	close $filehandle;
	return $content;
}


#函数列表
sub getFunction {
	my $bug_file_name = $_[0];
	my $bug_content = $_[1];
	#print $bug_file_name, "\n";
	#print $bug_content, "\n";
	foreach my $func ($db->ents("function ~unknown ~unresolved"))
	{
		if( $func->parent()->relname eq $bug_file_name ) #该文件中的某函数
		{
			#print $func->parent()->relname, "  ", $func->name, " ", $func->metric("CountLine"), "\n";
			if($func->contents() =~ /$bug_content/xg )     #该bug文本属于该函数
			{
				print $func->name(), "-------------------------------- has a bug\n";
			}
		}
	}
}