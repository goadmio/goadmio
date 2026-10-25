<?php


	$Result = SQL("select * from User where UserID='{$_SESSION['SessionUserID']}'");
	foreach ($Result as $Row)
	{
	$TotalAccounts=$Row['ResellerAccounts'];
	}
	
	$SubResellerAccounts=0;

	$Result = SQL("SELECT SUM(ResellerAccounts) AS SubResellerAccounts FROM User where CreatedBy='{$_SESSION['SessionUserID']}'");
	foreach ($Result as $Row)
	{
	$SubResellerAccounts=$Row['SubResellerAccounts'];
	}
	
	$WebsiteAccounts=RowCount("SELECT * FROM Site where UserID='{$_SESSION['SessionUserID']}'");
	$RemainAccounts=$TotalAccounts-($WebsiteAccounts+$SubResellerAccounts);

?>
