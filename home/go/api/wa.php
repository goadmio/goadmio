<?php

header('Content-Type: text/html; charset=UTF-8');

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

$Sql = "select * from Config where ConfigID=1";
$Result = SQL($Sql);
foreach ($Result as $Row)
{
	$SSHPassword=$Row['SSHPassword'];
}

SSH ("/usr/bin/sudo screen -d -m bash -c '/go/wa'",$SSHUsername,$SSHPassword);
	
	


?>