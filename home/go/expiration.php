<?php

	include "navigator.php";
	$Buttons="";
	include "title.php";

	if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{

		if ($_SESSION['SessionResellerUsername']=="")
		{
		echo "
		Sorry, You Are Not Allowed to Access This Page
		";

		exit;
		}
	}

	$SiteID=intval($_REQUEST['SiteID']);
	

if ($_REQUEST['ExpiresOn']!="")
{

	$FullName=$_REQUEST['FullName'];
	$Mobile=$_REQUEST['Mobile'];
	$Email=$_REQUEST['Email'];
	$Description=$_REQUEST['Description'];
	$ExpiresOn=substr($_REQUEST['ExpiresOn'],6,4)."-".substr($_REQUEST['ExpiresOn'],3,2)."-".substr($_REQUEST['ExpiresOn'],0,2);

	$Sql = "select Domain from Site where SiteID='$SiteID'";
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$Domain=$Row['Domain'];
	}

	$Sql = "UPDATE Site SET FullName='$FullName',Mobile='$Mobile',Email='$Email',ExpiresOn='$ExpiresOn',Description='$Description' where SiteID='$SiteID'";
	$Result = SQL($Sql);
	If ($Result)
	{
	echo Error("Expiration date updated successfully.");
	}
	
}

	
	

	$Result = SQL("select * from Site where SiteID='$SiteID'");
	foreach ($Result as $Row)
	{
	$Domain=$Row['Domain'];
	$FullName=$Row['FullName'];
	$Mobile=$Row['Mobile'];
	$Email=$Row['Email'];
	$Description=$Row['Description'];
	$ExpiresOn=substr($Row['ExpiresOn'],8,2)."/".substr($Row['ExpiresOn'],5,2)."/".substr($Row['ExpiresOn'],0,4);
	}

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=SiteID value='$SiteID'>
	<input type=hidden name=ControlID value='$ControlID'>
	
	<div class='TitleB'>
	{$LNG['CustomerProfile']}
	</div>

	<div class='DivInput {$Dir}DivInput'>Domain<br>
	<input type='text' name='Domain' value='$Domain' readonly maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>Name<br>
	<input type='text' name='FullName' id='FullName' value='$FullName' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>Mobile<br>
	<input type='text' name='Mobile' id='Mobile' value='$Mobile' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>Email<br>
	<input type='text' name='Email' id='Email' value='$Email' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>Expires On<br>
	<input type='text' name='ExpiresOn' id='ExpiresOn' value='$ExpiresOn' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>Description<br>
	<textarea name='Description' rows=7 id='Description' class='TextArea DivScroll'>$Description</textarea>
	</div>

	<div id=DivSubmit class=DivSubmit>
	";
	
		if ($Edit==1)
		{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
		}
		else
		{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
		}
		
	Echo "
	</div>

</form>
";
?>