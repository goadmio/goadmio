<?php


	function GetDns($Domain) 
	{ 
	$Ext = substr("$Domain",-2); 

		if($Ext==uk) 
		{
		$type=uk;
		} 
		else 
		{
		$type=com;
		}         

		if($type==uk) 
		{
		$Server="whois.nic.uk";
		} 
		else
		{
		$Server="rs.internic.net";
		} 
	
		$fp = fsockopen( "$Server",43, &$errno, &$errstr, 10); 
		fputs($fp, "$Domain\r\n"); 
	                        
		while(!feof($fp)) 
		{ 
		$buf = fgets($fp,128); 

			if (ereg( "Domain servers", $buf)) 
		        { 
	        {
		$dns = fgets($fp,128);
		} 
	
		{
		$dns .= fgets($fp,128);
		} 
	
	        } 

		if (ereg( "Name Server:", $buf)) 
		{ 

		{
		$dns = fgets($fp,128);
		} 

	        {
		$dns .= fgets($fp,128);
		} 

		$dns = str_replace( "Name Server:",  "", $buf); 
	        $dns = str_replace( "Server:",  "", $dns);   
	        $dns = trim($dns); 
	        }   
	    } 
	    Return $dns; 
	}

function GetDomainExpire($Domain) 
{ 
    $Ext = substr("$Domain",-2); 
    if($Ext==uk) 
    {$type=uk;} 
    else 
    {$type=com;}         

    if($type==uk) 
    {$Server="whois.nic.uk";} 
    else{$Server="rs.internic.net";} 

    $fp = fsockopen( "$Server",43, &$errno, &$errstr, 10); 

    fputs($fp, "$Domain\r\n"); 
                        
    while(!feof($fp)) 
    { 
        $buf = fgets($fp,128); 

        if (ereg( "Expiration Date:", $buf)) 
        { 
            {$ExpiresOn = fgets($fp,128);} 
            {$ExpiresOn .= fgets($fp,128);} 
        } 
        if (ereg( "Expiration Date:", $buf)) 
        { 
            {$ExpiresOn = fgets($fp,128);} 
            {$ExpiresOn .= fgets($fp,128);} 
            $ExpiresOn = str_replace( "Expiration Date:",  "", $buf); 
            $ExpiresOn = trim($ExpiresOn); 
        }   
    }

    $ExpiresOn = str_replace("jan", "01",$ExpiresOn);
    $ExpiresOn = str_replace("feb", "02",$ExpiresOn);
    $ExpiresOn = str_replace("mar", "03",$ExpiresOn);
    $ExpiresOn = str_replace("apr", "04",$ExpiresOn);
    $ExpiresOn = str_replace("may", "05",$ExpiresOn);
    $ExpiresOn = str_replace("jun", "06",$ExpiresOn);
    $ExpiresOn = str_replace("jul", "07",$ExpiresOn);
    $ExpiresOn = str_replace("aug", "08",$ExpiresOn);
    $ExpiresOn = str_replace("sep", "09",$ExpiresOn);
    $ExpiresOn = str_replace("oct", "10",$ExpiresOn);
    $ExpiresOn = str_replace("nov", "11",$ExpiresOn);
    $ExpiresOn = str_replace("dec", "12",$ExpiresOn);

    $DomainExpiresOn=SubStr($ExpiresOn,6,4)."-".SubStr($ExpiresOn,3,2)."-".SubStr($ExpiresOn,0,2);

    Return $DomainExpiresOn; 
} 


	// تحديد اذا كان الدومين متاح ام لا
	function CheckDomain($DomainName,$Ext)
	{

		$Sql = "select * from Extension where Extension='$Ext'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
	        $Server=$Row['Server'];
	        $NoMatch=$Row['NoMatch'];
		}



	
	    $output="";
		
		    if(($sc = @fsockopen($Server,43))==false)
			{
			echo"$DomainName.$Ext : The script could not connect to whois server : $Server";
			}
			else
			{
			    fputs($sc,"$DomainName.$Ext\n");
			    while(!feof($sc)){$output.=fgets($sc,128);}
			    fclose($sc);
			    //compare what has been returned by the server
			    if (eregi($NoMatch,$output)){
			        return false;
			    }else{
			        return true;
		   }
	    }
	}


	// Whois Domain
	function WhoisDomain($DomainName,$Ext)
	{   
		$Sql = "select * from Extension where Extension='$Ext'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
	        $Server=$Row['Server'];
	        $NoMatch=$Row['NoMatch'];
		}




	    if(($sc = fsockopen($Server,43))==false){
	        if(($sc = fsockopen($Server,43))==false){
	            echo"There is a temporary service disruption Please again try later";
	            exit;
	        }
	    }
	    if($Ext=="com"||$Ext=="net"){
	        //
	        fputs($sc, "$DomainName.$Ext\n");
	        while(!feof($sc)){
	            $temp = fgets($sc,128);
	            if(ereg("Whois Server:", $temp)) {
	                $Server = str_replace("Whois Server: ", "", $temp);
	                $Server = trim($Server);
	            }
	        }
	        fclose($sc);
	        if(($sc = fsockopen($Server,43))==false)
		{
	            echo"There is a temporary service disruption Please try later";
	            exit;
	        }
	    }
	
	    $output="";
	    fputs($sc,"$DomainName.$Ext\n");
	    while(!feof($sc)){$output.=fgets($sc,128);}
	    fclose($sc);

		$output=explode("\n",$output);
	
		$Lines=count($output);
	
		for ($x=1 ;$x<=$Lines; $x++)
		{
		Echo "$output[$x] <br />";
		}
	}

	// Whois IP
	function WhoisIP($WhoisServerIP)
	{   
	        $Server="whois.arin.net";
	        $NoMatch="No match";

	    if(($sc = fsockopen($Server,43))==false){
	        if(($sc = fsockopen($Server,43))==false){
	            echo"There is a temporary service disruption Please again try later";
	            exit;
	        }
	    }

	    if($Ext=="com"||$Ext=="net"){
	        //
	        fputs($sc, "$WhoisServerIP\n");
	        while(!feof($sc)){
	            $temp = fgets($sc,128);
	            if(ereg("Whois Server:", $temp)) {
	                $Server = str_replace("Whois Server: ", "", $temp);
	                $Server = trim($Server);
	            }
	        }
	        fclose($sc);
	        if(($sc = fsockopen($Server,43))==false)
		{
	            echo"There is a temporary service disruption Please try later";
	            exit;
	        }
	    }
	
	    $output="";
	    fputs($sc,"$WhoisServerIP\n");
	    while(!feof($sc)){$output.=fgets($sc,128);}
	    fclose($sc);

		$output=explode("\n",$output);
	
		$Lines=count($output);
	
		for ($x=1 ;$x<=$Lines; $x++)
		{
		Echo "$output[$x] <br />";
		}
	}


?>
