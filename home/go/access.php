<?php

$Access=0;

if ($_SESSION['SessionUserID']==1)
{
	$Access=1;
}

if ($_SESSION['SessionType']=="Website")
{
	if (is_array($_SESSION['SessionDomains']))
	{
		if (in_array($Domain,$_SESSION['SessionDomains']))
		{
			$Access=1;
		}
	}
}

if ($_SESSION['SessionType']=="Reseller")
{
	$Result = SQL("select * from Site where UserID=?", [$_SESSION['SessionUserID'] ?? 0]);
	foreach ($Result as $Row)
	{
	$Access=1;
	}
}

if ($Access==0)
{
	echo Error("Sorry, You are not allowed to access this page");
	exit;
}

?>