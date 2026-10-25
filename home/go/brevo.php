<?php

include "navigator.php";
$Buttons="
<a href='https://app.brevo.com/security/authorised_ips' class='ButtonB' target='_blan'>Authorize IP Address</a>
<a href='https://app.brevo.com/senders/domain/list' class='ButtonB' target='_blank'>Add Domain</a>
";
include "title.php";

			$Result = SQL("select * from Config");
			foreach ($Result as $Row)
			{
				$BrevoAPIKey=$Row['BrevoAPIKey'];
				$BrevoSMTPHostname=$Row['BrevoSMTPHostname'];
				$BrevoSMTPPort=$Row['BrevoSMTPPort'];
				$BrevoSMTPUsername=$Row['BrevoSMTPUsername'];
				$BrevoSMTPPassword=$Row['BrevoSMTPPassword'];
			}

	if ($BrevoAPIKey!="")
	{
	
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, 'https://api.brevo.com/v3/account');
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, [
		'Accept: application/json',
		'api-key: ' . $BrevoAPIKey
	]);

	$response = curl_exec($ch);
	curl_close($ch);

	$data = json_decode($response, true);
	$EmailNo = intval($data['plan'][0]['credits']);
	}

	$IPv4=SSH ("/usr/bin/sudo curl -s -4 checkip.amazonaws.com",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$IPv6=SSH ("/usr/bin/sudo curl -s -6 https://icanhazip.com",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

echo "
<div class=NavigatorInfo>

When enabled, outgoing emails from Roundcube are routed through the Brevo API for improved deliverability, as long as credits are available—if credits run out, the system automatically falls back to your server's default SMTP configuration without interrupting email flow. However, this feature is automatically disabled for any domain that has a custom SMTP configuration assigned. To function correctly, your domain must be verified and authenticated in Brevo (including SPF, DKIM, and tracking domain setup), and your server's public IP address must be whitelisted in your Brevo account. If your domain isn't verified or your IP hasn't been added yet, don't worry—Roundcube will continue sending emails normally using your current server's default SMTP configuration until all prerequisites are met. Note that this feature works exclusively with Roundcube; for SnappyMail or mail client apps like Outlook, please use the \"SMTP Relay\" feature instead.

</div>
";
			
echo "			
<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

<div class='DivInput {$Dir}DivInput'>Brevo API Key:<br>
<input type='text' value='$BrevoAPIKey' id='BrevoAPIKey' onchange=\"Config('BrevoAPIKey',encodeURI(document.getElementById('BrevoAPIKey').value))\" class=InputText>
</div>

<div class='DivInput {$Dir}DivInput'>Email Credits:<br>
<input type='text' value='$EmailNo' readonly class=InputText>
</div>

<div class='DivInput {$Dir}DivInput'>IPv4:<br>
<input type='text' value='$IPv4' readonly class=InputText>
</div>

<div class='DivInput {$Dir}DivInput'>IPv6:<br>
<input type='text' value='$IPv6' readonly class=InputText>
</div>

</form>
";

?>