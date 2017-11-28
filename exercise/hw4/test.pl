use Understand;

#获取文件句柄
$filename = "Halstead.csv";
open my $filehandle, '>', $filename;

#输出标题
print $filehandle "functionName, N, V, D, E, L, T\n";

#打开数据库
$udbName = "gcc-3.4.0.udb";
($db, $status) = Understand::open($udbName);
die "Error status: ",$status,"\n" if $status;

foreach $ent ($db->ents("Function ~Unknown ~Unresolved")) {
    print $ent->name()," ", $ent->parent()->relname(), "\n";

    $input = $ent->metric("CountInput");
    $output = $ent->metric("CountOutput");
    CalcDesiredMetrics($ent, $input, $output, $filehandle);  #计算度量值
}

close $filehandle or die "Cannot close the file handle\n";
print "Output Successfuly!\n";



##########################子程序列表###################################
#计算要求的度量N, V, D, E, L, T
sub CalcDesiredMetrics {
    $ent = $_[0];
    $n_star = $_[1] + $_[2];  #n*
    $filehandle = $_[3];   #获取文件句柄
    $lexer = $ent->lexer();
    #获取基础度量
    ($n1, $n2, $N1, $N2) = GetHalsteadBaseMetrics($lexer, 1, $lexer->lines());
    $n = $n1 + $n2;
    print $n1, " ", $n2, "\n";
    $N = $N1 + $N2;
    $V = $N * log($n)/log(2);
    $V_star = (2 + $n_star) * log(2 + $n_star)/log(2);  #$n* = input + output
    $D = $V / $V_star;
    $L = 1 / $D;
    $E = $V * $D;
    $T = $E / 18;   #s 默认为18
    $NN = $n1 * log($n1) / log(2) + $n2 * log($n2) / log(2);
    
    #print $filehandle $ent->parent()->relname(), ", ";
    print $filehandle $ent->name(), ", ";
    print $filehandle $N, ", ";
    print $filehandle $V, ", ";
    print $filehandle $D, ", ";
    print $filehandle $E, ", ";
    print $filehandle $L, ", ";
    print $filehandle $T, "\n";
}

#获取Halstead基本度量值
sub GetHalsteadBaseMetrics {
    my ($lexer,$startLine,$endLine) = @_;
    my $n1=0;  #出现的操作符
    my $n2=0;  #出现的操作数
    my $N1=0;  #总操作符数目
    my $N2=0;  #总操作数数目
    
    my %n1 = ();
    my %n2 = ();
    
    foreach my $lexeme ($lexer->lexemes($startLine,$endLine)) {
        if(($lexeme->token eq "Operator") ||
                ($lexeme->token eq "Keyword") ||
                ($lexeme->token eq "Punctuation")) {  
            if($lexeme->text() !~ /[)}\]]/) {
                $n1{$lexeme->text()} = 1;
                $N1++;
            } # end if($lexeme->text() !~ /[)}\]]/)
        }elsif(($lexeme->token eq "Identifier") ||
                ($lexeme->token eq "Literal") || ($lexeme->token eq "String")){
            $n2{$lexeme->text()} = 1;
            $N2++;
        } # end if(...)
    } # end foreach my $lexeme ($lexer->lexemes($startLine,$endLine))
    
    $n1 = scalar(keys(%n1));
    $n2 = scalar(keys(%n2));  
    return ($n1,$n2,$N1,$N2);
} # end sub GetHalsteadBaseMetrics ()