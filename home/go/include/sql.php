<?php

if ($SortBy=="") {$SortBy=$DefaultSortBy;}
if ($Direction=="")	{$Direction=$DefaultDirection;}
if ($Page=="") {$Page=1;}
$FilterSql=str_replace("\'","'",$FilterSql);
$FromRecord=($Page-1)*$PageNo;

if ($Table=="Script")
{
$SearchSql="";
}

if ($FilterSql!="") 
{
	$Sql = "select * from $Table where $Field and $FilterSql $SearchSql order by $SortBy $Direction LIMIT $FromRecord,$PageNo";
}
elseif ($SearchFor=="")
{
	$Sql = "select * from $Table where $Field $SearchSql order by $SortBy $Direction  LIMIT $FromRecord,$PageNo";
}
else
{
	include "include/search.php";
}

$RowsNo=RowCount($Sql,$Table);

?>