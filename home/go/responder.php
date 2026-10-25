<?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

$ResponderFirstDay=$_REQUEST['ResponderFirstDay'];
$ResponderLastDay=$_REQUEST['ResponderLastDay'];

$Domain=ValidateDomain($_REQUEST['Domain']);

if ($_REQUEST['User']!="")
{
$Email=$_REQUEST['User']."@".$Domain;
}
else
{
$Email=$_REQUEST['Email'];
}

$ResponderSubject=$_REQUEST['ResponderSubject'];
$ResponderMessage=$_REQUEST['ResponderMessage'];

$ResponderActive=intval($_REQUEST['ResponderActive']);

If ($Delete==1 and $Step==1)
{
	echo Error("Are you sure you want to delete the autoresponder for $Email? <a href=\"javascript:Load('$CurrentFileName?Delete=1&Domain=$Domain&Email=$Email&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{

	include "access.php";

	$Sql = "UPDATE Mail SET ResponderSubject='',ResponderMessage='',ResponderFirstDay='',ResponderLastDay='',ResponderActive='-0' where Email='$Email'";
	$Result = SQL($Sql);
	
	echo Error("Auto-responder has been deleted successfully for email: {$Email}");

	// $Error=SSH ("/usr/bin/sudo /go/responder $Email delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	// echo Error("$Error");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

	exit;

}

if ($ResponderSubject!="")
{

	include "access.php";
	
	if ($Email!="")
	{
		$Sql = "UPDATE Mail SET ResponderSubject='$ResponderSubject',ResponderMessage='$ResponderMessage',ResponderFirstDay='$ResponderFirstDay',ResponderLastDay='$ResponderLastDay',ResponderActive='$ResponderActive' where Email='$Email'";
		$Result = SQL($Sql);
		
		echo Error("Auto-responder created successfully for email: {$Email}");

		echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
		exit;
		

	}
	
	// $Error=SSH ("/usr/bin/sudo /go/responder $Email add",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	// echo Error("$Error");
	
	$Edit=0;

}


	if ($Edit==1)
	{
		$Sql = "select * from Mail where Email='$Email'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{ 
			$EmailArray=explode("@",$Row['Email']);
			$User=$EmailArray[0];
			
			$Domain=$Row['Domain'];
			
			$ResponderSubject=$Row['ResponderSubject'];
			$ResponderMessage=$Row['ResponderMessage'];
			
			$ResponderFirstDay=$Row['ResponderFirstDay'];
			$ResponderLastDay=$Row['ResponderLastDay'];

			if ($Row['ResponderActive']==0)
			{
			$ResponderOffChecked="checked";
			}
			
		}
	}
	else
	{
	
			$User="";
			$Domain="";
			
			$ResponderSubject="";
			$ResponderMessage="";
			
			$ResponderFirstDay="";
			$ResponderLastDay="";
	}

	echo "
	<div>
	";
	
	if ($Edit==1)
	{
	echo "Editing Email \"$Email\"";
	}
	else
	{
	echo "$PageTabName";
	}
	
	echo "
	</div>
	
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'><input type=hidden name=ServiceControl value='$ServiceControl'>
	<input type=hidden name=MailID value='$MailID'>

	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Email']}<br>
	";
	
	if ($Edit==1)
	{
		echo "
		<input type='hidden' name='User' value='$User'>
		<input type='hidden' name='Domain' value='$Domain'>
		$User@$Domain
		";
	}
	else
	{
		Echo "<input type='Text' name='User' maxlength=100 class=InputText style='width:24%'>@";
		
		unset($Domains);
		$Result = SQL("select * from Site where Trash=0 $SearchSql");
		foreach ($Result as $Row)
		{
		$Domains[]=$Row['Domain'];
		}
		
		if (is_array($Domains))
		{
			sort($Domains);
		}
		else
		{
			$Domains[]="";
		}
		
		echo "
		<select name='Domain' id='Domain' class=Select style='width:24%'>
		";
		
		foreach ($Domains as $Domain) 
		{
			if ($Domain==$_REQUEST['Domain'])
			{
			echo "<option value='$Domain' selected>$Domain</option>";
			}
			else
			{
			echo "<option value='$Domain'>$Domain</option>";
			}
		}

		echo "</select>";
	
	}
	Echo "
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Subject']}<br>
	<input type='text' name='ResponderSubject' value='$ResponderSubject' required maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	{$LNG['Message']}
	</div>

	<div class='DivInput {$Dir}DivInput'>
	<textarea rows='10' name='ResponderMessage' id='ResponderMessage' cols=80 class=TextArea>$ResponderMessage</Textarea>
	</div>
	
	 
	<div class='DivInput {$Dir}DivInput'>
	{$LNG['FirstDay']}: <input type='date' name='ResponderFirstDay' id='ResponderFirstDay' value='$ResponderFirstDay' class=InputText style='width:20%'> 
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	{$LNG['LastDay']}: <input type='date' name='ResponderLastDay' id='ResponderLastDay' value='$ResponderLastDay' class=InputText style='width:20%'>
	</div>

	";
	
	if ($ResponderOffChecked!="checked")
	{
	$ResponderOnChecked="checked";
	}

	echo "
	<div class='DivInput {$Dir}DivInput'>

		<label class=\"radio-enhanced\">
			<input type='radio' name='ResponderActive' value='0' $ResponderOffChecked>
			<span class=\"radio-custom\"></span>
			<span class=\"radio-label-text\">
			{$LNG['VacationResponderOff']}
			</span>
		</label>

		<label class=\"radio-enhanced\">
			<input type='radio' name='ResponderActive' value='0' $ResponderOnChecked>
			<span class=\"radio-custom\"></span>
			<span class=\"radio-label-text\">
			{$LNG['VacationResponderOn']}
			</span>
		</label>
	
	</div>
	
	<div id=DivSubmit class=DivSubmit>
	";

	if ($Edit==1)
	{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
	}
	else
	{
		Echo "<input type=submit value='{$LNG['Create']}' Class=InputButton>";
	}
	
	Echo "
	</div>

