<?php
include "navigator.php";
$Buttons="";
include "title.php";

$DDosID=intval($_REQUEST['DDosID']);
$CheckList=$_REQUEST['CheckList'];

if ($_SESSION['SessionSSHUsername']!="root")
{

	
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";

	exit;
	
}

if ($Action=="Block")
{
	$IP=$_REQUEST['IP'];
	$Username=ValidateUsername($_REQUEST['Username']);

	if ($Username=="")
	{
	$Username="-";
	}



	$Error=SSH ("/usr/bin/sudo /go/block $IP $Username add",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	if (stristr($Error,"success"))
	{
	echo Error("Users from the IP address(es) $IP will not be able to access your site.");
	}
	else
	{
	echo Error($Error);
	}
	
}

$Date=date ("Y-m-d",mktime (date("G"),date("i")+$GMT,date("s"),date("m"),date("d"),date("Y")));

    
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	

	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='15%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=IP')\">{$LNG['IP']}</a>
    </TH>
	
    <TH align='$DAlign' width='15%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Country')\">{$LNG['Country']}</a>
    </TH>

    <TH align='$DAlign' width='10%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=VisitorNo')\">{$LNG['VisitorNo']}</a>
    </TH>


    <TH align='$DAlign' width='15%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Browser')\">{$LNG['Browser']}</a>
    </TH>

    <TH align='$DAlign' width='40%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=UserAgent')\">{$LNG['UserAgent']}</a>
    </TH>

    <TH width='5%'>
 
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
	$Table="DDos";$Field="IP!='127.0.0.1' and IP!='$IPv4'";
	$DefaultSortBy="VisitorNo";
	$DefaultDirection="DESC";
	include "include/sql.php";
	

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$DDosID=$Row['DDosID'];
	$Domain=$Row['Domain'];
		
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
		

	$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

	$IPInfo="";
	if ($Row['IP']==getenv ("REMOTE_ADDR"))
	{
	$BlockIP="";
	$IPInfo=" ({$LNG['YourIP']})";
	}
	elseif (stristr($Row['IP'],":"))
	{
	$BlockIP="";
	}
	elseif (! filter_var($Row['IP'], FILTER_VALIDATE_IP))
	{
	$BlockIP="";
	}
	elseif ($Row['IP']==$IPv4)
	{
	$BlockIP="";
	$IPInfo=" ({$LNG['IPv4']})";
	}
	elseif ($Row['IP']=="127.0.0.1")
	{
	$BlockIP="";
	}		
	elseif (stristr($Row['UserAgent'],"bingbot") or stristr($Row['UserAgent'],"google") or stristr($Row['UserAgent'],"yandex"))
	{
	$BlockIP="";
	}
	else
	{
	$BlockIP="<a href=\"javascript:Load('$CurrentFileName?Action=Block&Username={$Row['Username']}&IP={$Row['IP']}')\" class=Action>{$LNG['Block']}</a>";
	}
	
    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['IP']}-{$Row['Country']}'>

    <TD>
    <a href=\"javascript:Load('httplog.php?SearchFor={$Row['IP']}')\">{$Row['IP']}</a>{$IPInfo} 
    </td>

	<TD>
   
    {$Row['Country']}
    </td>

	<TD>
    {$Row['VisitorNo']}
    </td>

	<TD>
    {$Row['Browser']}
    </td>
	
	<TD>
    {$Row['UserAgent']}
    </td>
	
	<TD align='$OAlign'>
	$BlockIP
    </td>
    
	</tr>
	";
	
	$X++;
	}
	
	if ($X!=0)
	{
	echo "</TBODY>";
	}

	echo "
	<TFOOT>

	<th align='$DAlign' colspan=2>
	Showing $X of $RowsNo records.
	</th>
	
	<th align='$OAlign' colspan=4>
	";
			
	include "pages.php";

	echo "
	</th>



	</TFOOT>

	</TABLE>
	</div>
	</form>
	";
	



	
?>