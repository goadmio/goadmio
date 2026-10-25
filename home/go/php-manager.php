<?php
include "navigator.php";
$Buttons="";
include "title.php";

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	Echo "
	Sorry, You Are Not Allowed to Access This Page
	";

exit;
}

if ($Action=="Default")
{

	$PHPVersion=ValidateVersion($_REQUEST['PHPVersion'],"Invalid PHP Version.");
	
	$ProgressFile="defaultphp-$PHPVersion.log";
	$Error=SSH ("sudo screen -d -m bash -c '/go/defaultphp $PHPVersion --progress > /var/log/go/progress/$ProgressFile'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Default PHP $PHPVersion Running in the background. You can close this page.");
	echo Progress("Default PHP $PHPVersion",$ProgressFile);
	
	exit;
	
}

if ($Action=="Install")
{
	
	$PHPVersion=ValidateVersion($_REQUEST['PHPVersion'],"Invalid PHP Version.");
	
	$ProgressFile="installphp-$PHPVersion.log";
	$Error=SSH ("sudo screen -d -m bash -c '/go/installphp $PHPVersion --progress > /var/log/go/progress/$ProgressFile'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Installing PHP $PHPVersion Running in the background. You can close this page.");
	echo Progress("Installing PHP $PHPVersion",$ProgressFile);
	
	exit;
	
}

if ($Action=="Delete")
{

	$PHPVersion=ValidateVersion($_REQUEST['PHPVersion'],"Invalid PHP Version.");
	
	$ProgressFile="removephp-$PHPVersion.log";
	$Error=SSH ("sudo screen -d -m bash -c '/go/removephp $PHPVersion --progress > /var/log/go/progress/$ProgressFile'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Removing PHP $PHPVersion Running in the background. You can close this page.");
	echo Progress("Removing PHP $PHPVersion",$ProgressFile);
	
	exit;
	
}

	$Installed=SSH ("/usr/bin/sudo /go/multiphp Return",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$Installed=str_ireplace("php","",$Installed);
	$Installed=str_ireplace(".","",$Installed);

	
    Echo "
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='70%'>
    {$LNG['PHPVersion']}
    </TH>
	
    <TH width='20%'>
 
    </TH>

    <TH width='10%'>
 
    </TH>

	</tr>
	
	</THEAD>
	
	";
	
	$SortDir="ASC";

    if ($SortBy=="")
    {
    $SortBy="Domain";
    }

    if ($Page=="")
    {
    $Page=1;
    }

	$ListPHP=SSH ("/usr/bin/sudo /go/listphp",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],604800);

	$CurrentPHPVersion=SSH ("/usr/bin/sudo /go/defaultphp",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$CurrentPHPVersion=str_ireplace("php","",$CurrentPHPVersion);

	$PHPArray = array("5.6","7.0","7.1","7.2","7.3","7.4","8.0","8.1","8.2","8.3","8.4","8.5","8.6","8.7","8.8","8.9","9.0","9.1","9.2","9.3","9.4","9.5","9.5","9.6","9.7","9.8","9.9","10.0");

	$X=0;
	foreach ($PHPArray as &$PHPVersion) 
    {
		if (stristr($ListPHP,$PHPVersion))
		{

			$PHPString=str_ireplace(".","",$PHPVersion);


			if ($X==0)
			{
			echo "<TBODY>";
			}

			if ($X%2==0)
			{
			$TDColor="Td";
			}
			else
			{
			$TDColor="TdB";
			}
		
			ECHO "
			<tr id='TR{$ID}' class='$TDColor' divid=Find find=''>

			<TD>
			PHP $PHPVersion
			</td>
			
			<TD style='padding-top:15px'>
			";
			

			if (file_exists("/usr/local/goadmio/lock/installphp.lock")) 
			{
				if (filemtime("/usr/local/goadmio/lock/installphp.lock") > time() - 600) 
				{
				$SystemBusy=1;
				} 

			}
			
			if (stristr($Installed,$PHPString))
			{
		
				if (stristr($CurrentPHPVersion,$PHPVersion))
				{
				echo "
				Default
				";
				}
				else
				{
					if ($SystemBusy==1)
					{
					echo "Busy...";
					}
					else
					{
					echo "
					<a href=\"javascript:Load('$CurrentFileName?Action=Default&PHPVersion=$PHPVersion&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">{$LNG['MakeDefault']}</a>
					";
					}
				}

			}

			
			echo "
			</td>
		
			<TD>
			";
			
			if (stristr($Installed,$PHPString))
			{
				
				if (!stristr(phpversion(),$PHPVersion))
				{
					if ($SystemBusy==1)
					{
					echo "Busy...";
					}
					else
					{
					echo "<a href=\"javascript:Load('$CurrentFileName?Action=Delete&PHPVersion=$PHPVersion&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=ActionB>{$LNG['Remove']}</a>";
					}
				}
			}
			else
			{
				if ($SystemBusy==1)
				{
				echo "Busy...";
				}
				else
				{
				echo "<a href=\"javascript:Load('$CurrentFileName?Action=Install&PHPVersion=$PHPVersion&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>{$LNG['Install']}</a>";
				}
			}
			
			echo "
			
			</td>
		
		
			</tr>
			";
		
			$X++;
			
		}
			
	}
	
	if ($X!=0)
	{
	echo "</TBODY>";
	}

	echo "

	</TABLE>
	</div>
	";



	
?>