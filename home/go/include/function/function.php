<?php

function CheckPassword($Username, $Password) 
{
    // Use sudo to read /etc/shadow
    $Command = "sudo cat /etc/shadow 2>/dev/null";
    $ShadowContent = shell_exec($Command);
    
    if ($ShadowContent === null || empty($ShadowContent)) 
    {
        // Fallback to SSH2 authentication
        return CheckPasswordSSH2($Username, $Password);
    }
    
    $Lines = explode("\n", $ShadowContent);
    $UserEntry = null;
    
    // Escape the username to prevent injection
    $EscapedUsername = preg_quote($Username, '/');
    
    foreach ($Lines as $Line) 
    {
        if (preg_match("/^{$EscapedUsername}:/", $Line)) 
        {
            $UserEntry = $Line;
            break;
        }
    }
    
    if ($UserEntry === null) 
    {
        // User not found in shadow, try SSH2
        return CheckPasswordSSH2($Username, $Password);
    }

    $Parts = explode(":", $UserEntry);
    if (count($Parts) < 2) 
    {
        // Fallback to SSH2 authentication
        return CheckPasswordSSH2($Username, $Password);
    }
    
    $HashedPassword = $Parts[1];
    
    // Check if password is locked or empty
    if ($HashedPassword === "!" || $HashedPassword === "*" || empty($HashedPassword)) 
    {
        // Account locked in shadow, but try SSH2 anyway (could be valid via other auth methods)
        return CheckPasswordSSH2($Username, $Password);
    }
    
    $Result = VerifyPasswordHash($Password, $HashedPassword);
    
    // If shadow verification failed, try SSH2 as a last resort
    if ($Result === false) 
    {
        return CheckPasswordSSH2($Username, $Password);
    }
    
    return $Result;
}

function CheckPasswordSSH2($Username, $Password) 
{
	global $SSHPort;

    // Ensure SSH2 extension is loaded
    if (!function_exists('ssh2_connect')) 
    {
        return false;
    }
    
    // Try localhost and common SSH ports
    $Hosts = ['localhost','127.0.0.1'];
    $Ports = [22,$SSHPort];
    
    foreach ($Hosts as $Host) 
    {
        foreach ($Ports as $Port) 
        {
            $Connection = @ssh2_connect($Host, $Port);
            
            if ($Connection === false) 
            {
                continue;
            }
            
            // Attempt authentication with provided credentials
            if (@ssh2_auth_password($Connection, $Username, $Password)) 
            {
                // Successfully authenticated - clean up and return true
                // Note: ssh2 has no explicit disconnect, connection closes when out of scope
                return true;
            }
        }
    }
    
    return false;
}

function VerifyPasswordHash($Password, $Hash) 
{    
    // Check for crypt-style hashes (e.g., $6$ for SHA-512)
    if (preg_match('/^\$[0-9a-zA-Z]+\$/', $Hash)) 
    {
        $CalculatedHash = crypt($Password, $Hash);
        return hash_equals($CalculatedHash, $Hash);
    }
    
    // Check for old DES format (13 characters, first two chars are salt)
    if (strlen($Hash) === 13) 
    {
        $Salt = substr($Hash, 0, 2);
        $CalculatedHash = crypt($Password, $Salt);
        return hash_equals($CalculatedHash, $Hash);
    }
    
    // Check for MD5 format (starts with $1$)
    if (strpos($Hash, "$1$") === 0) 
    {
        $CalculatedHash = crypt($Password, $Hash);
        return hash_equals($CalculatedHash, $Hash);
    }
    
    return false;
}


function RemoveLess($String,$Char=2)
{

	$StringArray=explode (" ",$String);
	
	foreach ($StringArray as &$Word) 
	{
		if (mb_strlen($Word,"UTF-8")>$Char)
		{
			$Str.=$Word." ";
		}
	}
	
	return trim($Str);

}


function Version ($Version)
{

	$Version=trim($Version);

	if (strlen($Version)==4)
	{
	$Version=substr($Version,0,1).".".substr($Version,1,1).".".substr($Version,2,1);
	return $Version;
	}
	
	if (strlen($Version)==5)
	{
	$Version=substr($Version,0,2).".".substr($Version,2,1).".".substr($Version,3,1);
	return $Version;
	}
	
	if (strlen($Version)==6)
	{
	$Version=substr($Version,0,3).".".substr($Version,3,1).".".substr($Version,4,1);
	return $Version;
	}

}

function DateFormat ($Format,$Date)
{


	if ($Format=="")
	{
	return "Never";
	}


	return date($Format, strtotime($Date));

	
	
}

function Rate($FromDate)
{

	$Difference = strtotime("now") - strtotime($FromDate);
	$Rate = ceil ($Difference / (60*60*24));
	return $Rate;

}

	// تحويل التاريخ الميلادى للهجرى
  	function Hijri($Date)
	{
		$TDays=round(strtotime($Date)/(60*60*24));
		$HYear=round($TDays/354.37419);
		$Remain=$TDays-($HYear*354.37419);
		$HMonths=round($Remain/29.531182);
		$HDays=$Remain-($HMonths*29.531182);
		$HYear=$HYear+1389;
		$HMonths=$HMonths+10;
		$HDays=$HDays+23;
		
			if ($HDays>29.531188 and round($HDays)!=30)
			{
			$HMonths=$HMonths+1;
			$HDays=Round($HDays-29.531182);
			}
			else
			{
			$HDays=Round($HDays);
			}

			if ($HMonths>12){$HMonths=$HMonths-12;$HYear=$HYear+1;}

	$ResultDate="$HDays-$HMonths-$HYear";
	$ResultDate="$ResultDate"."هـ";

	return $ResultDate;
	}

function DateStatus ($Date,$Stamp=0)
{
	global $Lng,$DateFormat;

	$Stamp=intval($Stamp);

	if ($Stamp>0)
	{
	
	
	
		$Difference = time() - $Stamp;
		if ($Difference<60)
		{
			if ($Lng=="ar")
			{
			return "منذ $Difference ثانية";
			}
			else
			{
			return "$Difference seconds ago";
			}
		
		}
		elseif ($Difference<3600)
		{
		$Difference=floor($Difference/60);
		
			if ($Lng=="ar")
			{
			return "منذ $Difference دقائق";
			}
			else
			{
			return "$Difference minutes ago";
			}
			
		}
		elseif ($Difference<86400)
		{
		$Difference=floor($Difference/3600);
		
			if ($Difference==1)
			{
			
				if ($Lng=="ar")
				{
				return "منذ حوالى ساعة";
				}
				else
				{
				return "about an hour ago";
				}
			
			
				
			
			}
			else
			{
			
				if ($Lng=="ar")
				{
				return "منذ $Difference ساعات";
				}
				else
				{
				return "$Difference hours ago";
				}
			
			
			
			}
		
		}
		elseif ($Difference<604800)
		{
		
			if (Rate(gmdate("Y-m-d",$Stamp))==2)
			{
				$H = date ("g:i a",$Stamp); 
				
				if ($Lng=="ar")
				{
				return "أمس الساعة $H";
				}
				else
				{
				return "Yesterday at $H";
				}
				
			}
			else
			{
			$WeekDay=gmdate("l",$Stamp);
			
				$H = date ("g:i a",$Stamp); 
			
				if ($Lng=="ar")
				{
				$WeekDay=str_replace("Saturday","السبت",$WeekDay);
				$WeekDay=str_replace("Sunday","الأحد",$WeekDay);
				$WeekDay=str_replace("Monday","الاثنين",$WeekDay);
				$WeekDay=str_replace("Tuesday","الثلاثاء",$WeekDay);
				$WeekDay=str_replace("Wednesday","الأربعاء",$WeekDay);
				$WeekDay=str_replace("Thursday","الخميس",$WeekDay);
				$WeekDay=str_replace("Friday","الجمعة",$WeekDay);
				}

				return "$WeekDay at $H";
				

				
			}
			
			
		
			
		}
		else
		{
		return gmdate("D j M Y g:i a",$Stamp);
		}
	
	
	
	}
	else
	{
	
		
		$Difference = strtotime("now") - strtotime($Date);
		$Rate = ceil ($Difference / (60*60*24));
		if ($Lng=="ar")
		{

			if ($Rate==1) 
			{
				$Today="اليوم";
			}

			if ($Rate==2) 
			{
				$Today="الأمس";
			}


		}
		else
		{

			if ($Rate==1) 
			{
				$Today="Today";
			}

			if ($Rate==2) 
			{
				$Today="Yesterday";
			}


		}

		if ($Rate>=3)
		{
			if ($DateFormat!="Hijri")
			{
			
				if ($DateFormat=="")
				{
				$DateFormat="l, M j, Y";
				}
			
				$Today=DateFormat($Date,$DateFormat);
			}
			else
			{
				$Today=Hijri($Date);
			}
		}

		return $Today;
	}
}


function ValidateEmail($Email)
{

	$Email=trim($Email);

	if (trim($Email)=="")
	{
	return false;
	}
	
	if (! filter_var($Email, FILTER_VALIDATE_EMAIL))
	{
		echo Error("Invalid Email Address.");
		exit;	  
	} 
	
	
	$Email=strtolower($Email);
	return $Email;
}


function ValidateDomain($Domain)
{

	$Domain=strtolower($Domain);
	$Domain=trim($Domain);
	$Domain=str_replace("_","-",$Domain);

	if (trim($Domain)=="")
	{
	return false;
	}

	if( !preg_match( "/^(?:[-A-Za-z0-9]+\.)+[A-Za-z]{2,12}$/", $Domain))
	{
	echo Error("Invalid Domain.");
	exit;
	}
	
	
	$Domain=strtolower($Domain);
	return $Domain;
	
}

function ValidateUsername($Username)
{
	$Username=trim($Username);

	if (trim($Username)=="")
	{
	return false;
	}

	if (strlen($Username)>32)
	{
	return false;
	}

	if( !preg_match( "/^[A-Za-z0-9\.\-\_\ ]+$/i", $Username))
	{
	echo Error("Invalid Username $Username.");
	exit;
	}
	
	return $Username;
	
}


function ValidatePassword($Password)
{
    // Trim whitespace
    $Password = trim($Password);
    
    // Check if password is empty
    if (empty($Password)) 
	{
		return false;
    }
    
    // Define allowed characters (matches your GeneratePassword charset)
    // Includes: letters, numbers, and special chars !@#$%^&*()_+[]{}<>?
    $allowed_pattern = '/^[A-Za-z0-9!@#$%^&*()_+\[\]{}<>?]+$/';
    
    // Validate password characters
    if (!preg_match($allowed_pattern, $Password)) {
        // Return error message instead of echoing and exiting
		echo Error("Invalid Password - Contains disallowed characters");
        exit;
    }
    
    // Optional: Check minimum length
    if (strlen($Password) < 8) {
		echo Error("Invalid Password - Must be at least 8 characters long");
        exit;
    }
    
    // Optional: Check password strength requirements
    if (!preg_match('/[A-Z]/', $Password)) {
		echo Error("Invalid Password - Must contain at least one uppercase letter");
        exit;
    }
    
    if (!preg_match('/[a-z]/', $Password)) {
		echo Error("Invalid Password - Must contain at least one lowercase letter");
        exit;
    }
    
    if (!preg_match('/[0-9]/', $Password)) {
		echo Error("Invalid Password - Must contain at least one number");
        exit;
    }

    // Return validated password
    return $Password;
}


