<?php

$SearchFor=trim($SearchFor);

$FieldNameString=Column($Table,"2",$SearchFor,"like");

if ($SearchSql=="")
{
	$SQL="select * from $Table where $FieldNameString order by $SortBy $Direction LIMIT $FromRecord,$PageNo";
}
else
{
	$SQL="select * from $Table where ($FieldNameString) $SearchSql order by $SortBy $Direction LIMIT $FromRecord,$PageNo";
}

?>