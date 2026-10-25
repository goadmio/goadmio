<?php

$SearchFor=trim($SearchFor);

$FieldNameString=Column($Table,"2",$SearchFor,"like");

if ($SearchSql=="")
{
	$Sql = "select * from $Table where $FieldNameString order by $SortBy $Direction LIMIT $FromRecord,$PageNo";
	
}
else
{
	$Sql = "select * from $Table where ($FieldNameString) $SearchSql order by $SortBy $Direction LIMIT $FromRecord,$PageNo";
}

?>