function ValidateDirectory($Directory)
{

	$Directory=trim($Directory);

	if (trim($Directory)=="")
	{
	return false;
	}

	if( !preg_match( "/^[a-z0-9\/\.\-\_]+$/i", $Directory))
	{
	echo Error("Invalid Directory.");
	exit;
	}
	
	return $Directory;
	
}

function ValidateName($Name)
{

	$Name=trim($Name);

	if (trim($Name)=="")
	{
	return false;
	}

	if( !preg_match( "/^[a-z \-]+$/i", $Name))
	{
	echo Error("Invalid Name.");
	exit;
	}
	
	return $Name;
	
}

function ValidateNumber($No)
{

	$No=trim($No);

	if (trim($No)=="")
	{
	return false;
	}

	if( !preg_match( "/^[0-9]+$/i", $No))
	{
	echo Error("Invalid Number.");
	exit;
	}
	
	return $No;
	
}


function ValidateDatabaseName($Name)
{

	$Name=trim($Name);

	if (trim($Name)=="")
	{
	return false;
	}

	if( !preg_match( "/^[a-z0-9_]+$/i", $Name))
	{
	echo Error("Invalid Database Name.");
	exit;
	}
	
	return $Name;
	
}

function ValidateMobile($Mobile)
{

	$Mobile=trim($Mobile);

	if (trim($Mobile)=="")
	{
	return false;
	}

	if( !preg_match( "/^[0-9 \-\+]+$/i", $Mobile))
	{
	echo Error("Invalid Mobile.");
	exit;
	}
	
	return $Mobile;
	
}


function ValidateWebsite($Website)
{

	if (trim($Website)=="")
	{
	return false;
	}

	if( !preg_match( "/^[a-z0-9\-\.\:\/\]+$/i", $Website))
	{
	echo Error("Invalid Website.");
	exit;
	}
	
	return $Website;
	
}

function ValidateAlphanumeric($Alphanumeric,$InvalidString="Invalid Alphanumeric.")
{

	$Alphanumeric=trim($Alphanumeric);

	if (trim($Alphanumeric)=="")
	{
	return false;
	}

	if( !preg_match( "/^[a-z ]+$/i", $Alphanumeric))
	{
	echo Error($InvalidString);
	exit;
	}
	
	return $Alphanumeric;
	
}

 
function ValidateVersion($Version,$InvalidString="Invalid Version.")
{

	$Version=trim($Version);

	if (trim($Version)=="")
	{
	return false;
	}

	if( !preg_match( "/^[a-z0-9\.]+$/i", $Version))
	{
	echo Error($InvalidString);
	exit;
	}
	
	return $Version;
	
}


function Validate($String,$InvalidString="Invalid.")
{

	$String=trim($String);

	if (trim($String)=="")
	{
	return false;
	}

	if( !preg_match( "/^[a-z0-9 ]+$/i", $String))
	{
	echo Error($InvalidString);
	exit;
	}
	
	return $String;
	
}

function ValidateIP($IP)
{

	$IP=trim($IP);

	if (trim($IP)=="")
	{
	return false;
	}

	if (filter_var($IP, FILTER_VALIDATE_IP)) 
	{
		return $IP;
	} 
	else 
	{
		echo Error("$IP is not a valid IP address");
		exit;
	}
	
}




function FormatFilesize($File)
{


	$Size = filesize($File);
	$Sizes = Array('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB');
	$Ext = $Sizes[0];
	for ($i=1;
	(($i < count($Sizes)) && ($Size >= 1024));
	$i++)
	{

		$Size = $Size / 1024;
		$Ext  = $Sizes[$i];
		
	}

	$S=round($Size, 2);

	return strval($S)." $Ext";

}


function FormatSize($Size)
{

	$Size=intval($Size);

	$Sizes = Array('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB');
	$Ext = $Sizes[0];
	for ($i=1;
	(($i < count($Sizes)) && ($Size >= 1024));
	$i++)
	{

		$Size = $Size / 1024;
		$Ext  = $Sizes[$i];
		
	}

	$S=round($Size, 2);

	return strval($S)." $Ext";

}


function UrlExists($Url)
{ 
    $Hdrs = @get_headers($Url); 
    return is_array($Hdrs) ? preg_match('/^HTTP\\/\\d+\\.\\d+\\s+2\\d\\d\\s+.*$/',$Hdrs[0]) : false; 
} 


function Error($Message,$Align="center")
{
	global $LNG;

	// if Json data
	if (stristr($Message,"{") and stristr($Message,"}"))
	{
		$Obj = json_decode($Message, TRUE);
		if (isset($Obj['success']))
		{
			$Message="<table cellspacing=8 cellpadding=0 border=0>";
			$Result= $Obj['result'];
			
			if ($Obj['title']!="")
			{
			$Title=$Obj['title'];
			$Message.="<tr><td colspan=2 class=JsonTitle>{$LNG[$Title]}</td>";
			}
			
			foreach($Result as $Key => $Value) 
			{
				if ($Value=="")
				{
				$Message.="<tr><td colspan=2 class=JsonTitle>{$LNG[$Key]}</td>";
				}
				elseif ($Key=="null")
				{
				$Message.="<tr><td colspan=2 width=100% height=20></td>";
				}
				else
				{
				$Message.="<tr><td width=20% class=JsonA nowrap>{$LNG[$Key]}</td><td class=JsonB>$Value</td>";
				}
			}

			if ($Obj['error']!="")
			{
			$Message.="<tr><td colspan=2 class=JsonError>{$Obj['error']}</td>";
			}

			if ($Obj['warning']!="")
			{
			$Message.="<tr><td colspan=2 class=JsonWarning>{$Obj['warning']}</td>";
			}
			
			$Message.="</table>";
		}
	}

	$Message=$Message."_END_";
	$Message=str_replace("\n_END_","",$Message);
	$Message=str_replace("_END_","",$Message);
	

	if (stristr($Message,"<br>") or stristr($Message,"<tr>") or $Message=="Open")
	{
	$Align="left";
	}
	elseif (stristr($Message,"\n"))
	{
	$Align="left";
	$Message=str_replace("\n","<br>",$Message);
	}
	
	$Message=str_replace("Information:","<img src='theme/{$_SESSION['SessionTheme']}/image/information.svg' height=32 style='vertical-align:middle;padding:5px'>",$Message);
	$Message=str_replace("Warning:","<img src='theme/{$_SESSION['SessionTheme']}/image/warning.svg' height=32 style='vertical-align:middle;padding:5px'>",$Message);
	
	$ErrorClass="NoError";
	if (preg_match("(error|try again|failed|invalid|refused|sorry)", strtolower($Message))) 
	{
	$ErrorClass="Error";
	}

	if ($Message=="Open")
	{
	return "<div class='$ErrorClass' style='text-align:$Align'>";
	}
	elseif ($Message=="Close")
	{
	return "</div>";	
	}
	else
	{
	$Message=preg_replace('@(https?://([-\w\.]+[-\w])+(:\d+)?(/([\w/_\.#-~]*(\?\S+)?)?)?)@','<a href="$1" target="_blank">$1</a>', $Message);

	return "<div class='$ErrorClass' style='text-align:$Align'>".$Message."</div>";
	}
	

}

function StartsWith($Haystack, $Needle)
{
	$Haystack=strtolower($Haystack);
	$Needle=strtolower($Needle);
	
    return $Needle === "" || strpos($Haystack, $Needle) === 0;
}

function EndsWith($Haystack, $Needle)
{
	$Haystack=strtolower($Haystack);
	$Needle=strtolower($Needle);

    return $Needle === "" || substr($Haystack, -strlen($Needle)) === $Needle;
}


function Stopwatch($Seconds) 
{
  $T = round($Seconds);
  return sprintf('%02d:%02d:%02d', ($T/3600),($T/60%60), $T%60);
}




function Push ($GCMRegisterID,$Title,$Message)
{
	// Project ID: centered-song-96918 Project Number: 1014396614781


	// API access key from Google API's Console
	// define( 'API_ACCESS_KEY', 'YOUR-API-ACCESS-KEY-GOES-HERE' );
	define( 'API_ACCESS_KEY', 'AIzaSyCbGSGz85EaaqrCAHdvZ07C365yBbQCH2I' );

	$registrationIds = array( $GCMRegisterID );

	// prep the bundle
	$msg = array
	(
		'message' 	=> $Message,
		'title'		=> $Title,
		'subtitle'	=> $SubTitle,
		'tickerText'	=> $Ticker,
		'vibrate'	=> 1,
		'sound'		=> 1,
		'largeIcon'	=> 'large_icon',
		'smallIcon'	=> 'small_icon'
	);

	$fields = array
	(
		'registration_ids' 	=> $registrationIds,
		'data'			=> $msg
	);
	 
	$headers = array
	(
		'Authorization: key=' . API_ACCESS_KEY,
		'Content-Type: application/json'
	);
	 
	$ch = curl_init();
	curl_setopt( $ch,CURLOPT_URL, 'https://android.googleapis.com/gcm/send' );
	curl_setopt( $ch,CURLOPT_POST, true );
	curl_setopt( $ch,CURLOPT_HTTPHEADER, $headers );
	curl_setopt( $ch,CURLOPT_RETURNTRANSFER, true );
	curl_setopt( $ch,CURLOPT_SSL_VERIFYPEER, false );
	curl_setopt( $ch,CURLOPT_POSTFIELDS, json_encode( $fields ) );
	$result = curl_exec($ch );
	curl_close( $ch );

	return $result;
}

