<?php
include "nav.php";
include "no.php";
$Buttons="";
include "title.php";

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}

$GithubID=intval($_REQUEST['GithubID']);

if ($_REQUEST['URL']!="")
{
	$Directory=trim($_REQUEST['Directory']);
	$URL=trim($_REQUEST['URL']);
	$Sync=trim($_REQUEST['Sync']);
	
	$DirectoryArray = explode('/', $Directory);
	$Domain = $DirectoryArray[2];
	
	include "access.php";
	
	if (file_exists($Directory))
	{

		$ProgressFile="github-$Domain.log";
		$Error=SSH ("sudo screen -d -m bash -c '/go/github $URL $Directory $Sync --progress > /var/log/go/progress/$ProgressFile'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("We’re downloading files from GitHub in the background. You can safely close this page - the download will continue.");
		echo Progress("Download in progress",$ProgressFile);
		
		echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
		exit;
		
	}
	else
	{
		echo Error("Directory $Directory not Exists.");
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
	exit;
}

if ($Action=="Delete")
{
	include "access.php";
	
	SQL ("DELETE from Github where GithubID='$GithubID'");
	
}

if ($Action=="Active")
{
	include "access.php";
	
	SQL ("UPDATE Github set Sync=1 where GithubID='$GithubID'");
	
}

if ($Action=="Inactive")
{
	include "access.php";
	
	SQL ("UPDATE Github set Sync=0 where GithubID='$GithubID'");
}

$Result = SQL("select * from Site where Trash=0 $SearchSql");
foreach ($Result as $Row)
{
	$Account['Domain'][]=$Row['Domain'];
	$Account['Username'][]=$Row['Username'];
}

if (is_array($Account['Domain']))
{
	array_multisort($Account['Domain'], SORT_ASC, SORT_STRING,$Account['Username'], SORT_NUMERIC, SORT_DESC);
	
	$SelectDomain="<select name='WWWPath' id='WWWPath' onchange='Folder()' class=Select>";
	for ($E=0;$E<count($Account['Domain']);$E++)
	{
		
		if ($Account['Domain'][$E]==$_REQUEST['Domain'])
		{
			$SelectDomain.="<option value='/home/{$Account['Domain'][$E]}/www' selected>{$Account['Domain'][$E]}</option>";
		}
		else
		{
			$SelectDomain.="<option value='/home/{$Account['Domain'][$E]}/www'>{$Account['Domain'][$E]}</option>";
		}
	}
	
	$SelectDomain.="</select>";
}

$Content=DesignCode($Content,"Github Content");
echo $Content;

include "search.php";

$Header=DesignCode($Header,"$Control (Header)");
echo $Header;

$Table="Github";$Field="GithubID>=1";
$DefaultSortBy="Directory";
$DefaultDirection="ASC";
include "include/sql.php";

$X=0;		
$Result = SQL($Sql);
foreach ($Result as $Row)
{
	$GithubID=$Row['GithubID'];
	
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
	
	if ($Row['Sync']==1)
	{
		$SyncCode="
		<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Inactive&GithubID={$Row['GithubID']}&&Username={$Row['Username']}&Domain={$Row['Domain']}&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>	
		";
	}
	else
	{
		$SyncCode="
		<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Active&GithubID={$Row['GithubID']}&Username={$Row['Username']}&Domain={$Row['Domain']}&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>	
		";
	}
	
	$SerialNo=(($Page-1)*$PageNo)+($X+1);
	
	$Date=$Row['Date'];
	
	echo DesignCode($Loop,"$Control (Loop)");
	
	$X++;
}

$Footer=DesignCode($Footer,"$Control (Footer)");
echo $Footer;
?>