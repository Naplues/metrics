use Understand;

($db, $status) = Understand::open("bas-3.2.udb");
die "Error status: ", $status, "\n" if $status;


foreach my $function ( sort{$a->name() cmp $b->name() } $db->ents("function ~unknown ~unresolved") )
{
	print $function->name(), "  [", $function->kindname(), "]\n";
}

$db->close();  #关闭数据库

#
use Understand;

($db, $status) = Understand::open("bash-3.2.udb");
die "Error status: ", $status, "\n" if $status;


foreach my $function ( $db->ents("Global Object ~Static") )
{
	print $function->name(),":\n";
	foreach $ref ( $function->refs() )
	{
		printf "  %-8s %-16s %s (%d,%d)\n",
		$ref->kindname(),
		$ref->ent()->name(),
		$ref->file()->name(),
		$ref->line(),
		$ref->column();
	}
	print "\n";
}

$db->close();  #关闭数据库