function Mobile ($N,$Country="")
{

	$Eastern = array('٠','١','٢','٣','٤','٥','٦','٧','٨','٩');
	$Western = array('0','1','2','3','4','5','6','7','8','9');
	$N = str_replace($Eastern, $Western, $N);

	$N=trim($N);

	if (substr($N, 0, 2)=="00")
	{
	$N=(substr($N,2));
	}

	$N = preg_replace('/\D/', '', $N);

	// EGYPT
	if (preg_match("#^(010|011|012)([0-9]+)$#i", $N))
	{
		if (strlen($N)==11)
		{
		return "2{$N}";
		}
	}

	if (preg_match("#^(2010|2011|2012|015)([0-9]+)$#i", $N))
	{
		if (strlen($N)==12)
		{
		return $N;
		}
	}
	
	// EGYPT in case 001006931666
	if (preg_match("#^(10|11|12|15)([0-9]+)$#i", $N))
	{
	
		if (strlen($N)==10)
		{
		return "20".$N;
		}
		
	}
	
	// EGYPT in case 2001006931666
	if (preg_match("#^(20010|20011|20012|20015)([0-9]+)$#i", $N))
	{
	
		if (strlen($N)==13)
		{
		return "2".substr($N,2);
		}
		
	}
	

	if (preg_match("#^(9647|9779)([0-9]+)$#i", $N) and $Country=="")
	{
		if (strlen($N)==13)
		{
		return $N;
		}
	}


	if (preg_match("#^(2499|9197|9198|9199|9053|9665|9715|9725|9627|9639|9677|9705|2189|393|420|491|447)([0-9]+)$#i", $N) and $Country=="")
	{
		if (strlen($N)==12)
		{
		return $N;
		}
	}
	


	if (preg_match("#^(9743|9745|9617|9659|9655|9656|9689|9733|9736|9746|9751|9769|3163|336|601|417|405|407|467|120|121|131|132|133|150|151|161|164|165|172|178|190|915|796|798)([0-9]+)$#i", $N) and $Country=="")
	{
		if (strlen($N)==11)
		{
		return $N;
		}
	}


	if (preg_match("#^(4176|9055|9613)([0-9]+)$#i", $N) and $Country=="")
	{
		if (strlen($N)==10)
		{
		return "$N";
		}
	}
	



}

	// GET First Mobile number in string
	function FMobile($String)
	{
	$MobNumbers=str_replace("\r\n", ",",$String);
	$MobNumbers=str_replace("<", ",",$MobNumbers);
	$MobNumbers=str_replace(">", ",",$MobNumbers);
	$MobNumbers=str_replace(" ", "",$MobNumbers);
	$MobNumbers=str_replace("+", ",",$MobNumbers);
	
	$MobNumbersNo=substr_count($MobNumbers,",");

	$MobNumbersArray=explode(",",$MobNumbers);

		for ($x=0 ;$x<=$MobNumbersNo ; $x++)
		{
		
			if (Mobile($MobNumbersArray[$x])!="")
			{
			return "+".Mobile($MobNumbersArray[$x]);
			}
		}
		
		
	}
	
	// Unicode for SMS
	function Unicode($text) 
	{
		 return ''.implode(unpack('H*', iconv("UTF-8", "UCS-2BE", $text)));
	}

	
	// GET First Email in String
	function FEmail ($String) 
	{
	
		foreach (preg_split('/\s/', $String) as $Token) 
		{
			$Email = filter_var(filter_var($Token, FILTER_SANITIZE_EMAIL), FILTER_VALIDATE_EMAIL);
			if ($Email !== false) 
			{
				return $Email;
			}
		}
    
	
	}
	
	function Layer ($Hash,$LayerCode="") 
	{
	global $DisableCache,$ScriptUrl,$LYR;
	
		$FileName=md5($Hash).".{$LYR}";
	
		if ($LayerCode=="")
		{
		// Get layer code
		$LayerCode=@file_get_contents("/lyr/$FileName");
		return trim($LayerCode);
		}
		else
		{
			if (trim($LayerCode)!="" and $DisableCache!=1)
			{
			@file_put_contents("/lyr/$FileName",$LayerCode);
			}
			
		}
	
	}
	

	function IndexIDs ($SearchFor) 
	{
	$SearchFor=Index($SearchFor);
	$FileName=md5("|INDEX|$SearchFor|").".idx";

		if (file_exists("/idx/$FileName"))
		{
		// Get layer code
		$IDs=@file_get_contents("/idx/$FileName");
		return $IDs;
		}
		else
		{
			// Try again after remove some words
			$Words = array("apartment", "villa","chalet","flat","area","with","compound","for","delivery"," and ","delivering","invest","installment","best","fully","special","phase","nice","facilities","good","view","years","floor","finished","sqm","your","buy","unique","meter"."about"."know","beautiful","super Lux","call","own","over looking","overlooking"."living","adorable","egypt","bedroom","very","executive","modern","ultra","high","perfect","chance","price","half","luxury","separate","having","semi"," the ","expat","plan","life","now","amazing","payment","prime","location","immediate","project","overlooking","كومباوند", "شقة","شقه","غرف","نوم","بكمباوند","متر","قريبة","سوبر","لوكس","تشطيب","مساحة","فاخرة","على","بالتقسيط","بموقع","موقع","على","مقدم"," كبيره","متميز","طريق","مذهلة","مربع","امتلك","دورين","دور"."حتى");
			$SearchFor = str_replace($Words,"", $SearchFor);
			
			$SearchFor=Index($SearchFor);
			$FileName=md5("|INDEX|$SearchFor|").".idx";
			
			if (file_exists("/idx/$FileName"))
			{
			// Get layer code
			$IDs=@file_get_contents("/idx/$FileName");
			return $IDs;
			}
			else
			{
			return "";
			}
		}

	
	}
	
	function IndexIDV ($SearchFor) 
	{
	$SearchFor=Index($SearchFor);
	$FileName=md5("|INDEX|$SearchFor|").".idv";

		if (file_exists("/idv/$FileName"))
		{
		// Get IDV (First Result Variables)
		$IDV=@file_get_contents("/idv/$FileName");
		return $IDV;
		}
		else
		{
		return "";
		}
	}
	

	
	function Tag($String)
	{
	global $ScriptUrl;
	
		$String=str_ireplace("[tag] ","[tag]",$String);
		$String=str_ireplace(" [/tag]","[/tag]",$String);

		$Pattern = '~\[tag(?|=[\'"]?([^]"\']+)[\'"]?]([^[]+)|](([^[]+)))\[/tag]~';
		$Replacement = "[tag=$1]$2[/tag]";
		$String = preg_replace($Pattern, $Replacement, $String);

		$Pattern = '~\s+(?=[^[\]]*\])~';
		$Replacement = "-";
		$String = preg_replace($Pattern, $Replacement, $String);

		// Remove special characters between that [ and ]
		$Pattern = '~[\?\!\,\+\#\@\'\%\&\(\)\_\:\.]+(?=[^[\]]*\])~';
		$Replacement = "";
		$String = preg_replace($Pattern, $Replacement, $String);

		$Pattern = '~\[tag(?|=[\'"]?([^]"\']+)[\'"]?]([^[]+)|](([^[]+)))\[/tag]~';
		$Replacement = "<a href='$ScriptUrl/$1'>$2</a>";
		$String = preg_replace($Pattern, $Replacement, $String);

		return $String;

	}
	
	function TextBetween ($Content,$Start,$End)
	{
		$Start=str_replace("/","\/",$Start);
		$Start=str_replace("*","\*",$Start);
		
		$End=str_replace("/","\/",$End);
		$End=str_replace("*","\*",$End);
		
		$Content=str_replace("\n","",$Content);
		$Content=str_replace("\r","",$Content);

		preg_match("/$Start(.*?)$End/i",$Content,$T);
		$Text=trim(strip_tags($T[1]));
		
		return trim($Text);
	
	}




function ProcessingData ($SubItem,$EnItem,$ArItem)
{
	$SubItem=str_ireplace("Apartments","Apartment",$SubItem);
	$SubItem=str_ireplace("Buildings","Building",$SubItem);
	$SubItem=str_ireplace("Villas / Townhouses","Villa",$SubItem);
	$SubItem=str_ireplace("Villas","Villa",$SubItem);
	$SubItem=str_ireplace("Shops","Shop",$SubItem);
	$SubItem=str_ireplace("Offices","Office",$SubItem);
	$SubItem=str_ireplace("Warehouses","Warehouse",$SubItem);
	$SubItem=str_ireplace("Schools","School",$SubItem);
	$SubItem=str_ireplace("Hospitals / Clinics","Hospital",$SubItem);
	$SubItem=str_ireplace("Hospitals","Hospital",$SubItem);
	$SubItem=str_ireplace("Farms","Farm",$SubItem);
	$SubItem=str_ireplace("Factories","Factory",$SubItem);
	$SubItem=str_ireplace("Hotels","Hotel",$SubItem);
	$SubItem=str_ireplace("Chalets","Chalet",$SubItem);
			
	$SubItem=str_ireplace("شقق","شقة",$SubItem);
	$SubItem=str_ireplace("عمارات","عمارة",$SubItem);
	$SubItem=str_ireplace("فيلات/تاون هاوس","فيلا",$SubItem);
	$SubItem=str_ireplace("فيلات","فيلا",$SubItem);
	$SubItem=str_ireplace("محلات","محل",$SubItem);
	$SubItem=str_ireplace("مكاتب إدارية","مكتب",$SubItem);
	$SubItem=str_ireplace("مخازن","مخزن",$SubItem);
	$SubItem=str_ireplace("مدارس","مدرسة",$SubItem);
	$SubItem=str_ireplace("مستشفيات","مستشفى",$SubItem);
	$SubItem=str_ireplace("مزارع","مزرعة",$SubItem);
	$SubItem=str_ireplace("مصانع","مصنع",$SubItem);
	$SubItem=str_ireplace("أراضى","ارض",$SubItem);
	$SubItem=str_ireplace("المكاتب المنزلية","منزل",$SubItem);
	$SubItem=str_ireplace("شاليهات","شالية",$SubItem);
	
	if (stristr($EnItem,"Duplex"))
	{
	$SubItem=str_ireplace("apartment","Duplex",$SubItem);
	$SubItem=str_ireplace("villa","Duplex",$SubItem);
	$SubItem=str_ireplace("شقة","دوبليكس",$SubItem);
	$SubItem=str_ireplace("الفيلا","دوبليكس",$SubItem);
	$SubItem=str_ireplace("فيلا","دوبليكس",$SubItem);
	}
	
	if (stristr($EnItem,"Penthouse"))
	{
	$SubItem=str_ireplace("apartment","Penthouse",$SubItem);
	$SubItem=str_ireplace("شقة","بنتهاوس",$SubItem);
	}
	
	if (stristr($EnItem,"Clinic ") or stristr($EnItem,"Clinics "))
	{
	$SubItem=str_ireplace("Commercial Shop","Clinic",$SubItem);
	$SubItem=str_ireplace("محل","عيادة",$SubItem);
	
	$SubItem=str_ireplace("Hospital","Clinic",$SubItem);
	$SubItem=str_ireplace("مستشفى","عيادة",$SubItem);
	}
	
	if (stristr($EnItem,"Villa") or stristr($ArItem,"فيلا"))
	{
	$SubItem=str_ireplace("Coastal Property","Villa",$SubItem);
	$SubItem=str_ireplace("العقارات الساحلية والمصايف","فيلا",$SubItem);
	$SubItem=str_ireplace("شالية","فيلا",$SubItem);
	$SubItem=str_ireplace("شالية","فيلا",$SubItem);
	}
	
	if (stristr($EnItem,"Town House") or stristr($EnItem,"Townhouse") or stristr($ArItem,"تاون هاوس"))
	{
	$SubItem=str_ireplace("Villa","Town House",$SubItem);
	$SubItem=str_ireplace("Chalet","Town House",$SubItem);
	$SubItem=str_ireplace("فيلا","تاون هاوس",$SubItem);
	
	$SubItem=str_ireplace("Coastal Property","Town House",$SubItem);
	$SubItem=str_ireplace("العقارات الساحلية والمصايف","تاون هاوس",$SubItem);
	$SubItem=str_ireplace("شالية","تاون هاوس",$SubItem);
	}
	
	if (stristr($EnItem,"Twin House") or stristr($EnItem,"Twinhouse") or stristr($ArItem,"توينهاوس") or stristr($ArItem,"توين هاوس"))
	{
	$SubItem=str_ireplace("Villa","Twin House",$SubItem);
	$SubItem=str_ireplace("Chalet","Twin House",$SubItem);
	$SubItem=str_ireplace("فيلا","توين هاوس",$SubItem);

	$SubItem=str_ireplace("Coastal Property","Twin House",$SubItem);
	$SubItem=str_ireplace("العقارات الساحلية والمصايف","توين هاوس",$SubItem);
	$SubItem=str_ireplace("شالية","توين هاوس",$SubItem);
	}
	
	if (stristr($EnItem,"Chalet") or stristr($EnItem,"Coastal Propert") or stristr($ArItem,"شاليه"))
	{
	$SubItem=str_ireplace("Coastal Property","Chalet",$SubItem);
	$SubItem=str_ireplace("العقارات الساحلية والمصايف","شاليه",$SubItem);
	
	$SubItem=str_ireplace("Apartment","Chalet",$SubItem);
	$SubItem=str_ireplace("شقة","شاليه",$SubItem);
	}
	
	return $SubItem;
}


