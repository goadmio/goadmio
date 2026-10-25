<?php

// $BrevoAPIKey = "";
// Get $BrevoAPIKey From config.php
include "/usr/local/goadmio/include/config/brevo.php";

$Domain=str_replace(["www.","webmail.","go."],"",$_SERVER['HTTP_HOST']);

if ($BrevoAPIKey!="")
{

	// Make API call
	$ch = curl_init("https://api.brevo.com/v3/senders/domains/" . urlencode($Domain));
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, ['Accept: application/json', 'api-key: ' . $BrevoAPIKey]);
	$response = curl_exec($ch);
	$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	// Simple result
	if ($httpCode == 200) {
		$data = json_decode($response, true);
		$isActive = ($data['authenticated'] == true && $data['verified'] == true);

		if ($isActive) 
		{
		$Active=1;
		}
	}

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


if (file_exists("/home/$Domain/etc/roundcube.php"))
{
include "/home/$Domain/etc/roundcube.php";
}
elseif ($BrevoAPIKey!="")
{

	if ($EmailNo>0 and $Active==1)
	{
	include "/var/go/etc/roundcube.php";
	}

}

?>