<?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

$Directory=ValidateDirectory($_REQUEST['Directory']);
$User=trim($_REQUEST['User']);
$Pass=ValidatePassword($_REQUEST['Pass']);

$FtpID=$_REQUEST['FtpID'];

if ($Action!="")
{

	$Domain=ValidateDomain($_REQUEST['Domain']);

	include "access.php";

	$Error=SSH ("/usr/bin/sudo /go/ftp $Domain - $User - $Action",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	
}
else
{

	If ($Delete==1 and $Step==1)
	{
		$Domain=ValidateDomain($_REQUEST['Domain']);
		
		echo Error("Delete \"{$User}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&Domain=$Domain&User=$User&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName')\" class=Action>No</a>");
		exit;
	}

	if ($Delete==1 and $Step==2)
	{
		$Domain=ValidateDomain($_REQUEST['Domain']);
		
		include "access.php";

		$Error=SSH ("/usr/bin/sudo /go/ftp $Domain - $User - delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");

		echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
		exit;
	}

	if ($_REQUEST['Directory']!="")
	{
		$Part=explode("/", $Directory);
		$Domain = $Part[2];
	
		include "access.php";

		if ($Edit==1)
		{
		$Error=SSH ("/usr/bin/sudo /go/ftp $Domain $Directory $User $Pass edit",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");	
		}
		else
		{
		$Error=SSH ("/usr/bin/sudo /go/ftp $Domain $Directory $User $Pass add",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");	
		}
		
		$Edit="";
		
	}

}


	$Domain="";
	$Directory="";
	$Pass="";
	if ($Edit==1)
	{
		$Sql = "select * from Ftp where User='$User'";
		$Result=SQL($Sql);
		foreach ($Result as $Row)
		{

			$Domain=$Row['Domain'];
			$Username=$Row['Username'];
			$Directory=$Row['Directory'];
			$User=$Row['User'];
			$Pass=$Row['Pass'];

		}
		
		$Sql = "select Domain from Site where Domain='$Domain'";
		$Result=SQL($Sql);
		foreach ($Result as $Row)
		{
		$Domain=$Row['Domain'];
		}

		if ($_SESSION['SessionPassword']=="demo")
		{
		$Password="********";
		}
		
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


	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=FtpID value='$FtpID'>
	";

	if ($Edit!=1)
	{
	echo "
	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>
	$SelectDomain	
	</div>

	<!-- Folder Selector Component - No Search -->
	<div class=\"folder-selector-wrapper\">
		<div class=\"folder-tree-list\" id=\"folderTreeContainer\">
			<!-- Folder tree will be rendered here -->
		</div>
	</div>
	";
	}

	echo "
	<div class='DivInput {$Dir}DivInput'>{$LNG['Directory']}<br>	
	";
	
	if ($Edit==1)
	{
		echo "<input type='Text' name='Directory' id='Directory' readonly value='$Directory' maxlength=255 class=InputText>";
	}
	else
	{
		echo "<input type='Text' name='Directory' id='Directory' value='$Directory' maxlength=255 class=InputText>";
	}
		
	echo "
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['FTPUsername']}<br>	

	";

	if ($Edit==1)
	{
		Echo "<input type='Text' name='User' value='$User' maxlength=100 readonly autocomplete='off' class=InputText>";
	}
	else
	{
		Echo "<input type='Text' name='User' maxlength=100 autocomplete='off' class=InputText>";
	}

	echo "
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['FTPPassword']}<br>
	<input type='password' name='Pass' id='Password' autocomplete='new-password' required maxlength=100 class=InputText> <span onclick=\"GeneratePassword('Password')\" style='cursor:pointer'>Generate Password</span>
	</div>

	<div id=DivSubmit class=DivSubmit>
	";
	
	if ($Edit==1)
	{
		echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
	}
	else
	{
		echo "<input type=submit value='{$LNG['Create']}' Class=InputButton>";
	}


	Echo "
	</div>

</form>
";


		include "search.php";

		echo "

		<div class=DivXTable>
		<table cellPadding='8' cellSpacing=0 width='100%' class=Table>
		<THEAD>
		
		<tr>
		
		<th align='$DAlign' width='15%'>
		{$LNG['FTPUsername']}
		</th>
		
		<th align='$DAlign' width='20%'>
		{$LNG['Directory']}
		</th>
		
		<th align='$DAlign' width='15%'>
		{$LNG['Permissions']}
		</span>
		</th>
		
		<th align='$OAlign' width='50%'>

		</th>
		
		</tr>
		
		</THEAD>

		";

		$Table="Ftp";$Field="FtpID>=1";
		$DefaultSortBy="User";
		$DefaultDirection="ASC";
		include "include/sql.php";
		

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		$Domain=$Row['Domain'];
		$Username=$Row['Username'];
		$User=$Row['User'];

		$FTPStatus=$Row['FTPStatus'];
		$FTPUpload=$Row['FTPUpload'];
		$FTPDownload=$Row['FTPDownload'];
		$FTPDelete=$Row['FTPDelete'];
		
		if ($FTPUpload==1)
		{
			if ($Permissions=="")
			{
			$Permissions="Upload";
			}
			else
			{
			$Permissions.=", Upload";
			}
		}
		
		if ($FTPDownload==1)
		{
			if ($Permissions=="")
			{
			$Permissions="Download";
			}
			else
			{
			$Permissions.=", Download";
			}
		}
		
		if ($FTPDelete==1)
		{
			if ($Permissions=="")
			{
			$Permissions="Delete";
			}
			else
			{
			$Permissions.=", Delete";
			}
		}
		
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
			
			$SerialNo=(($Page-1)*$PageNo)+($X+1);
			
			echo "
			
			<tr name=R$i id=R$i divid=Find find='{$Row['Username']}-{$Row['User']}-{$Row['Directory']}' class='$TDColor'>

			<TD>{$Row['User']}</TD>
			
			<TD>{$Row['Directory']}</TD>
			
			<TD>$Permissions</TD>
			
			<TD align='$OAlign'>  
			";
			
			if ($FTPStatus==1)
			{
			echo "<a title='Disable FTP Login for $User' href=\"javascript:Load('$CurrentFileName?Action=DisableFTP&Domain=$Domain&User=$User&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Disabe FTP</a>";	
			}
			else
			{
			echo "<a title='Enable FTP Login for $User' href=\"javascript:Load('$CurrentFileName?Action=EnableFTP&Domain=$Domain&User=$User&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Enable FTP</a>";
			}
			
			if ($FTPUpload==1)
			{
			echo "<a title='Disable FTP Upload for $User' href=\"javascript:Load('$CurrentFileName?Action=DisableUpload&Domain=$Domain&User=$User&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Disabe Upload</a>";	
			}
			else
			{
			echo "<a title='Enable FTP Upload for $User' href=\"javascript:Load('$CurrentFileName?Action=EnableUpload&Domain=$Domain&User=$User&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Enable Upload</a>";
			}
			
			if ($FTPDownload==1)
			{
			echo "<a title='Disable FTP Download for $User' href=\"javascript:Load('$CurrentFileName?Action=DisableDownload&Domain=$Domain&User=$User&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Disabe Download</a>";	
			}
			else
			{
			echo "<a title='Enable FTP Download for $User' href=\"javascript:Load('$CurrentFileName?Action=EnableDownload&Domain=$Domain&User=$User&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Enable Download</a>";
			}
			
			if ($FTPDelete==1)
			{
			echo "<a title='Disable FTP Delete for $User' href=\"javascript:Load('$CurrentFileName?Action=DisableDelete&Domain=$Domain&User=$User&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Disabe Delete</a>";	
			}
			else
			{
			echo "<a title='Enable FTP Delete for $User' href=\"javascript:Load('$CurrentFileName?Action=EnableDelete&Domain=$Domain&User=$User&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Enable Delete</a>";
			}
	
			echo "
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&Domain=$Domain&User={$Row['User']}&FtpID={$Row['FtpID']}')\" class=Action>Edit</a>

			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&Domain=$Domain&User=$User')\" class=Action>Delete</a>


			</TD>
			";
			
		$X++;
		}
		

		if ($X!=0)
		{
		echo "</TBODY>";
		}

		echo "
		<TFOOT>

		<tr class=TdDown>

		<th align='$DAlign' colspan=3>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=4>
		";
				
		include "pages.php";

		echo "
		</th>

		</tr>

		</TFOOT>

		</TABLE>
		</div>
		</form>
		";
		

?>