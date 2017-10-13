
use Understand;
use Encode;

#获取文件句柄
$filename = "gcc-2.8.0.csv";
open my $filehandle, '>', $filename;

#输出标题
print $filehandle "FunctionName, RelativePath, CountLineCode, CountPath, Cyclomatic, MaxNesting, Knots, CountInput, CountOutput\n";

#打开udb数据库
$db = Understand::open("gcc-2.8.0.udb");
foreach $function ($db->ents("function ~unknown ~unresolved"))
{
	print $filehandle $function->name(), ", ";
	print $filehandle $function->parent()->relname(), ", ";
	print $filehandle $function->metric("CountLineCode"), ", ";
	print $filehandle $function->metric("CountPath"), ", ";
	print $filehandle $function->metric("Cyclomatic"), ", ";
	print $filehandle $function->metric("MaxNesting"), ", ";
	print $filehandle $function->metric("Knots"), ", ";
	print $filehandle $function->metric("CountInput"), ", ";
	print $filehandle $function->metric("CountOutput"), "\n";
}

close $filehandle or die "不能关闭文件句柄";
print "成功导出数据.\n";