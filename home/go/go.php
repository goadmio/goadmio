<?php
include "navigator.php";
$Buttons="";
include "title.php";

$FullName=trim($_REQUEST['FullName']);

$Mobile=trim($_REQUEST['Mobile']);
$Mobile=preg_replace("/[^0-9]/","",$Mobile);

$Email=trim($_REQUEST['Email']);

if ($Email!="" or $Mobile!="")
{
	
	SQL("UPDATE Site SET FullName='$FullName',Mobile='$Mobile',Email='$Email' where Domain='{$_SESSION['SessionUsername']}'");

	echo Error("Your contact information and preferences have been updated.");
	
	
	exit;
}

$Result = SQL("select * from Site where Domain='{$_SESSION['SessionUsername']}'");
foreach ($Result as $Row)
{
	$FullName=$Row['FullName'];
	$Mobile=$Row['Mobile'];
	$Email=$Row['Email'];
}

if ($Mobile=="")
{
$Mobile=CallCode();
}

if (!stristr($Mobile,"+"))
{
$Mobile="+{$Mobile}";
}

echo "

<div class=UnderTitle>
You may use an email address on a domain that this server hosts. However, we do not recommend this, because you may fail to receive messages when the server encounters problems. For example, if your mailbox exceeds its quota, you will not receive any new email, including notices.
</div>

<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

<div class='TitleB {$Dir}TitleB'>
Contact Information
</div>

<div class='DivInput {$Dir}DivInput'>Name<br>
<input type='text' name='FullName' id='FullName' value='$FullName' maxlength=100 required class=InputText>
</div>

<div class='DivInput {$Dir}DivInput'>Mobile<br>
<input type='text' name='Mobile' id='Mobile' value='$Mobile' maxlength=20 required class=InputText pattern='\+\d{9,}' title='Please enter a valid phone number starting with +'>
</div>

<div class='DivInput {$Dir}DivInput'>Email<br>
<input type='email' name='Email' id='Email' value='$Email' maxlength=255 required class=InputText>
</div>

<div id=DivSubmit class=DivSubmit>
<input type=submit value='Save Changes' Class=InputButton>
</div>

</form>
";
?>