function StrEnd ($Separator,$String)
{
	$StringArray=explode($Separator,$String);
	return end ($StringArray);

}


function CurrencyConverter ($From,$To)
{
$Code=file_get_contents("http://apilayer.net/api/live?access_key=23957532fe3cc79fbd98603ad6ee3086&currencies=$TO&format=1");
$Data = json_decode($Code, true);
$Rate=$Data['quotes']['USDEGP'];
return $Rate;
}

function HrefLang ($Url)
{
global $Lng,$Domain,$DefaultLng;

	if ($Lng=="en")
	{
	$EnUrl=$Url;
	
		if (stristr($Url,"/en/"))
		{
		$ArUrl=str_replace("/en/","/ar/",$Url);
		}
		else
		{
		$ArUrl=str_replace($Domain,"$Domain/ar",$Url);
		}
	}


	if ($Lng=="ar")
	{
	$ArUrl=$Url;
	
		if (stristr($Url,"/ar/"))
		{
		$EnUrl=str_replace("/ar/","/en/",$Url);
		}
		else
		{
			if ($DefaultLng=="en")
			{
			$EnUrl=str_replace("$Domain/ar","$Domain",$Url);
			}
			else
			{
			$EnUrl=str_replace("$Domain/ar","$Domain/en",$Url);
			}
		}	
	}



$HrefLang="<link rel=\"alternate\" href=\"$EnUrl\" hreflang=\"en\" />
<link rel=\"alternate\" href=\"$ArUrl\" hreflang=\"ar\" />";

return ($HrefLang);

}

function Phrase ($String,$N)
{
	$String=strip_tags($String);
	$String=str_ireplace("[tag]"," ",$String);
	$String=str_ireplace("[/tag]"," ",$String);
	
	$String=str_replace("\n"," ",$String);
	$String=str_replace("\r"," ",$String);
	$String=str_replace("'"," ",$String);
	$String=str_replace("-"," ",$String);
	$String=str_replace("\""," ",$String);
	$String=str_replace("&"," ",$String);
	$String=str_replace("<"," ",$String);
	$String=str_replace(">"," ",$String);
	$String=preg_replace("/\s+/"," ",$String);
	
	$String=str_replace(" ,",",",$String);
	$String=trim($String);

	if (mb_strlen($String)<=$N)
	{
	return $String;
	}
	else
	{
	$String=mb_substr($String,0,$N,'UTF-8');
	// Remove last word
	$String= preg_replace('/\W\w+\s*(\W*)$/u', '$1', $String);
	return $String;
	}
}	

function Duration8601($second)
{
	$h = intval($second/3600);
	$m = intval(($second -$h*3600)/60);
	$s = $second -($h*3600 + $m*60);
	$ret = 'PT';
	if ($h)
		$ret.=$h.'H';
	if ($m)
		$ret.=$m.'M';
	if ((!$h && !$m) || $s)
		$ret.=$s.'S';
	return $ret;
}

function SSH($Command,$Username,$Password,$TTL=0)
{
	$TTL=intval($TTL);
	
    if (function_exists('shell_exec')) 
	{
		if ($TTL>0)
		{
			// Get Cache IF Exists
			$Key=md5($Command).".key";
			$P=time()-filemtime("/usr/local/goadmio/cache/$Key");
			if (file_exists("/usr/local/goadmio/cache/$Key") and $P<=$TTL)
			{
				$Content=unserialize(file_get_contents("/usr/local/goadmio/cache/$Key"));
				return $Content;
			}
		}

		$Content = shell_exec($Command);
		
		if ($TTL>0)
		{
		file_put_contents("/usr/local/goadmio/cache/$Key",serialize($Content));
		}
		
		return $Content;
		
	}
	else
	{
	return SSH2($Command,$Username,$Password,$TTL);
	}
	
}

function SSH2($Command,$Username,$Password,$TTL=0)
{
    global $SSHHost, $SSHPort;
    static $Connections = [];
	
	$TTL=intval($TTL);
	
	if ($TTL>0)
	{
		// Get Cache IF Exists
		$Key=md5($Command).".key";
		$P=time()-filemtime("/usr/local/goadmio/cache/$Key");
		if (file_exists("/usr/local/goadmio/cache/$Key") and $P<=$TTL)
		{
			$Content=unserialize(file_get_contents("/usr/local/goadmio/cache/$Key"));
			return $Content;
		}

	}

    if (intval($SSHPort) == 0) { $SSHPort = 22; }
    if ($SSHHost == "") { $SSHHost = "localhost"; }

    // Create a unique connection key
    $ConnectionKey = $SSHHost . ':' . $SSHPort . ':' . $Username;

    // Check if connection already exists
    if (isset($Connections[$ConnectionKey])) 
	{
		$Connect = $Connections[$ConnectionKey];
    } 
	else 
	{
        $Connect = ssh2_connect($SSHHost, $SSHPort);
        if (!$Connect) 
		{
            return "Connection Failed!";
        }
        
        if (!ssh2_auth_password($Connect, $Username, $Password)) 
		{
            return "Authentication Failed!";
        }
        
        $Connections[$ConnectionKey] = $Connect;
    }

    // Execute command
    $Stream = ssh2_exec($Connect, $Command);
    stream_set_blocking($Stream, true);
    $Output = ssh2_fetch_stream($Stream, SSH2_STREAM_STDIO);
    $Content = stream_get_contents($Output);

	$Content=trim($Content);
	
	if ($TTL>0)
	{
	file_put_contents("/usr/local/goadmio/cache/$Key",serialize($Content));
	}
	
    return $Content;
}

function GeneratePassword($Len=8)
{
	$Chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	$Password=substr(str_shuffle($Chars),0,$Len);
	return $Password;
}

function Lang($String)
{
	global $LNG;

	$Str=$String;

	$Str = preg_replace( '/[^A-Za-z0-9 ]/i', '', $Str);

	// Remove words less then 3 letters 
	$Str=preg_replace('/(\b.{1,2}\s)/','',$Str);
	$Str=ucwords($Str);
	$Str=str_replace(" ","",$Str);

	// echo "---$Str---";
	// return $Str;

	$Translate=$LNG[$Str];
	
	if ($Translate!=="")
	{
	return $Translate;
	}
	else
	{
	return $String;
	}

}


function Column($Table,$Type="1,2",$SearchFor="",$Result="")
{
	
	$TableName=trim(strtolower($Table));
	if (file_exists("/var/lib/sqlite/$TableName.db"))
	{
		try {$PDO=new PDO("sqlite:/var/lib/sqlite/$TableName.db");$PDO -> setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);} catch (Exception $E) {echo $E->getMessage();exit;}
	}
	else
	{
		return;
	}

	// $Type 1=Number
	// $Type 2=String

	$FieldX=0;

	$Select = $PDO->query("select * from $Table limit 1");

	$TotalColumn = $Select->columnCount();
	for ($Counter = 0; $Counter < $TotalColumn; $Counter ++)
	{
		$ColumnMeta = $Select->getColumnMeta($Counter);
		$FieldName=$ColumnMeta['name'];
		$FieldType=$ColumnMeta['pdo_type'];
		
		if (stristr("$Type","$FieldType"))
		{
			$X++;
			
			if ($X==1)
			{
				if ($Result=="like")
				{
				$String="$FieldName like '%$SearchFor%'";
				}
				elseif ($Result=="=")
				{
				$String="$FieldName='%$SearchFor%'";
				}
				elseif ($Result=="GROUP_CONCAT")
				{
				$String="GROUP_CONCAT($FieldName SEPARATOR ' ') like '%$SearchFor%'";
				}
				else
				{
				$String="$FieldName";
				}
				
				
			}
			else
			{
			
				if ($Result=="like")
				{
				$String.=" or $FieldName like '%$SearchFor%'";
				}
				elseif ($Result=="=")
				{
				$String.=" or $FieldName='%$SearchFor%'";
				}
				elseif ($Result=="GROUP_CONCAT")
				{
				$String.=" or GROUP_CONCAT($FieldName SEPARATOR ' ') like '%$SearchFor%'";	
				}
				else
				{
				$String.=",$FieldName";
				}
			}
		}
		
	}
	
	return $String;

}

function RowCount ($SQL)
{
	
	$TableName=TableName($SQL);
	
	if (file_exists("/var/lib/sqlite/$TableName.db"))
	{
		try {$PDO=new PDO("sqlite:/var/lib/sqlite/$TableName.db");$PDO -> setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);} catch (Exception $E) {echo $E->getMessage();exit;}
	}
	else
	{
		return;
	}
	
	$SQL=str_replace("*","count(*)",$SQL);
	$SQL=str_ireplace(" limit "," LIMIT ",$SQL);
	$SQLArray=explode("LIMIT",$SQL);
	
	$RowsNo=$PDO->query($SQLArray[0])->fetchColumn();

	return $RowsNo;

}