</form>


";

	if($Edit!=1)
	{

		Echo "
		<div class=DivTable>
		<table cellPadding='8' cellSpacing=0 width='100%' class=Table>

		<THEAD>
		
		<tr>
		
		<th align='$DAlign' width='30%'>
		Email
		</th>
		
		<th align='$DAlign' width='10%'>
		Subject
		</th>

		<th align='$DAlign' width='10%'>
		First Day
		</th>
		
		<th align='$DAlign' width='10%'>
		Last Day
		</th>


		<th align='$DAlign' width='10%'>
		Status
		</th>

		<th align='$OAlign' width='20%'>
		
		</th>

		";
		
		$Table="Mail";$Field="ResponderSubject!=''";
		$DefaultSortBy="Email";
		$DefaultDirection="ASC";
		include "include/sql.php";

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{

		
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
			
			$ResponderFirstDay=substr($Row['ResponderFirstDay'],8,2)."/".substr($Row['ResponderFirstDay'],5,2)."/".substr($Row['ResponderFirstDay'],0,4);
			$ResponderLastDay=substr($Row['ResponderLastDay'],8,2)."/".substr($Row['ResponderLastDay'],5,2)."/".substr($Row['ResponderLastDay'],0,4);

			if ($Row['ResponderActive']==1)
			{
			$ActiveStatus="<img src='image/true.svg' style='width:24px;height:24px;'>";
			}
			else
			{
			$ActiveStatus="";
			}
		
			Echo "<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Email']}-{$Row['Domain']}'>";
			
			Echo "<TD>{$Row['Email']}</TD>";

			Echo "<TD>{$Row['ResponderSubject']}</TD>";
			Echo "<TD>$ResponderFirstDay</TD>";
			Echo "<TD>$ResponderLastDay</TD>";
			
			Echo "<TD width='15%'>$ActiveStatus</TD>";
			
			Echo "<TD align='$LNG[OAlign]' width='20%'>";
			
			echo "
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&Step=1&Email={$Row['Email']}&Domain={$Row['Domain']}')\" class=Action>Edit</a>
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&Email={$Row['Email']}&Domain={$Row['Domain']}')\" class=Action>Delete</a>
			";
			
			echo "</TD>"; 
			
			$X++;
		}
		
		if ($X!=0)
		{
		echo "</TBODY>";
		}

		echo "
		<TFOOT>

		<tr>

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
		
	}


	
?>