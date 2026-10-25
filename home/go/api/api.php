<?php

header('Content-Type: text/html; charset=UTF-8');

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

$Name=trim($_REQUEST['Name']);
$APIKey=trim($_REQUEST['APIKey']);

$Domain = preg_replace("/^www\./","",$_SERVER['SERVER_NAME']);
$Domain = preg_replace("/^go\./","",$Domain);

echo "
				<style>
				form {padding:0px;margin:0px}
				
				input,select {width:500px;padding:10px;margin:10px}
				
				h1 {font-size:13px;font-weight:bold;text-decoration:none;margin:0px;color:#333;margin-bottom:10px;border-bottom:5px solid #cccccc;font-family:'Open Sans',Helvetica,Geneva}

				.Outer {display: table;height: 100%;width: 100%;}
				.Middle {display: table-cell;vertical-align: middle;}
				.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:center;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;}
				
				</style>

				<BR>

						<div class='Outer'>
						<div class='Middle'>
						<div class='Inner'>

";


if ($APIKey!="")
{

	if (strlen($APIKey)!=16 and strlen($APIKey)!=50) 
	{
	echo "Invalid API Key. "; echo "(".strlen($APIKey).")";
	exit;
	}

	$Sql = "select * from Config where ConfigID=1";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		$SSHPassword=$Row['SSHPassword'];
	}

	$Success=0;
	$Sql = "select * from API where Name='$Name' and APIKey='$APIKey'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		$Success=1;
		$Command=$Row['Command'];
		$Command=str_ireplace("[Domain]","$Domain",$Command);
		
	}

	if ($Success!=1)
	{
	echo "Invalid API Key.";
	exit;
	}

	if ($Command!="")
	{
		$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '$Command'",$SSHUsername,$SSHPassword);
		
		echo "$Command";
		
	}

}
else
{

		echo "
		<form method='POST' action='api.php'>

		<select name='Name'>
		";
		
		$Sql = "select * from API where Name!='' and Command!='' and Command!='all'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		echo "<option value='{$Row['Name']}'>{$Row['Name']}</option>";
		}
		
		echo "
		</select>
		
		<BR>

		<input type='text' name='APIKey' placeholder='API Key'>
		
		<BR>
		
		<input type='Submit' value='Send'>
		
		
		
		</form>
		";

}

echo "
</div>
</div>
</div>
	
";				


?>