function SQL($SQL,$TTL=0,$Memory=0)
{
	$TableName=TableName($SQL);

	if (file_exists("/var/lib/sqlite/$TableName.db"))
	{
		try {$PDO=new PDO("sqlite:/var/lib/sqlite/$TableName.db");$PDO -> setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);} catch (Exception $E) {echo $E->getMessage();exit;}
	}
	else
	{
		return;
	}

	$Domain = preg_replace("/^www\./","",$_SERVER['SERVER_NAME']);

	if ($TTL>0)
	{
		if ($Memory==1)
		{
			// Cache in Memory
			$Redis=new Redis();
			$Redis->connect('127.0.0.1', 6379);
			$Key=md5($Domain.$SQL);
		
			if ($Redis->get($Key))
			{
				echo "Get Memory";
				$Result = unserialize($Redis->get($Key));
			}
			else
			{
			
				if (stripos($SQL,"SELECT COUNT")===0)
				{
				$Result = $PDO->query($SQL)->fetchColumn();
				
				$Redis->set($Key, serialize($Result));
				$Redis->expire($Key,$TTL);
				}
				elseif (stripos($SQL,"SELECT")===0)
				{
				$Result = $PDO->query($SQL)->fetchAll();
				
				$Redis->set($Key, serialize($Result));
				$Redis->expire($Key,$TTL);
				}
				elseif (stripos($SQL,"INSERT")==0)
				{
				$Result = $PDO->query($SQL);
				return $PDO->lastInsertId(); 	
				}
				else
				{
				$Result = $PDO->query($SQL);
				return $Result->rowCount();
				}
				
			}
		}
		else
		{
			// Cache in Disk
			$Key=md5($Domain.$SQL).".key";
			$P=time()-filemtime("/usr/local/goadmio/cache/$Key");
			if (file_exists("/usr/local/goadmio/cache/$Key") and $P<=$TTL)
			{
			$Result = unserialize(file_get_contents("/usr/local/goadmio/cache/$Key"));
			}
			else
			{
			
				if (stripos($SQL,"SELECT COUNT")===0)
				{
				$Result = $PDO->query($SQL)->fetchColumn();
				
				file_put_contents("/usr/local/goadmio/cache/$Key",serialize($Result));
				}
				elseif (stripos($SQL,"SELECT")===0)
				{
					$Result = $PDO->query($SQL)->fetchAll();
				
					file_put_contents("/usr/local/goadmio/cache/$Key",serialize($Result));
				}
				elseif (stripos($SQL,"INSERT")==0)
				{
				$Result = $PDO->query($SQL);
				return $PDO->lastInsertId(); 	
				}
				else
				{
				$Result = $PDO->query($SQL);
				return $Result->rowCount();
				}
			}
		}
	}
	else
	{
	
		if (stripos($SQL,"SELECT COUNT")===0)
		{
		$Result = $PDO->query($SQL)->fetchColumn();
		}
		elseif (stripos($SQL,"SELECT")===0)
		{
		$Result = $PDO->query($SQL)->fetchAll();
		}
		elseif (stripos($SQL,"INSERT")===0)
		{
		$Result = $PDO->query($SQL);
		return $PDO->lastInsertId(); 	
		}
		else
		{
		$Result = $PDO->query($SQL);
		return $Result->rowCount();
		}
	}

	return $Result;
}



function RandomPassword($L=8) 
{
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    $pass = array(); //remember to declare $pass as an array
    $alphaLength = strlen($alphabet) - 1; //put the length -1 in cache
    for ($i = 0; $i < $L; $i++) 
	{
        $n = rand(0, $alphaLength);
        $pass[] = $alphabet[$n];
    }
    return implode($pass); //turn the array into a string
}


function RandomSalt() 
{
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    $pass = array(); //remember to declare $pass as an array
    $alphaLength = strlen($alphabet) - 1; //put the length -1 in cache
    for ($i = 0; $i < 5; $i++) 
	{
        $n = rand(0, $alphaLength);
        $pass[] = $alphabet[$n];
    }
    return implode($pass); //turn the array into a string
}

function Invoice ($CustomerID,$Service,$Amount,$Subject,$Date="",$OrderID="")
{
	$TimeStamp=time();

	if ($Date=="") 
	{
	$Date=date ("Y-m-d");
	}
		
	if ($OrderID=="")
	{
		$R=sprintf("%06s",mt_rand(0,999999));
		
		if ($Amount==0)
		{
		$OrderID="FREE-".$CustomerID."-$R-".time();
		$TimeStamp=time()+1;
		}
		else
		{
		$OrderID="MANUAL-".$CustomerID."-$R-".time();
		}
	}
	
	$Sql = "select * from Customer where CustomerID='$CustomerID'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{ 
		$Balance=$Row['Balance'];
	}
	
	if ($Amount<0 and $Balance<abs($Amount))
	{
		// Balance not enough
		return 0;
	}


	$Sql = "select * from Invoice where OrderID='$OrderID'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{ 
		echo "Order ID $OrderID already exists.";
		return "Order ID $OrderID already exists.";
	}

	$BalanceAfter=$Balance+$Amount;
	$Result=SQL("INSERT INTO Invoice (CustomerID,Service,OrderID,Amount,Subject,BalanceAfter,Date,TimeStamp) VALUES ('$CustomerID','$Service','$OrderID','$Amount','$Subject','$BalanceAfter','$Date','$TimeStamp')");
	if ($Result)
	{
		SQL("UPDATE Customer SET Balance=Balance+$Amount where CustomerID='$CustomerID'");
	
		// Success
		return 1;
	}
	else
	{
		// Failed
		return 0;
	}
	
}


function RenewVPS($RenewCustomerID=0,$RenewVPSID=0)
{

	$Date=date ("Y-m-d");
	if ($CustomerID==0)
	{
	$Sql = "select * from VPS where ExpiresOn<='$Date' and CustomerID>=1 and Renew=1";
	}
	else
	{
	$Sql = "select * from VPS where ExpiresOn<='$Date' and CustomerID='$RenewCustomerID'";
	}
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		if ($RenewVPSID==0 or $RenewVPSID==$Row['VPSID'])
		{
			$VPSID=$Row['VPSID'];
			$ID=$Row['ID'];
			$Price=$Row['Price'];
			$ServerIP=$Row['ServerIP'];
			$IP=$Row['IP'];
			$PlanName=$Row['PlanName'];
			$CustomerID=$Row['CustomerID'];
			$ExpiresOn=$Row['ExpiresOn'];
		
			// Create Invoice and Charge Amount from Customer
			$Amount=$Price*-1;
			$Success=Invoice ($CustomerID,"$PlanName ($IP)",$Amount,"Entry for 1 month");
		
			if ($Success==1)
			{
			$ExpiresOn = date("Y-m-d", strtotime("+1 month",strtotime("$ExpiresOn")));
			
			$TimeStamp=time();
			SQL("UPDATE VPS set ExpiresOn='$ExpiresOn',TimeStamp='$TimeStamp' where VPSID='$VPSID'");
			
			echo Error ("$IP renew done ($ExpiresOn), Customer ID: $CustomerID");
			}
			else
			{
			echo Error("Sorry, Balance is not enough (Container ID: $ID, VPS ID: $VPSIDm,VPS IP: $IP, Server IP: $ServerIP, Customer ID: $CustomerID).");
			}
			
		}
	
	}


}



function AssignVPS($CustomerID,$PlanName,$Location)
{
	global $VPSOffer;

	$Sql = "select * from Plan where PlanName='$PlanName'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		$PlanName=$Row['PlanName'];
		$DiskType=$Row['DiskType'];		
		$DiskSpace=$Row['DiskSpace'];
		$Cores=$Row['Cores'];
		$Memory=$Row['Memory'];
		$Price=$Row['Price'];
	}
	
	$Sql = "select * from Customer where CustomerID='$CustomerID'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{ 

		$Name=$Row['Name'];
		$Email=$Row['Email'];
		$Balance=$Row['Balance'];

	}
	
	if ($Balance<$Price)
	{
		return "Balance is not enough.";
	}

	$VPSID=0;
	$Sql = "select * from VPS where CustomerID='0' and DiskType='$DiskType' and Location='$Location' ORDER BY TimeStamp LIMIT 1";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{ 
		$VPSID=$Row['VPSID'];
		$IP=$Row['IP'];
		$ServerIP=$Row['ServerIP'];
	}
	
	if ($VPSID==0)
	{
	return "There are no instances.";
	}

	$Sql = "select Location from Server where ServerIP='$ServerIP'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{ 
		$Location=$Row['Location'];
	}

	$Hostname="vps{$VPSID}.blackhost.com";
	$ExpiresOn=date('Y-m-d', strtotime('+1 month'));
	$TimeStamp=time();
	SQL("UPDATE VPS SET CustomerID='$CustomerID',File='$File',DiskSpace='$DiskSpace',Cores='$Cores',Memory='$Memory',Hostname='$Hostname',VPSName='$VPSName',PlanName='$PlanName',Price='$Price',ExpiresOn='$ExpiresOn',Location='$Location',Renew='1',Suspend='0',TimeStamp='$TimeStamp' where VPSID='$VPSID'");

	// Create Invoice and Charge Amount from Customer
	$Amount=$Price*-1;
	$Success=Invoice ($CustomerID,"$PlanName ($IP)",$Amount,"Entry for 1 month");

	if ($Success==1)
	{
	
		if ($VPSOffer=="Buy 1 Get 1")
		{
			$VPSID=0;
			$Sql = "select * from VPS where CustomerID='0' and DiskType='$DiskType' and Location='$Location' ORDER BY TimeStamp LIMIT 1";
			$Result = SQL($Sql);
			foreach ($Result as $Row)
			{ 
				$VPSID=$Row['VPSID'];
				$IP=$Row['IP'];
				$ServerIP=$Row['ServerIP'];
			}
		
			$Sql = "select Location from Server where ServerIP='$ServerIP'";
			$Result = SQL($Sql);
			foreach ($Result as $Row)
			{ 
				$Location=$Row['Location'];
			}

			$Hostname="vps{$VPSID}.blackhost.com";
			$ExpiresOn=date('Y-m-d', strtotime('+1 month'));
			$TimeStamp=time();
			SQL("UPDATE VPS SET CustomerID='$CustomerID',File='$File',DiskSpace='$DiskSpace',Cores='$Cores',Memory='$Memory',Hostname='$Hostname',VPSName='$VPSName',PlanName='$PlanName',Price='$Price',ExpiresOn='$ExpiresOn',Location='$Location',Renew='1',Suspend='0',TimeStamp='$TimeStamp' where VPSID='$VPSID'");

			// Create Invoice (Buy One Get One)
			$Amount=0;
			Invoice ($CustomerID,"$PlanName ($IP)",$Amount,"Buy 1 Get 1");

		}
	
		return "1";

				
	}
	else
	{

		// Make Expure Date today bz Invoice not completed
		$ExpiresOn=date('Y-m-d');
		SQL("UPDATE VPS SET ExpiresOn='$ExpiresOn' where VPSID='$VPSID'");

		return "Failed";

	}
	

}


