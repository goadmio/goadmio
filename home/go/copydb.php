</TD><?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}

$Domain=ValidateDomain($_REQUEST['Domain']);

$Name=ValidateDatabaseName($_REQUEST['Name']);
$User=ValidateUsername($_REQUEST['User']);
$Pass=ValidatePassword($_REQUEST['Pass']);
$Source=ValidateDatabaseName($_REQUEST['Source']);


if ($_REQUEST['Domain']!="")
{
	include "access.php";

	$ProgressFile="$Name.log";
	$Error=SSH ("sudo screen -d -m bash -c '/go/copydb $Domain $Name $User '$Pass' $Source > /var/log/go/progress/$ProgressFile'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Running in background.");

	echo Progress($ProgressTitle,$ProgressFile);

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;
}


	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

	<div <div class='TitleB {$Dir}TitleB'>{$LNG['CopyFrom']}</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['MySQLDatabase']}<br>

		<select name='Source' class=Select>
		";
		
		$Sql = "select * from Mysql where MysqlID>=1 order by Name";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			echo "<option value='{$Row['Name']}'>{$Row['Name']} ({$Row['Domain']})</option>";
		}
		
		echo "
		</select>
	
	</div>

	<div <div class='TitleB {$Dir}TitleB'>{$LNG['CopyTo']}</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>

		<select name='Domain' class=Select>
		";
		
		$Sql = "select * from Site where Trash=0 $SearchSql order by Domain";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			if ($Row['Domain']==$Domain)
			{
			echo "<option value='{$Row['Domain']}' selected>{$Row['Domain']}</option>";
			}
			else
			{
			echo "<option value='{$Row['Domain']}'>{$Row['Domain']}</option>";
			}
		}
		
		echo "
		</select>
	
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['DatabaseName']}<br>
	<input type='Text' name='Name' value='$Name' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['DatabaseUsername']}<br>
	<input type='Text' name='User' value='$User' autocomplete='off' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Password']}<br>
	<input type='password' name='Pass' id='Password' autocomplete='off' pattern='^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$' title='Must contain at least one number, one uppercase letter, one lowercase letter, and be at least 8 characters long' autocomplete='new-password' required maxlength=100 class=InputText>
	</div>
	
	<div id=DivSubmit class=DivSubmit>
	";
	
		if ($Edit==1)
		{
			echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
		}
		else
		{
			echo "<input type=submit value='{$LNG['Copy']}' Class=InputButton>";
		
		}
		
	echo "
	</div>

</form>
";

?>