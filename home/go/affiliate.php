<?php
include "navigator.php";
$Buttons="";
include "title.php";

$Email=ValidateEmail($_REQUEST['Email']);
$AffiliateID=strtolower($_REQUEST['AffiliateID']);
$Password=ValidatePassword($_REQUEST['Password']);
$FullName=ValidateName($_REQUEST['FullName']);
$Mobile=ValidateMobile($_REQUEST['Mobile']);
$Gender=ValidateAlphanumeric($_REQUEST['Gender'],"Invalid Gender.");
$Country=ValidateAlphanumeric($_REQUEST['Country'],"Invalid Country.");
$Website=ValidateWebsite($_REQUEST['Website']);
$Company=ValidateAlphanumeric($_REQUEST['Company'],"Invalid Company");

$Password=str_replace("[DollarSign]","$",$Password);
$Password=str_replace("[AndSign]","&",$Password);
$Password=str_replace("[EqualSign]","=",$Password);

If ($Delete==1 and $Step==1)
{
	echo Error("Delete \"{$Email}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&ControlID=$ServiceID&AffiliateID=$AffiliateID&Email=$Email&Step=2','$ControlID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{

	$Sql = "DELETE from Affiliate where AffiliateID='$AffiliateID'";
	$Result = SQL($Sql);
	If ($Result)
	{
		echo Error("User $Email  has been deleted.");
	}

}
elseif ($_REQUEST['FullName']!="")
{

	if ($Edit==1)
	{
	
		$Sql = "UPDATE Affiliate SET Email='$Email',Password='$Password',FullName='$FullName',Mobile='$Mobile',Gender='$Gender',Country='$Country',Website='$Website',Company='$Company' where AffiliateID='$AffiliateID'";
		$Result = SQL($Sql);
		If ($Result)
		{
		echo Error("User $Email updated successfully.");
		}

	
	}
	else
	{
		$TimeStamp=time();
		$Sql = "INSERT INTO Affiliate (Email,Password,FullName,Mobile,Gender,Country,IP,Website,Company,TimeStamp) VALUES ('$Email','$Password','$FullName','$Mobile','$Gender','$Country','$IP','$Website','$Company','$TimeStamp')";
		$Result = SQL($Sql);
		If ($Result)
		{
		echo Error("User $Email created successfully.");
		}

	}
}

	$Email="";
	$Password="";
	$FullName="";
	$Mobile="";
	$Gender="";
	$Country="";
	$Website="";
	$Company="";
	if ($Edit==1)
	{
		$Sql = "select * from Affiliate where AffiliateID='$AffiliateID'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{ 
	
			$Email=$Row['Email'];
			$Password=$Row['Password'];
			$FullName=$Row['FullName'];
			$Mobile=$Row['Mobile'];
			$Gender=$Row['Gender'];
			$Country=$Row['Country'];
			$Website=$Row['Website'];
			$Company=$Row['Company'];

		}
				
	}

    

	Echo "

	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>

	<div class='DivInput {$Dir}DivInput'>Email<br>
	<input type='text' name='Email' value='$Email' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>
	Password<br>
	<input type='text' name='Password' value='$Password' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	Full Name<br>
	<input type='text' name='FullName' value='$FullName' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	Mob No<br>
	<input type='text' name='Mobile' value='$Mobile' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	Gender<br>
	<input type='radio' name='Gender' value='Male'> Male
	<input type='radio' name='Gender' value='Female'> Female
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	Country<br>
	<input type='text' name='Country' value='$Country' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	Company<br>
	<input type='text' name='Company' value='$Company' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	Website<br>
	<input type='text' name='Website' value='$Website' maxlength=100 class=InputText>
	</div>

	<div id=DivSubmit class=DivSubmit>
	
	";

	if ($Edit==1)
	{
		Echo "<input type=submit value='Save Changes' Class=InputButton>";
	}
	else
	{
		Echo "<input type=submit value='Save' Class=InputButton>";
	}


	Echo "
	</div>

</form>


";


	if($Edit!=1)
	{
	
		include "search.php";

		Echo "
		<div class=DivTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
	
		<th width='2%' height=40>

		</th>
		
		<th align='$DAlign' width='38%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=Email')\">Email</a>
		</th>
		
		<th align='$DAlign' width='30%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=TimeStamp')\">Created Date</a>
		</th>

		<th width='30%'>
		
		</span>
		</th>

		</tr>
		
		</THEAD>

		";

		if ($SortBy=="")
		{
			$SortBy="FullName";
		}
		
		if ($Direction=="")
		{
			$Direction="ASC";
		}
		
		if ($Page=="")
		{
			$Page=1;
		}

		$FilterSql=str_replace("\'","'",$FilterSql);

		$FromRecord=($Page-1)*$PageNo;

		if ($FilterSql!="")
		{
			$Sql = "select * from Affiliate where AffiliateID>=1 and $FilterSql $SearchSql order by $SortBy $Direction LIMIT $FromRecord,$PageNo";
			$RowsNo=RowsCount("select * from Affiliate where AffiliateID>=1 and $FilterSql $SearchSql");
		}
		elseif ($SearchFor=="")
		{
			$Sql = "select * from Affiliate where AffiliateID>=1 $SearchSql order by $SortBy $Direction  LIMIT $FromRecord,$PageNo";
			$RowsNo=RowCount("select * from Affiliate where AffiliateID>=1 $SearchSql");
		}
		else
		{
			$TableName="Affiliate";
			include "include/search.php";
		}

		

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			
			$AffiliateID=$Row['AffiliateID'];
			$Email=$Row['Email'];
		
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

			
			Echo "
			<tr name=R$i id=R$i divid=Find find='{$Row['Email']}' class='$TDColor'>

			<TD align='middle'>
			{$Row['AffiliateID']}
			</TD>

			<TD>{$Row['FullName']}</TD>

			<TD>{$Row['Email']}</TD>
			
			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&AffiliateID={$Row['AffiliateID']}&Email={$Row['Email']}')\" class=Action>Edit</a>&nbsp;
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&AffiliateID={$Row['AffiliateID']}&Email={$Row['Email']}')\" class=Action>Delete</a>&nbsp;

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

		<tr>

		<th align='$DAlign' colspan=2>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=2>
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


echo "
</div>
";

	
?>