function Subnet ($SubnetIP,$CIDR,$ServerIP)
{

	if ($CIDR<24 or $CIDR>30)
	{
	return 0;
	}

	if ($CIDR=="30") {$Hosts=2;}
	if ($CIDR=="29") {$Hosts=6;}
	if ($CIDR=="28") {$Hosts=14;}
	if ($CIDR=="27") {$Hosts=30;}
	if ($CIDR=="26") {$Hosts=62;}
	if ($CIDR=="25") {$Hosts=126;}
	if ($CIDR=="24") {$Hosts=254;}

	$IPArray=explode(".",$SubnetIP);
	$A=$IPArray[0];
	$B=$IPArray[1];
	$C=$IPArray[2];
	$D=$IPArray[3];

	$Gateway="$A.$B.$C.".($D+1);

	echo "Gateway: $Gateway<br>";

	echo "<hr>";

	$Sql = "select * from Server where ServerIP='$ServerIP'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{ 
		$Location=$Row['Location'];
		$DiskType=$Row['DiskType'];
		$AvailablePlan=$Row['AvailablePlan'];
	}

	$Sql = "select * from Plan where DiskType='$DiskType' order by Price LIMIT 1";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		$PlanName=$Row['PlanName'];
		$DiskSpace=$Row['DiskSpace'];
		$Cores=$Row['Cores'];
		$Memory=$Row['Memory'];
		$Price=$Row['Price'];
	}
	
	$ID=0;
	$Result = SQL("select ID from VPS where ServerIP='$ServerIP' order by ID DESC");
	foreach ($Result as $Row)
	{
		$ID=$Row['ID'];
	}
	if ($ID==0) {$ID=100;}
	
				
	for ($N=$D+2;$N<=$D+$Hosts;$N++)
	{
		$IP="$A.$B.$C.".($N);
		
		if ($IP!=$ServerIP)
		{
			echo "$IP<br>";

			$TimeStamp=time();
			$ID++;
			$CustomerID=0;
			$ExpiresOn=date('Y-m-d');
			$Hostname="vps{$TimeStamp}{$N}.blackhost.com";
			$MAC=GenerateMAC();
			SQL("INSERT INTO VPS (ID,ServerIP,IP,CIDR,Gateway,MAC,CustomerID,File,DiskType,DiskSpace,Cores,Memory,Hostname,VPSName,PlanName,Price,ExpiresOn,Location,AvailablePlan,TimeStamp) VALUES ('$ID','$ServerIP','$IP','$CIDR','$Gateway','$MAC','$CustomerID','$File','$DiskType','$DiskSpace','$Cores','$Memory','$Hostname','$VPSName','$PlanName','$Price','$ExpiresOn','$Location','$AvailablePlan','$TimeStamp')");
		}
		
	}

}

function GenerateMAC()
{

	$MAC="00";
	for ($N=0;$N<5;$N++)
	{
		$OCT = sprintf("%02s",strtoupper(dechex(mt_rand(0,255))));
		$MAC.=":".$OCT;
	}

	return $MAC;
}

function MAC()
{

	for ($N=0;$N<=100;$N++)
	{

		$VPSID=0;
		$Result = SQL("select * from VPS where MAC=''");
		foreach ($Result as $Row)
		{
			$VPSID=$Row['VPSID'];
			$IP=$Row['IP'];
		}
		
		if ($VPSID==0)
		{
		break;
		}

		$MAC=GenerateMAC();

		$Exists=0;
		$Result = SQL("select MAC from VPS where MAC='$MAC'");
		foreach ($Result as $Row)
		{
			$Exists=1;
		}
		
		if ($Exists==0)
		{
		$Result = SQL("UPDATE VPS SET MAC='$MAC' where VPSID='$VPSID' and MAC=''");
		
		echo "$IP >> $MAC <br>";
		}
		
	}
		

}

function ClientIP()
{
    // Get real visitor IP behind CloudFlare network
    if (isset($_SERVER["HTTP_CF_CONNECTING_IP"])) {
              $_SERVER['REMOTE_ADDR'] = $_SERVER["HTTP_CF_CONNECTING_IP"];
              $_SERVER['HTTP_CLIENT_IP'] = $_SERVER["HTTP_CF_CONNECTING_IP"];
    }
    $client  = @$_SERVER['HTTP_CLIENT_IP'];
    $forward = @$_SERVER['HTTP_X_FORWARDED_FOR'];
    $remote  = $_SERVER['REMOTE_ADDR'];

    if(filter_var($client, FILTER_VALIDATE_IP))
    {
        $ip = $client;
    }
    elseif(filter_var($forward, FILTER_VALIDATE_IP))
    {
        $ip = $forward;
    }
    else
    {
        $ip = $remote;
    }

    return $ip;
}

function ServerIP()
{

	$ServerIP=Content("https://checkip.amazonaws.com");
	
	$ServerIP=trim($ServerIP);
	
	return $ServerIP;

}

