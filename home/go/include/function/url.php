<?php 

	function ShortenUrl($Url,$UrlLong)
	{

	
		$Length = strlen($Url);
		if($Length > $UrlLong)
		{
			$Length = $Length - floor($UrlLong/3*2);
			$First = substr($Url, 0, -$Length);
			$Last = substr($Url, -floor($UrlLong/3));
			$NewUrl = $First."[ ... ]".$Last;
			return $NewUrl;
		}
		else
		{
			return $Url;
		}
	}
	
	
	
	
	function GetPageTitle($Url)
	{
		$Str = file_get_contents($Url);
		if(Strlen($Str)>0)
		{
			preg_match("/\<title\>(.*)\<\/title\>/",$Str,$Title);
			
			if ($Title[1]!="YouTube")
			{
			return $Title[1];
			}
			else
			{
			return "";
			}
		}
	}
	
	
	function GetYoutubeDescription($Code)
	{
	$Str = @file_get_contents("http://gdata.youtube.com/feeds/api/videos/$Code");

	$Str=str_ireplace("\n","",$Str);
	$Str=str_ireplace("\r","",$Str); 

	$Str=str_ireplace("<media:description type='plain'>","<description>",$Str); 
	$Str=str_ireplace("</media:description>","</description>",$Str);
	
		
	
	
		if(Strlen($Str)>0)
		{
			preg_match("/\<description\>(.*)\<\/description\>/",$Str,$Description);
			return $Description[1];
		}

	}
	

?>
