<?php

header('Content-Type: text/html; charset=UTF-8');

include("/usr/local/goadmio/include/config/config.php");
include("/usr/local/goadmio/home/go/include/function/function.php");

$RebootPassword=$_REQUEST['RebootPassword'];

echo "
				<style>
				form {padding:0px;margin:0px}
				
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

	if ($RebootPassword!="")
	{
		$Login=0;
		$Result = SQL("select * from Config and RebootPassword='$RebootPassword'");
		foreach ($Result as $Row)
		{
			$Login=1;
			$SSHPassword=$Row['SSHPassword'];

			SSH ("reboot",$SSHUsername,$SSHPassword);

			echo "Rebooting Server...";
		}
		
		if ($Login==0)
		{
		echo "Invalid Reboot Password.";
		}

	}
	else
	{
		
		echo "
		<form method='POST' action='index.php'>

		<input type='text' name='RebootPassword' placeholder='Reboot Password'>
		
		
		<input type='Submit' value='Reboot'>
		
		
		
		</form>
		";

	}

echo "
</div>
</div>
</div>
	
";				
?>