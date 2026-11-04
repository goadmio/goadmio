<?php
$SelectDomain="<select name='Domain' id='Domain' class=Select>";
$Result = SQL("select * from Site where Trash=0 $SearchSql order by Domain");
foreach ($Result as $Row)
{	
	if ($Row['Domain']==$_REQUEST['Domain'])
	{
	$SelectDomain.="<option value='{$Row['Domain']}' selected>{$Row['Domain']}</option>";
	}
	else
	{
	$SelectDomain.="<option value='{$Row['Domain']}'>{$Row['Domain']}</option>";
	}
}
$SelectDomain.="</select>";