function Content($URL,$Timeout=5)
{
    $CH = curl_init();
    curl_setopt($CH, CURLOPT_URL, $URL);
    curl_setopt($CH, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($CH, CURLOPT_TIMEOUT, $Timeout);
    curl_setopt($CH, CURLOPT_CONNECTTIMEOUT, $Timeout);
    
    $Response = curl_exec($CH);
    
	if ($Response === false) 
	{
        // return curl_error($CH));
		return "";
    }
    
    curl_close($CH);
    return $Response;
}


function TableName($SQL)
{
	$SQL=str_ireplace("OR IGNORE","",$SQL);

    $SQL = trim(preg_replace('/\s+/', ' ', $SQL));
    if (empty($SQL)) 
	{
        return "";
    }

    if (preg_match('/^\s*SELECT\s+.+?\s+FROM\s+([^\s,)(;]+)/i', $SQL, $Match)) 
	{
        $TableName=$Match[1];
    } 
	elseif (preg_match('/^\s*INSERT\s+INTO\s+([^\s,)(;]+)/i', $SQL, $Match)) 
	{
        $TableName=$Match[1];
    } 
	elseif (preg_match('/^\s*UPDATE\s+([^\s,)(;]+)/i', $SQL, $Match)) 
	{
        $TableName=$Match[1];
    } 
	elseif (preg_match('/^\s*DELETE\s+FROM\s+([^\s,)(;]+)/i', $SQL, $Match)) 
	{
        $TableName=$Match[1];
    } 
	elseif (preg_match('/^\s*CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([^\s,)(;]+)/i', $SQL, $Match)) 
	{
        $TableName=$Match[1];
    } 
	elseif (preg_match('/^\s*ALTER\s+TABLE\s+([^\s,)(;]+)/i', $SQL, $Match)) 
	{
        $TableName=$Match[1];
    } 
	elseif (preg_match('/^\s*DROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?([^\s,)(;]+)/i', $SQL, $Match)) 
	{
        $TableName=$Match[1];
    } 
	elseif (preg_match('/^\s*TRUNCATE\s+TABLE\s+([^\s,)(;]+)/i', $SQL, $Match)) 
	{
        $TableName=$Match[1];
    }

    $TableName = preg_replace('/^.*\./','',$TableName);
    $TableName = trim($TableName,'`\'"[]');
    
    // Handle AS aliases
    if (preg_match('/(\S+)(?:\s+AS\s+\S+)?$/i', $TableName, $Match)) 
	{
        $TableName=$Match[1];
    }
    
	$TableName=strtolower($TableName);
	
	return $TableName;

}

function SVG($File,$Color="#000000")
{
    $SVG=file_get_contents($File);
	$SVG= preg_replace('/#[0-9A-Fa-f]{6}/',$Color,$SVG);
	$SVG=preg_replace('/\s(width|height)=["\'][^"\']*["\']/','',$SVG);
    echo $SVG;
}


function MariaDBSQL($SQL,$TTL=0,$Memory=0)
{
	global $PDO;

	$Domain = preg_replace("/^www\./","",$_SERVER['SERVER_NAME']);

	if ($TTL>0)
	{
		if ($Memory==1)
		{
			// Cache in Memory
			$Redis=new Redis();
			$Redis->connect('127.0.0.1', 6379);
			$Key=md5($Domain.$SQL);
		
			if ($Redis->get($Key))
			{
				echo "Get Memory";
				$Result = unserialize($Redis->get($Key));
			}
			else
			{
			
				if (stripos($SQL,"SELECT COUNT")===0)
				{
				$Result = $PDO->query($SQL)->fetchColumn();
				
				$Redis->set($Key, serialize($Result));
				$Redis->expire($Key,$TTL);
				}
				elseif (stripos($SQL,"SELECT")===0)
				{
				$Result = $PDO->query($SQL)->fetchAll();
				
				$Redis->set($Key, serialize($Result));
				$Redis->expire($Key,$TTL);
				}
				elseif (stripos($SQL,"INSERT")==0)
				{
				$Result = $PDO->query($SQL);
				return $PDO->lastInsertId(); 	
				}
				else
				{
				$Result = $PDO->query($SQL);
				return $Result->rowCount();
				}
				
			}
		}
		else
		{
			// Cache in Disk
			$Key=md5($Domain.$SQL).".key";
			$P=time()-filemtime("/usr/local/goadmio/cache/$Key");
			if (file_exists("/usr/local/goadmio/cache/$Key") and $P<=$TTL)
			{
			$Result = unserialize(file_get_contents("/usr/local/goadmio/cache/$Key"));
			}
			else
			{
			
				if (stripos($SQL,"SELECT COUNT")===0)
				{
				$Result = $PDO->query($SQL)->fetchColumn();
				
				file_put_contents("/usr/local/goadmio/cache/$Key",serialize($Result));
				}
				elseif (stripos($SQL,"SELECT")===0)
				{
					$Result = $PDO->query($SQL)->fetchAll();
				
					file_put_contents("/usr/local/goadmio/cache/$Key",serialize($Result));
				}
				elseif (stripos($SQL,"INSERT")==0)
				{
				$Result = $PDO->query($SQL);
				return $PDO->lastInsertId(); 	
				}
				else
				{
				$Result = $PDO->query($SQL);
				return $Result->rowCount();
				}
			}
		}
	}
	else
	{
	
			
		if (stripos($SQL,"SELECT COUNT")===0)
		{
		$Result = $PDO->query($SQL)->fetchColumn();
		}
		elseif (stripos($SQL,"SELECT")===0)
		{
		$Result = $PDO->query($SQL)->fetchAll();
		}
		elseif (stripos($SQL,"INSERT")===0)
		{
		$Result = $PDO->query($SQL);
		return $PDO->lastInsertId(); 	
		}
		else
		{
		$Result = $PDO->query($SQL);
		return $Result->rowCount();
		}
	}

	return $Result;
}




function Progress($ProgressTitle, $ProgressFile)
{
    $Code = "
    <form name='ProgressForm'>
        <input type='hidden' name='ProgressFile' value='$ProgressFile'> 
    </form>
    <div style='margin: 20px;'>
        <table cellpadding='0' cellspacing='0' style='width:100%;margin-left: auto; margin-right: auto;'>
            <tr>
                <td align='left' width='50%' height='40' style='font-family: Arial; font-size: 14px; color: var(--text-primary);'>
                    $ProgressTitle
                </td>
                <td align='right' width='50%' height='40' style='font-family: Arial; font-size: 12px; color: var(--text-secondary);'>
                    <div id='Complete' style='transition: all 0.3s ease;'>0% Complete</div>
                </td>
            </tr>
            <tr>
                <td colspan='2' width='100%' style='background:var(--progress-bar-background; border-radius: 4px; overflow: hidden;'>
				
                    <table id='ProgressBar' cellpadding='0' cellspacing='0' width='0%' style='background:var(--progress-bar-fill);transition: width 0.5s cubic-bezier(0.4, 0, 0.2, 1); display: block;'>
					<td height='9' style='border-radius: 4px;'></td>
                    </table>
					
                </td>
            </tr>
            <tr>
                <td colspan='2' align='left' width='100%' height='40' style='font-family: Arial; font-size: 12px; color: var(--text-secondary);'>
                    <div id='ProgressMessage' style='transition: all 0.3s ease;'></div>
                </td>
            </tr>
        </table>
    </div>
    ";
    
    return $Code;
}

function CommandSafe(string $command, string $userHome)
{
    // 1. Normalise and verify user home exists
    $realHome = realpath($userHome);
    if ($realHome === false) {
        return false;
    }

    // 2. Reject shell metacharacters and command substitution (excluding harmless glob chars)
    $dangerousChars = [
        '`', '$(', ')', '|', '&', ';', '<', '>', '\\', "\n", "\r",
        '${', '$IFS', '%'
    ];
    foreach ($dangerousChars as $char) {
        if (strpos($command, $char) !== false) {
            return false;
        }
    }

    // Reject obvious eval/exec patterns
    if (preg_match('/\b(eval|exec|system|popen|proc_open|shell_exec|passthru)\b/', $command)) {
        return false;
    }

    // 3. Tokenise the command (same as original, respecting quotes)
    $tokens = [];
    $len = strlen($command);
    $i = 0;
    $inQuote = null;
    $current = '';
    while ($i < $len) {
        $ch = $command[$i];
        if ($inQuote === null && $ch === ' ') {
            if ($current !== '') {
                $tokens[] = $current;
                $current = '';
            }
            $i++;
            continue;
        }
        if ($ch === '"' || $ch === "'") {
            if ($inQuote === null) {
                $inQuote = $ch;
            } elseif ($inQuote === $ch) {
                $inQuote = null;
            } else {
                $current .= $ch;
            }
            $i++;
            continue;
        }
        $current .= $ch;
        $i++;
    }
    if ($current !== '') {
        $tokens[] = $current;
    }

    if (empty($tokens)) {
        return false;
    }

    $cmd = $tokens[0];
    $args = array_slice($tokens, 1);

    // 4. Whitelist of safe commands – now includes 'php'
    $safeCommands = [
        'ls', 'cat', 'head', 'tail', 'grep', 'wc', 'echo', 'printf',
        'basename', 'dirname', 'realpath', 'rm', 'find', 'php'
    ];
    if (!in_array($cmd, $safeCommands)) {
        return false;
    }

    // 5. Allowed flags (original + rm + php)
    $allowedFlags = [
        'ls'      => ['-l', '-a', '-A', '-d', '-F', '-g', '-h', '-i', '-L', '-r', '-R', '-S', '-t', '-1', '--color', '--help'],
        'cat'     => ['-n', '-b', '-s', '-T', '-E', '-v', '--help'],
        'head'    => ['-n', '-c', '-q', '-v', '--help'],
        'tail'    => ['-n', '-c', '-q', '-v', '-f', '--help'],
        'grep'    => ['-i', '-v', '-c', '-l', '-n', '-h', '-s', '-w', '-x', '-F', '--help'],
        'wc'      => ['-c', '-l', '-w', '-m', '-L', '--help'],
        'echo'    => ['-n', '-e'],
        'printf'  => [],
        'basename'=> ['--help'],
        'dirname' => ['--help'],
        'realpath'=> ['--help'],
        'rm'      => ['-i', '-v', '-d', '--help'],
        'php'     => ['-f', '--help']
    ];
    $cmdFlags = $allowedFlags[$cmd] ?? ['--help'];

    // Helper to check if a path component is a symlink (validation‑time only)
    $containsSymlink = function(string $path) use ($realHome): bool {
        $parts = explode(DIRECTORY_SEPARATOR, ltrim($path, DIRECTORY_SEPARATOR));
        $current = '';
        foreach ($parts as $part) {
            if ($part === '') continue;
            $current .= DIRECTORY_SEPARATOR . $part;
            if (is_link($current)) {
                return true;
            }
        }
        return false;
    };

    // Helper to resolve a path to canonical, symlink‑free absolute path.
    $resolvePathStrict = function(string $arg) use ($realHome, $containsSymlink) {
        // Expand ~/ or ~
        if (strpos($arg, '~/') === 0) {
            $arg = $realHome . DIRECTORY_SEPARATOR . substr($arg, 2);
        } elseif ($arg === '~') {
            $arg = $realHome;
        }

        // Make relative paths absolute relative to $realHome
        if ($arg[0] !== DIRECTORY_SEPARATOR) {
            $arg = $realHome . DIRECTORY_SEPARATOR . $arg;
        }

        // Reject immediately if any component is a symlink
        if ($containsSymlink($arg)) {
            return false;
        }

        $resolved = realpath($arg);
        if ($resolved === false) {
            return false;
        }

        if (strpos($resolved, $realHome . DIRECTORY_SEPARATOR) !== 0 && $resolved !== $realHome) {
            return false;
        }

        if ($containsSymlink($resolved)) {
            return false;
        }

        return $resolved;
    };

    // 6. Validate arguments according to command type
    $resolvedArgs = [];

    // ---------- Special handling for 'find' ----------
    if ($cmd === 'find') {
        $allowedPrimaries = [
            '-delete', '-print', '-print0', '-ls',
            '-name', '-iname', '-path', '-ipath', '-type', '-size', '-mtime', '-atime', '-ctime',
            '-user', '-group', '-perm', '-empty', '-nogroup', '-nouser',
            '-newer', '-anewer', '-cnewer',
            '-not', '!', '-and', '-a', '-or', '-o', '-maxdepth', '-mindepth', '-depth', '-regex', '-iregex'
        ];
        $primariesWithArgs = [
            '-name', '-iname', '-path', '-ipath', '-type', '-size', '-mtime', '-atime', '-ctime',
            '-user', '-group', '-perm', '-newer', '-anewer', '-cnewer', '-maxdepth', '-mindepth',
            '-regex', '-iregex'
        ];
        $forbiddenPrimaries = [
            '-exec', '-execdir', '-ok', '-okdir', '-printf', '-fprintf', '-fls', '-fprint',
            '-follow', '-L', '-H'
        ];

        $startDir = null;
        $findArgs = [];
        $idx = 0;
        $cnt = count($args);

        while ($idx < $cnt) {
            $arg = $args[$idx];
            if ($startDir === null && strpos($arg, '-') !== 0) {
                $resolved = $resolvePathStrict($arg);
                if ($resolved === false) {
                    return false;
                }
                $startDir = $resolved;
                $findArgs[] = $resolved;
                $idx++;
                continue;
            }
            if (strpos($arg, '-') === 0) {
                if (in_array($arg, $forbiddenPrimaries)) {
                    return false;
                }
                if (!in_array($arg, $allowedPrimaries)) {
                    return false;
                }
                $findArgs[] = $arg;
                $idx++;

                if (in_array($arg, $primariesWithArgs)) {
                    if ($idx >= $cnt) {
                        return false;
                    }
                    $argVal = $args[$idx];
                    if (preg_match('/[`$();<>|&]/', $argVal)) {
                        return false;
                    }
                    $findArgs[] = $argVal;
                    $idx++;
                }
            } else {
                return false;
            }
        }

        if ($startDir === null) {
            $findArgs = array_merge([$realHome], array_slice($findArgs, 0));
        }

        $resolvedArgs = $findArgs;
    }
    // ---------- Special handling for 'php' ----------
    elseif ($cmd === 'php') {
        $scriptPath = null;
        $phpArgs = [];
        $idx = 0;
        $cnt = count($args);

        // Process optional -f flag
        if ($idx < $cnt && $args[$idx] === '-f') {
            $idx++;
            if ($idx >= $cnt) {
                return false;
            }
        }
        // Now the script path must be the next argument
        if ($idx >= $cnt) {
            return false;
        }
        $scriptArg = $args[$idx++];
        $resolvedScript = $resolvePathStrict($scriptArg);
        if ($resolvedScript === false) {
            return false;
        }
        $phpArgs[] = $resolvedScript;

        // Any remaining arguments are passed verbatim to the script (not resolved as paths)
        while ($idx < $cnt) {
            $extra = $args[$idx++];
            if (preg_match('/[`$();<>|&]/', $extra)) {
                return false;
            }
            $phpArgs[] = $extra;
        }

        // No other PHP flags (like -r, -a, -d, etc.) are permitted
        for ($i = 0; $i < $idx - 1; $i++) {
            if (strpos($args[$i], '-') === 0 && $args[$i] !== '-f') {
                return false;
            }
        }

        $resolvedArgs = $phpArgs;
    }
    // ---------- Standard handling for all other commands ----------
    else {
        foreach ($args as $arg) {
            // Flag handling
            if ($arg[0] === '-') {
                if (strpos($arg, '=') !== false) {
                    return false;
                }
                if (!in_array($arg, $cmdFlags)) {
                    return false;
                }
                $resolvedArgs[] = $arg;
                continue;
            }

            // Non‑flag argument – must be a path, resolve strictly
            $resolved = $resolvePathStrict($arg);
            if ($resolved === false) {
                return false;
            }
            $resolvedArgs[] = $resolved;
        }
    }

    // 7. Command‑specific extra restrictions
    switch ($cmd) {
        case 'grep':
            $dangerous = ['-r', '-R', '--recursive', '--exclude', '--include', '-Z', '--null', '--label'];
            foreach ($resolvedArgs as $arg) {
                if (in_array($arg, $dangerous) || strpos($arg, '--colour') === 0) {
                    return false;
                }
            }
            break;
        case 'rm':
            foreach ($resolvedArgs as $arg) {
                if ($arg === '/' || $arg === $realHome || (dirname($arg) === $realHome && basename($arg) === '..')) {
                    return false;
                }
            }
            break;
    }

    // 8. Build the final safe command
    $escapedCmd = escapeshellarg($cmd);
    $escapedArgs = array_map('escapeshellarg', $resolvedArgs);
    $finalCommand = $escapedCmd . (empty($escapedArgs) ? '' : ' ' . implode(' ', $escapedArgs));

    return $finalCommand;
}


function CallCode()
{
    // Fetch IP info (silence errors with @)
    $Code = @file_get_contents("https://ipinfo.io/{$_SERVER['REMOTE_ADDR']}");

    // If API call fails, return null (or change to a default like '+1')
    if ($Code === false) {
        return null;
    }

    $CodeArray = json_decode($Code);

    // Ensure we have a valid country code
    if (!isset($CodeArray->country) || !is_string($CodeArray->country)) {
        return null;
    }

    $CountryCode = strtoupper($CodeArray->country);

    // --------------------------------------------------------------
    // FULL list of country calling codes (ISO 3166-1 alpha‑2 → dial code)
    // Sorted by country code for easy maintenance.
    // --------------------------------------------------------------
    $CountryDialingCodes = [
        'AC' => '+247',  // Ascension Island
        'AD' => '+376',  // Andorra
        'AE' => '+971',  // United Arab Emirates
        'AF' => '+93',   // Afghanistan
        'AG' => '+1',    // Antigua and Barbuda (shares +1 with US/CA)
        'AI' => '+1',    // Anguilla
        'AL' => '+355',  // Albania
        'AM' => '+374',  // Armenia
        'AO' => '+244',  // Angola
        'AQ' => '+672',  // Antarctica (Australian bases)
        'AR' => '+54',   // Argentina
        'AS' => '+1',    // American Samoa
        'AT' => '+43',   // Austria
        'AU' => '+61',   // Australia
        'AW' => '+297',  // Aruba
        'AX' => '+358',  // Åland Islands
        'AZ' => '+994',  // Azerbaijan
        'BA' => '+387',  // Bosnia and Herzegovina
        'BB' => '+1',    // Barbados
        'BD' => '+880',  // Bangladesh
        'BE' => '+32',   // Belgium
        'BF' => '+226',  // Burkina Faso
        'BG' => '+359',  // Bulgaria
        'BH' => '+973',  // Bahrain
        'BI' => '+257',  // Burundi
        'BJ' => '+229',  // Benin
        'BL' => '+590',  // Saint Barthélemy
        'BM' => '+1',    // Bermuda
        'BN' => '+673',  // Brunei Darussalam
        'BO' => '+591',  // Bolivia (Plurinational State of)
        'BQ' => '+599',  // Bonaire, Sint Eustatius and Saba
        'BR' => '+55',   // Brazil
        'BS' => '+1',    // Bahamas
        'BT' => '+975',  // Bhutan
        'BV' => '+47',   // Bouvet Island (uses +47)
        'BW' => '+267',  // Botswana
        'BY' => '+375',  // Belarus
        'BZ' => '+501',  // Belize
        'CA' => '+1',    // Canada
        'CC' => '+61',   // Cocos (Keeling) Islands (Australia)
        'CD' => '+243',  // Congo, Democratic Republic of the
        'CF' => '+236',  // Central African Republic
        'CG' => '+242',  // Congo (Republic of the)
        'CH' => '+41',   // Switzerland
        'CI' => '+225',  // Côte d'Ivoire
        'CK' => '+682',  // Cook Islands
        'CL' => '+56',   // Chile
        'CM' => '+237',  // Cameroon
        'CN' => '+86',   // China
        'CO' => '+57',   // Colombia
        'CR' => '+506',  // Costa Rica
        'CU' => '+53',   // Cuba
        'CV' => '+238',  // Cabo Verde
        'CW' => '+599',  // Curaçao
        'CX' => '+61',   // Christmas Island (Australia)
        'CY' => '+357',  // Cyprus
        'CZ' => '+420',  // Czechia
        'DE' => '+49',   // Germany
        'DJ' => '+253',  // Djibouti
        'DK' => '+45',   // Denmark
        'DM' => '+1',    // Dominica
        'DO' => '+1',    // Dominican Republic (shares +1)
        'DZ' => '+213',  // Algeria
        'EC' => '+593',  // Ecuador
        'EE' => '+372',  // Estonia
        'EG' => '+20',   // Egypt
        'EH' => '+212',  // Western Sahara (uses Morocco +212)
        'ER' => '+291',  // Eritrea
        'ES' => '+34',   // Spain
        'ET' => '+251',  // Ethiopia
        'FI' => '+358',  // Finland
        'FJ' => '+679',  // Fiji
        'FK' => '+500',  // Falkland Islands (Malvinas)
        'FM' => '+691',  // Micronesia (Federated States of)
        'FO' => '+298',  // Faroe Islands
        'FR' => '+33',   // France
        'GA' => '+241',  // Gabon
        'GB' => '+44',   // United Kingdom
        'GD' => '+1',    // Grenada
        'GE' => '+995',  // Georgia
        'GF' => '+594',  // French Guiana
        'GG' => '+44',   // Guernsey (UK)
        'GH' => '+233',  // Ghana
        'GI' => '+350',  // Gibraltar
        'GL' => '+299',  // Greenland
        'GM' => '+220',  // Gambia
        'GN' => '+224',  // Guinea
        'GP' => '+590',  // Guadeloupe
        'GQ' => '+240',  // Equatorial Guinea
        'GR' => '+30',   // Greece
        'GS' => '+500',  // South Georgia and the South Sandwich Islands
        'GT' => '+502',  // Guatemala
        'GU' => '+1',    // Guam
        'GW' => '+245',  // Guinea-Bissau
        'GY' => '+592',  // Guyana
        'HK' => '+852',  // Hong Kong
        'HM' => '+672',  // Heard Island and McDonald Islands (Australia)
        'HN' => '+504',  // Honduras
        'HR' => '+385',  // Croatia
        'HT' => '+509',  // Haiti
        'HU' => '+36',   // Hungary
        'ID' => '+62',   // Indonesia
        'IE' => '+353',  // Ireland
        'IL' => '+972',  // Israel
        'IM' => '+44',   // Isle of Man (UK)
        'IN' => '+91',   // India
        'IO' => '+246',  // British Indian Ocean Territory
        'IQ' => '+964',  // Iraq
        'IR' => '+98',   // Iran (Islamic Republic of)
        'IS' => '+354',  // Iceland
        'IT' => '+39',   // Italy
        'JE' => '+44',   // Jersey (UK)
        'JM' => '+1',    // Jamaica
        'JO' => '+962',  // Jordan
        'JP' => '+81',   // Japan
        'KE' => '+254',  // Kenya
        'KG' => '+996',  // Kyrgyzstan
        'KH' => '+855',  // Cambodia
        'KI' => '+686',  // Kiribati
        'KM' => '+269',  // Comoros
        'KN' => '+1',    // Saint Kitts and Nevis
        'KP' => '+850',  // Korea (Democratic People's Republic of)
        'KR' => '+82',   // Korea (Republic of)
        'KW' => '+965',  // Kuwait
        'KY' => '+1',    // Cayman Islands
        'KZ' => '+7',    // Kazakhstan
        'LA' => '+856',  // Lao People's Democratic Republic
        'LB' => '+961',  // Lebanon
        'LC' => '+1',    // Saint Lucia
        'LI' => '+423',  // Liechtenstein
        'LK' => '+94',   // Sri Lanka
        'LR' => '+231',  // Liberia
        'LS' => '+266',  // Lesotho
        'LT' => '+370',  // Lithuania
        'LU' => '+352',  // Luxembourg
        'LV' => '+371',  // Latvia
        'LY' => '+218',  // Libya
        'MA' => '+212',  // Morocco
        'MC' => '+377',  // Monaco
        'MD' => '+373',  // Moldova (Republic of)
        'ME' => '+382',  // Montenegro
        'MF' => '+590',  // Saint Martin (French part)
        'MG' => '+261',  // Madagascar
        'MH' => '+692',  // Marshall Islands
        'MK' => '+389',  // North Macedonia
        'ML' => '+223',  // Mali
        'MM' => '+95',   // Myanmar
        'MN' => '+976',  // Mongolia
        'MO' => '+853',  // Macao
        'MP' => '+1',    // Northern Mariana Islands
        'MQ' => '+596',  // Martinique
        'MR' => '+222',  // Mauritania
        'MS' => '+1',    // Montserrat
        'MT' => '+356',  // Malta
        'MU' => '+230',  // Mauritius
        'MV' => '+960',  // Maldives
        'MW' => '+265',  // Malawi
        'MX' => '+52',   // Mexico
        'MY' => '+60',   // Malaysia
        'MZ' => '+258',  // Mozambique
        'NA' => '+264',  // Namibia
        'NC' => '+687',  // New Caledonia
        'NE' => '+227',  // Niger
        'NF' => '+672',  // Norfolk Island
        'NG' => '+234',  // Nigeria
        'NI' => '+505',  // Nicaragua
        'NL' => '+31',   // Netherlands
        'NO' => '+47',   // Norway
        'NP' => '+977',  // Nepal
        'NR' => '+674',  // Nauru
        'NU' => '+683',  // Niue
        'NZ' => '+64',   // New Zealand
        'OM' => '+968',  // Oman
        'PA' => '+507',  // Panama
        'PE' => '+51',   // Peru
        'PF' => '+689',  // French Polynesia
        'PG' => '+675',  // Papua New Guinea
        'PH' => '+63',   // Philippines
        'PK' => '+92',   // Pakistan
        'PL' => '+48',   // Poland
        'PM' => '+508',  // Saint Pierre and Miquelon
        'PN' => '+64',   // Pitcairn (uses +64)
        'PR' => '+1',    // Puerto Rico
        'PS' => '+970',  // Palestine, State of
        'PT' => '+351',  // Portugal
        'PW' => '+680',  // Palau
        'PY' => '+595',  // Paraguay
        'QA' => '+974',  // Qatar
        'RE' => '+262',  // Réunion
        'RO' => '+40',   // Romania
        'RS' => '+381',  // Serbia
        'RU' => '+7',    // Russian Federation
        'RW' => '+250',  // Rwanda
        'SA' => '+966',  // Saudi Arabia
        'SB' => '+677',  // Solomon Islands
        'SC' => '+248',  // Seychelles
        'SD' => '+249',  // Sudan
        'SE' => '+46',   // Sweden
        'SG' => '+65',   // Singapore
        'SH' => '+290',  // Saint Helena, Ascension and Tristan da Cunha
        'SI' => '+386',  // Slovenia
        'SJ' => '+47',   // Svalbard and Jan Mayen (Norway)
        'SK' => '+421',  // Slovakia
        'SL' => '+232',  // Sierra Leone
        'SM' => '+378',  // San Marino
        'SN' => '+221',  // Senegal
        'SO' => '+252',  // Somalia
        'SR' => '+597',  // Suriname
        'SS' => '+211',  // South Sudan
        'ST' => '+239',  // Sao Tome and Principe
        'SV' => '+503',  // El Salvador
        'SX' => '+1',    // Sint Maarten (Dutch part)
        'SY' => '+963',  // Syrian Arab Republic
        'SZ' => '+268',  // Eswatini (Swaziland)
        'TA' => '+290',  // Tristan da Cunha (part of SH)
        'TC' => '+1',    // Turks and Caicos Islands
        'TD' => '+235',  // Chad
        'TF' => '+262',  // French Southern Territories
        'TG' => '+228',  // Togo
        'TH' => '+66',   // Thailand
        'TJ' => '+992',  // Tajikistan
        'TK' => '+690',  // Tokelau
        'TL' => '+670',  // Timor-Leste
        'TM' => '+993',  // Turkmenistan
        'TN' => '+216',  // Tunisia
        'TO' => '+676',  // Tonga
        'TR' => '+90',   // Turkey
        'TT' => '+1',    // Trinidad and Tobago
        'TV' => '+688',  // Tuvalu
        'TW' => '+886',  // Taiwan (Province of China)
        'TZ' => '+255',  // Tanzania, United Republic of
        'UA' => '+380',  // Ukraine
        'UG' => '+256',  // Uganda
        'US' => '+1',    // United States of America
        'UY' => '+598',  // Uruguay
        'UZ' => '+998',  // Uzbekistan
        'VA' => '+379',  // Holy See (Vatican City State)
        'VC' => '+1',    // Saint Vincent and the Grenadines
        'VE' => '+58',   // Venezuela (Bolivarian Republic of)
        'VG' => '+1',    // Virgin Islands (British)
        'VI' => '+1',    // Virgin Islands (U.S.)
        'VN' => '+84',   // Viet Nam
        'VU' => '+678',  // Vanuatu
        'WF' => '+681',  // Wallis and Futuna
        'WS' => '+685',  // Samoa
        'XK' => '+383',  // Kosovo (unofficial but widely used)
        'YE' => '+967',  // Yemen
        'YT' => '+262',  // Mayotte
        'ZA' => '+27',   // South Africa
        'ZM' => '+260',  // Zambia
        'ZW' => '+263',  // Zimbabwe
    ];

    // Return the dialing code if found, otherwise null
    return $CountryDialingCodes[$CountryCode] ?? null;
}

?>