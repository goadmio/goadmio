<?php




        // دالة إعداد موقع جديد
        function CreateNewAccount($ResellerUsername,$ResellerPassword,$ResellerDomain,$Package,$Domain,$Username,$Password,$AccountQuota,$CgiAccess,$FrontpageExtentions,$FtpAccounts,$EmailAccounts,$EmailLists,$SQLDatabases,$SubDomains,$ParkDomains,$AddonDomains,$BandwidthLimit,$CPanelTheme,$IPAddress)
        {
        $NewAccountUrl = "http://$ResellerUsername:$ResellerPassword@$ResellerDomain:2086/scripts/wwwacct?plan=$Package&domain=$Domain&Username=$Username&password=$Password&quota=$AccountQuota&cgi=$CgiAccess&frontpage=$FrontpageExtentions&maxftp=$FtpAccounts&maxpop=$EmailAccounts&maxlst=$EmailLists&maxsql=$SQLDatabases&maxsub=$SubDomains&maxpark=$ParkDomains&maxaddon=$AddonDomains&bwlimit=$BandwidthLimit&cpmod=$CPanelTheme&customip=$IPAddress/";

	// Old PHP Version
	// $File=@fopen("$NewAccountUrl","r");

		$File=@file_get_contents($NewAccountUrl);
       		if ($File)
        	{
        	$Success=1;
        	}
        	else
        	{
        	$Success=0;
        	}

    return $Success;
    }

        // دالة جذف موقع
        function TerminateAccount($ResellerUsername,$ResellerPassword,$ResellerDomain,$Username)
        {
        $DeleteAccountUrl = "http://$ResellerUsername:$ResellerPassword@$ResellerDomain:2086/scripts/killacct?domain=$Username&user=$Username&submit-domain=Terminate";

	// Old PHP version
	// $File=@fopen("$DeleteAccountUrl","r");

	$File=@file_get_contents($DeleteAccountUrl);
        if ($File)
        {
        $Success=1;
        }
        else
        {
        $Success=0;
        }

    return $Success;
    }

    // دالة تغيير كلمة مرور موقع
      	function PasswordModification($ResellerUsername,$ResellerPassword,$ResellerDomain,$Username,$NewPassword)
	{
        $ChangePwdUrl = "http://$ResellerUsername:$ResellerPassword@$ResellerDomain:2086/scripts/passwd?password=$NewPassword&domain=$Username&user=$Username&submit-domain=Change%0D%0A++++++Password";

	// Old Version
	// $File=@fopen("$ChangePwdUrl","r");

	$File=@file_get_contents($ChangePwdUrl);
        if ($File)
        {
        $X=@fclose($File);
        $Success=1;
        }
        else
        {
        $Success=0;
        }

    return $Success;
    }


        // دالة إضافة قاعدة بيانات
        function CreateMysqlDB($DomainUsername,$ResellerPassword,$ResellerIP,$DBName)
        {
        $AccessUrl = "http://$DomainUsername:$ResellerPassword@$ResellerIP:2082/frontend/x2/sql/adddb.html?db=$DBName";

	// Old PHP Version
	// $File=@fopen("$AccessUrl","r");

		$File=@file_get_contents($AccessUrl);
       		if ($File)
        	{
        	$Success=1;
        	}
        	else
        	{
        	$Success=0;
        	}

    	return $Success;
    	}


?>
