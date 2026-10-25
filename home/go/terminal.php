<?php
include "navigator.php";

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	Echo "
	Sorry, You Are Not Allowed to Access This Page
	";

exit;
}

if ($DemoPassword!="")
{
echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);
exit;
}

$Domain = preg_replace("/^go\./","",$_SERVER['SERVER_NAME']);

if ($Domain=="")
{
$Domain="-";
}

Echo "
<div class=NavigatorInfo>
To access Terminal directly, navigate to <a href='http://$Domain:2222' target='_blank'>http://$IPv4:2222</a></span>
</div>
";

include "title.php";

$SSH=$_REQUEST['SSH'];
$SSHFontSize=$_REQUEST['SSHFontSize'];

if ($SSHFontSize!="")
{
	$Sql = "UPDATE Config Set SSHFontSize='$SSHFontSize' where ConfigID=1";
	$Result = SQL($Sql);
}


if ($SSH!="")
{
	$Sql = "UPDATE Config Set SSH='$SSH' where ConfigID=1";
	$Result = SQL($Sql);

}


	$Result = SQL("select * from Config where ConfigID=1");
	foreach ($Result as $Row)
	{
		$SSH=$Row['SSH'];
		$SSHFontSize=$Row['SSHFontSize'];
		unset($_SESSION['SessionShellPassword']);
	}

	if ($SSH=="Black") {$CheckedBlack="checked";}
	if ($SSH=="White") {$CheckedWhite="checked";}
	if ($SSH=="Blue") {$CheckedBlue="checked";}
	if ($SSH=="Gray") {$CheckedGray="checked";}

	if ($SSHFontSize=="8") {$Checked8="checked";}
	if ($SSHFontSize=="10") {$Checked10="checked";}
	if ($SSHFontSize=="12") {$Checked12="checked";}
	if ($SSHFontSize=="14") {$Checked14="checked";}
	if ($SSHFontSize=="16") {$Checked16="checked";}
	if ($SSHFontSize=="18") {$Checked18="checked";}
	if ($SSHFontSize=="20") {$Checked20="checked";}
	if ($SSHFontSize=="24") {$Checked24="checked";}
	if ($SSHFontSize=="30") {$Checked30="checked";}
	if ($SSHFontSize=="36") {$Checked36="checked";}

	if (strlen($_SESSION['SessionShellPassword'])!=16)
	{
	$_SESSION['SessionShellPassword']=GeneratePassword(16);
	SSH ("sudo /go/terminal $Domain {$_SESSION['SessionShellPassword']}",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

	<div class='DivInput {$Dir}DivInput'>
	Font Size
	<br>
					
		<div class=\"radio-group-enhanced\">
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='8' onclick=\"Load('$CurrentFileName?SSHFontSize=8')\" $Checked8>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">8 PX</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='10' onclick=\"Load('$CurrentFileName?SSHFontSize=10')\" $Checked10>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">10 PX</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='12' onclick=\"Load('$CurrentFileName?SSHFontSize=12')\" $Checked12>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">12 PX</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='14' onclick=\"Load('$CurrentFileName?SSHFontSize=14')\" $Checked14>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">14 PX</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='16' onclick=\"Load('$CurrentFileName?SSHFontSize=16')\" $Checked16>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">16 PX</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='18' onclick=\"Load('$CurrentFileName?SSHFontSize=18')\" $Checked18>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">18 PX</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='20' onclick=\"Load('$CurrentFileName?SSHFontSize=20')\" $Checked20>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">20 PX</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='24' onclick=\"Load('$CurrentFileName?SSHFontSize=24')\" $Checked24>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">24 PX</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='30' onclick=\"Load('$CurrentFileName?SSHFontSize=30')\" $Checked30>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">30 PX</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSHFontSize' value='36' onclick=\"Load('$CurrentFileName?SSHFontSize=36')\" $Checked36>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">36 PX</span>
			</label>		
		</div>

	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['Style']}
	<br>

		<div class=\"radio-group-enhanced\">
		
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSH' value='Black' onclick=\"Load('$CurrentFileName?SSH=Black')\" $CheckedBlack>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">{$LNG['Black']}</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSH' value='White' onclick=\"Load('$CurrentFileName?SSH=White')\" $CheckedWhite>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">{$LNG['White']}</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSH' value='Blue' onclick=\"Load('$CurrentFileName?SSH=Blue')\" $CheckedBlue>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">{$LNG['Blue']}</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' name='SSH' value='Gray' onclick=\"Load('$CurrentFileName?SSH=Gray')\" $CheckedGray>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">{$LNG['Gray']}</span>
			</label>
		</div>


	</div>


	<div class='DivInput {$Dir}DivInput'>
	</div>

	<div id=DivSubmit class=DivSubmit>
	";
	

	if (strpos($_SERVER['SERVER_NAME'],"go.") === 0)
	{
	echo "<input type='button' value='Connect using SSH' class=InputButton onclick=\"window.open('https://root:{$_SESSION['SessionShellPassword']}@$Domain:2222')\">";
	}
	else
	{
	echo "<input type='button' value='Connect using SSH' class=InputButton onclick=\"window.open('http://root:{$_SESSION['SessionShellPassword']}@$IPv4:2222')\">";		
	}
	
	echo "
	</div>

	</form>
	

</div>


";
	


?>