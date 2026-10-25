<?php

include "navigator.php";
$Buttons="";
include "title.php";

$Active=$_REQUEST['Active'];
$RoundcubeSMTPActive=$_REQUEST['RoundcubeSMTPActive'];


if ($Action=="Active")
{

	if ($_REQUEST['RoundcubeSMTPActive']=="1")
	{
		SQL("update Config set RoundcubeSMTPActive=0");	
	}
	else
	{
		SQL("update Config set RoundcubeSMTPActive=1");
	}
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/roundcubeglobalsmtp'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}


			$Result = SQL("select * from Config");
			foreach ($Result as $Row)
			{

				$RoundcubeSMTPHost=$Row['RoundcubeSMTPHost'];
				$RoundcubeSMTPPort=$Row['RoundcubeSMTPPort'];
				$RoundcubeSMTPUser=$Row['RoundcubeSMTPUser'];
				$RoundcubeSMTPPass=$Row['RoundcubeSMTPPass'];
				$RoundcubeSMTPActive=$Row['RoundcubeSMTPActive'];
				
				if ($RoundcubeSMTPActive==1)
				{
				$RoundcubeSMTPActiveChecked="checked";
				}
			}
			
echo "
<div class=NavigatorInfo>
To have Roundcube use a custom SMTP relay (e.g., Brevo, SendPulse) while keeping SnappyMail webmail and all other email clients (Outlook, Thunderbird, etc.) on the same server using the default local SMTP, clarify that this feature will cover all emails (all domains) sent on the server while those sent via Roundcube, but each domain can override this feature using 'Roundcube Custom SMTP'.
</div>
";

echo "
<div class=DivCheckbox>

	<label class=LabelCheckbox onclick=\"javascript:Load('$CurrentFileName?Action=Active&RoundcubeSMTPActive=$RoundcubeSMTPActive')\">Enable Roundcube Global SMTP
		<input type='checkbox' name='RoundcubeSMTPActive' id='RoundcubeSMTPActive' value='1' $RoundcubeSMTPActiveChecked>
		<span class='Checkbox'></span>
	</label>

</div>
";

if ($RoundcubeSMTPActive==1)
{
echo "			
<div class='DivInput {$Dir}DivInput'>SMTP Hostname:<br>
<input type='text' value='$RoundcubeSMTPHost' id='RoundcubeSMTPHost' onchange=\"Config('RoundcubeSMTPHost',encodeURI(document.getElementById('RoundcubeSMTPHost').value))\" class=InputText>			
</div>

<div class='DivInput {$Dir}DivInput'>SMTP Port:<br>
<input type='text' value='$RoundcubeSMTPPort' id='RoundcubeSMTPPort' onchange=\"Config('RoundcubeSMTPPort',encodeURI(document.getElementById('RoundcubeSMTPPort').value))\" class=InputText>
</div>

<div class='DivInput {$Dir}DivInput'>{$LNG['SMTPUsername']}:<br>
<input type='text' value='$RoundcubeSMTPUser' id='RoundcubeSMTPUser' onchange=\"Config('RoundcubeSMTPUser',encodeURI(document.getElementById('RoundcubeSMTPUser').value))\" class=InputText>
</div>

<div class='DivInput {$Dir}DivInput'>{$LNG['SMTPPassword']}:<br>
<input type='text' value='$RoundcubeSMTPPass' id='RoundcubeSMTPPass' onchange=\"Config('RoundcubeSMTPPass',encodeURI(document.getElementById('RoundcubeSMTPPass').value))\" class=InputText>
</div>
";
}

?>