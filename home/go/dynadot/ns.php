<?php

$Domain=$_REQUEST['Domain'];
$DynadotAPIKey=$_REQUEST['DynadotAPIKey'];
$NS1=$_REQUEST['NS1'];
$NS2=$_REQUEST['NS2'];


$URL="https://api.dynadot.com/api3.xml?key={$DynadotAPIKey}&command=set_ns&domain={$Domain}&ns1={$NS1}&ns2={$NS2}";


$ch = curl_init();
curl_setopt_array($ch, [
    CURLOPT_URL => $URL,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_HTTPGET => true, 
    CURLOPT_SSL_VERIFYPEER => false,
    CURLOPT_TIMEOUT => 30,
]);

$Response = curl_exec($ch);

if (curl_errno($ch)) 
{
    echo curl_error($ch);
} 
else 
{

	if (stristr($Response,"<Status>success</Status>"))
	{
    echo "Dynadot: Nameservers updated successfully";
	}
	else
	{
			
		if (preg_match('#<Error>(.*?)</Error>#s', $Response, $Error)) 
		{
			echo "Dynadot: {$Error[1]}";
		} 
		else 
		{
			echo "Dynadot: $Response";
		}
	
	}
	
}

curl_close($ch);
?>