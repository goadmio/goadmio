<?php

include("/usr/local/goadmio/home/go/include/function/function.php");




function SendWhatsapp($To,$Message)
{

	global $WAInstanceID;

	$InstanceID = $WAInstanceID;
	$APIToken = '6taY79UYDujXORh28UPBhUn7TWd1MUUIM5rdGISZ98d05518';
	
	$curl = curl_init();
	curl_setopt_array($curl, [
	  CURLOPT_URL => "https://waapi.app/api/v1/instances/" . $InstanceID . "/client/action/send-message",
	  CURLOPT_RETURNTRANSFER => true,
	  CURLOPT_ENCODING => "",
	  CURLOPT_MAXREDIRS => 10,
	  CURLOPT_TIMEOUT => 30,
	  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
	  CURLOPT_CUSTOMREQUEST => "POST",
	  CURLOPT_POSTFIELDS => json_encode([
		'chatId' => "$To@c.us",
		'message' => "$Message"
	  ]),
	  CURLOPT_HTTPHEADER => [
		"accept: application/json",
		"authorization: Bearer " . $APIToken,
		"content-type: application/json"
	  ],
	]);

	$response = curl_exec($curl);
	$err = curl_error($curl);

	curl_close($curl);

	if ($err) 
	{
	  // echo "cURL Error #:" . $err;
	} else {
	  // echo $response;
	}
		
}


	$Message=$_REQUEST['Message'];

	$Result = SQL("select * from Config");
	foreach ($Result as $Row)
	{
		$AdminMobile=$Row['AdminMobile'];
		$AlternativeAdminMobile=$Row['AlternativeAdminMobile'];
		$WAInstanceID=$Row['WAInstanceID'];
	}

	if ($AdminMobile!="")
	{
	SendWhatsapp($AdminMobile,$Message);
	}

	if ($AlternativeAdminMobile!="")
	{
	SendWhatsapp($AlternativeAdminMobile,$Message);
	}

?>