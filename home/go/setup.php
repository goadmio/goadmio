<?php

	if (RowCount("SELECT * from Distro")==0)
	{
		include "update/distro.php";
	}

	if (RowCount("SELECT * from Plan")==0)
	{
		include "update/plan.php";
	}

	SQL("DELETE FROM Template");

	$Name="Default Website Page";
	$Code="<style>.Outer {display: table;height: 100%;width: 100%;}.Middle {display: table-cell;vertical-align: middle;}.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:center;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;</style><div class=Outer><div class=Middle><div class=Inner>Default Web Page www.goadmio.com</div></div></div>";
	$Description="";
	$Sql = "INSERT INTO Template (Name,Code,Description) VALUES ('$Name','$Code','$Description')";
	SQL($Sql);
	
	$Name="Account Suspended";
	$Code="<style>.Outer {display: table;height: 100%;width: 100%;}.Middle {display: table-cell;vertical-align: middle;}.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:center;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;</style><div class=Outer><div class=Middle><div class=Inner>This account has been suspended</div></div></div><META HTTP-EQUIV=\"Refresh\" Content=\"5;URL=https://www.goadmio.com\">";
	$Description="";
	$Sql = "INSERT INTO Template (Name,Code,Description) VALUES ('$Name','$Code','$Description')";
	SQL($Sql);

	$Name="Disk Quota Exceeded";
	$Code="<style>.Outer {display: table;height: 100%;width: 100%;}.Middle {display: table-cell;vertical-align: middle;}.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:center;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;</style><div class=Outer><div class=Middle><div class=Inner>Disk Quota Exceeded</div></div></div><META HTTP-EQUIV=\"Refresh\" Content=\"5;URL=https://www.goadmio.com\">";
	$Description="";
	$Sql = "INSERT INTO Template (Name,Code,Description) VALUES ('$Name','$Code','$Description')";
	SQL($Sql);

	$Name="Bandwidth Limit Exceeded";
	$Code="<style>.Outer {display: table;height: 100%;width: 100%;}.Middle {display: table-cell;vertical-align: middle;}.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:center;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;</style><div class=Outer><div class=Middle><div class=Inner>Bandwidth Limit Exceeded</div></div></div><META HTTP-EQUIV=\"Refresh\" Content=\"5;URL=https://www.goadmio.com\">";
	$Description="";
	$Sql = "INSERT INTO Template (Name,Code,Description) VALUES ('$Name','$Code','$Description')";
	SQL($Sql);

	$Name="Account Unpublished";
	$Code="Unpublished Code";
	$Description="";
	$Sql = "INSERT INTO Template (Name,Code,Description) VALUES ('$Name','$Code','$Description')";
	SQL($Sql);

	$Name="Hosting Expired";
	$Code="<title>Hosting Expired.</title><style>.Outer {display: table;height: 100%;width: 100%;}.Middle {display: table-cell;vertical-align: middle;}.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:center;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;line-height:30px}</style><div class=Outer><div class=Middle><div class=Inner>Hosting Expired.<br>You can recover an expired <a href=https://www.goadmio.com>Geelpanel</a> domain up to 25 days after it has expired.</div></div></div>";
	$Description="";
	$Sql = "INSERT INTO Template (Name,Code,Description) VALUES ('$Name','$Code','$Description')";
	SQL($Sql);

	// === EnD Template ===
	
	//$Sql = "ALTER TABLE Forward CHANGE Domain Username CHAR(32) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT ''";
	//$Result = SQL($Sql);		
	
	//$Sql = "ALTER TABLE Config ADD LoginNo INT NOT NULL DEFAULT '0' AFTER PageBarNo";
	//$Result = SQL($Sql);	

	
	
	
	
	
	
	
	
?>