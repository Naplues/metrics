
use Understand;

($db, $status) = Understand::open("bash.udb");
	die "Error status: ", $status, "\n" if $status;

%bug_function = (); #函数bug的数目

initBuggyFunction(); #初始化hash表
parsePatch(); #解析patch文件
output();     #显示结果

$db->close();

########################子程序列表#################################################

#初始化hash表,将每个函数的bug数置为0
sub initBuggyFunction {
	print "1.Begin initialize the function hash table.\n";
	foreach my $func ($db->ents("function ~unknown ~unresolved"))
	{
		$bug_function{ $func->parent()->relname() . "->" . $func->name() } = 0;
	}
}

#解析patch补丁文件
sub parsePatch {
	print "2.Begin parse batch files...\n";
	for($i = 3;$i<=57; $i++)
	{
		$bug_file_name = "";   #bug文件名
		$bug_contents = "";    #bug的文本内容
		$bug_flag = 0;
		#读取文件
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
			}
			elsif( $line =~ /^\*\*\* / and $line =~ /\*\*\*\*$/ )  #原始bug对应行
			{
				$line =~ s/\*//g; #去掉*
				$line =~ s/ //g;
				@line_number = split(',', $line);
				$content = readSource($bug_file_name, @line_number);   #查找原文内容
				getBuggyFunctionNumber($bug_file_name, $content);  #查找对应函数
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

#计算函数的bug次数
sub getBuggyFunctionNumber {
	my $bug_file_name = $_[0];
	my $bug_content = $_[1];
	foreach my $func ($db->ents("function ~unknown ~unresolved"))
	{
		if( $func->parent()->relname eq $bug_file_name ) #该文件中的某函数
		{
			if( index($func->contents(), $bug_content) != -1 )     #该bug文本属于该函数
			{
				$bug_function{ $func->parent()->relname() . "->" . $func->name() } += 1;
			}
		}
	}
}

#输出最后结果
sub output {
	print "3.Begin output to file...\n";
	my $filename = "bash-3.2_buggy_number.csv";
	open my $filehandle, '>', $filename;
	#输出标题
	print $filehandle "FunctionName, NumberOfBugs\n";
	#输出结果
	foreach my $key ( keys %bug_function )
	{
		my $value = $bug_function{$key};
		if($value > 0)
		{
			print $filehandle $key, ", ";
			print $filehandle $value, "\n";
		}
	}
	close $filehandle or die "Cannot close the file handle\n";
	print "Output Successfuly!\n";
}