<?php

$Domain=$_REQUEST['Domain'];
$ResellerclubUserID=$_REQUEST['ResellerclubUserID'];
$ResellerclubAPIKey=$_REQUEST['ResellerclubAPIKey'];
$Domain=$_REQUEST['Domain'];
$AuthCode=$_REQUEST['AuthCode'];

$ch = curl_init();
                              
curl_setopt($ch, CURLOPT_URL,"https://test.httpapi.com/api/domains/orderid.json?auth-userid=$ResellerclubUserID&api-key=$ResellerclubAPIKey&domain-name=$Domain");
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
$OrderID = curl_exec($ch);
curl_close($ch);

if (intval($OrderID)>=1)
{
	$ch = curl_init();
	
	curl_setopt($ch, CURLOPT_URL,"https://test.httpapi.com/api/domains/modify-auth-code?auth-userid=$ResellerclubUserID&api-key=$ResellerclubAPIKey&order-id=$OrderID&domain=$Domain&auth-code=$AuthCode");
	curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
	curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
	$Rusult = curl_exec($ch);
	curl_close($ch);

	if (stristr($Rusult,"Successfully"))
	{
	echo "ResellerClup: Auth Code updated successfully";
	}
	else
	{
	echo "ResellerClup: $Rusult";
	}

}
else
{

	if (stristr($OrderID,"Invalid credentials"))
	{
	echo "ResellerClup: Invalid credentials";
	}
	elseif (stristr($OrderID,"Required authentication"))
	{
	echo "ResellerClup: API Key missing";
	}	
	elseif (stristr($OrderID,"doesn't exist"))
	{
	echo "ResellerClup: Domain $Domain not exists";
	}
	else
	{
	echo "ResellerClup: $OrderID";
	}
}