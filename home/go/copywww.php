<?php
include "navigator.php";
include "no.php";

	echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>{$LNG['CopyFilesTitle']}</div>";


$Buttons="";
include "title.php";

if ($_REQUEST['To']!="")
{
	$From=ValidateDomain($_REQUEST['From']);
	$To=ValidateDomain($_REQUEST['To']);

	include "access.php";

	if (file_exists("/home/$To/www/index.php") or file_exists("/home/$To/www/index.html") or file_exists("/home/$To/www/index.htm")) 
	{
	echo Error("{$LNG['UnableCopyFilesTheDirectory']} /home/$To/www {$LNG['IsNotEmpty']}");
	}
	else
	{
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/copywww $From $To'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("{$LNG['TransferringFilesFrom']} $From {$LNG['To']} $To...");
	}


}



	Echo "
	
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

	<div class='DivInput {$Dir}DivInput'>{$LNG['CopyFrom']}<br>
	";



		$Result = SQL("select * from Site where Trash=0 $SearchSql");
		foreach ($Result as $Row)
		{
		$Domains[]=$Row['Domain'];
		}
		
		sort($Domains);
		
		echo "
		<select name='From' id='From' class=Select>
		";
		
		foreach ($Domains as $Domain) 
		{
			if ($Domain==$_REQUEST['Domain'])
			{
			echo "<option value='$Domain' selected>$Domain</option>";
			}
			else
			{
			echo "<option value='$Domain'>$Domain</option>";
			}
		}

		echo "</select>

	</div>



	<div class='DivInput {$Dir}DivInput'>{$LNG['CopyTo']}<br>

		<select name='To' id='To' class=Select>
		";
		
		foreach ($Domains as $Domain) 
		{
			if ($Domain==$_REQUEST['Domain'])
			{
			echo "<option value='$Domain' selected>$Domain</option>";
			}
			else
			{
			echo "<option value='$Domain'>$Domain</option>";
			}
		}

		echo "
		</select>

	</div>


	<div id=DivSubmit class=DivSubmit>
	<input type=submit value='{$LNG['Copy']}' Class=InputButton>
	</div>

	
</form>

	";


?>