<?php

$Domain=trim($_REQUEST['Domain']);
$ResellerclubUserID=trim($_REQUEST['ResellerclubUserID']);
$ResellerclubAPIKey=trim($_REQUEST['ResellerclubAPIKey']);
$NS1=trim($_REQUEST['NS1']);
$NS2=trim($_REQUEST['NS2']);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL,"https://test.httpapi.com/api/domains/orderid.json?auth-userid=$ResellerclubUserID&api-key=$ResellerclubAPIKey&domain-name=$Domain");
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
$OrderID = curl_exec($ch);
curl_close($ch);

if (intval($OrderID)>=1)
{
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL,"https://test.httpapi.com/api/domains/modify-ns.json?auth-userid=$ResellerclubUserID&api-key=$ResellerclubAPIKey&order-id=$OrderID&ns=$NS1&ns=$NS2");
	curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
	curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
	$Rusult = curl_exec($ch);
	curl_close($ch);

	if (stristr($Rusult,"Successfully"))
	{
	echo "ResellerClup: Nameservers updated successfully";
	}
	elseif (stristr($Rusult,"Same value"))
	{
	echo "ResellerClup: Same nameservers";
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
		if (stristr($OrderID,"<"))
		{
		echo "ResellerClup: Unknown";
		}
		else
		{
		echo "ResellerClup: $OrderID";
		}
	}
}